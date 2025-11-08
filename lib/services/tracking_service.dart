import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/user_profile.dart';
import '../models/workout_session.dart' as ws;
import './database_service.dart';

class TrackingService {
  static final TrackingService _instance = TrackingService._internal();
  factory TrackingService() => _instance;
  TrackingService._internal();

  final DatabaseService _db = DatabaseService();

  // Streams
  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<Position>? _positionSubscription;

  // Current workout state
  ws.WorkoutSession? _currentSession;
  DateTime? _workoutStartTime;
  final List<Position> _routePoints = [];
  int _currentSteps = 0;
  int _workoutStartSteps = 0;
  double _totalDistance = 0.0;
  bool _isTracking = false;

  // Getters
  bool get isTracking => _isTracking;
  ws.WorkoutSession? get currentSession => _currentSession;
  int get currentSteps => _currentSteps;
  double get currentDistance => _totalDistance;

  // ───────────── Permissions ─────────────
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Permission.location.request();
      return permission.isGranted;
    } catch (e) {
      debugPrint('Location permission error: $e');
      return false;
    }
  }

  Future<bool> requestActivityPermission() async {
    try {
      final p = await Permission.activityRecognition.request();
      // بعض الأجهزة لا تدعم، لذلك نسمح بالمتابعة حتى لو مرفوض
      return p.isGranted || p.isPermanentlyDenied;
    } catch (e) {
      debugPrint('Activity permission error: $e');
      return true;
    }
  }

  Future<bool> hasLocationPermission() async {
    try {
      return (await Permission.location.status).isGranted;
    } catch (_) {
      return false;
    }
  }

  // ─────── Initialize tracking services ───────
  Future<bool> initializeTracking() async {
    try {
      final hasLocation = await requestLocationPermission();
      await requestActivityPermission();

      if (!hasLocation) {
        debugPrint('Location permission denied');
        return false;
      }

      // تحذير فقط إن كانت خدمات الموقع مغلقة
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
      }

      await _initializeStepCounting();
      debugPrint('Tracking services initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Initialize tracking error: $e');
      return false;
    }
  }

  Future<void> _initializeStepCounting() async {
    try {
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        (StepCount event) {
          _currentSteps = event.steps;
          debugPrint('Current steps: $_currentSteps');
        },
        onError: (error) => debugPrint('Step counting error: $error'),
      );
    } catch (e) {
      debugPrint('Step counting initialization error: $e');
    }
  }

  // ───────────── Start workout ─────────────
  Future<bool> startWorkout(String workoutType) async {
    try {
      if (_isTracking) {
        debugPrint('Workout already in progress');
        return false;
      }

      _workoutStartTime = DateTime.now();
      _workoutStartSteps = _currentSteps;
      _routePoints.clear();
      _totalDistance = 0.0;
      _isTracking = true;

      final wt = workoutType.toLowerCase();
      if (wt == 'running' || wt == 'walking') {
        await _startLocationTracking();
      }

      debugPrint('Workout started: $workoutType');
      return true;
    } catch (e) {
      debugPrint('Start workout error: $e');
      return false;
    }
  }

  Future<void> _startLocationTracking() async {
    try {
      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // meter
      );

      _positionSubscription =
          Geolocator.getPositionStream(locationSettings: settings).listen(
        (Position pos) {
          _addLocationPoint(pos);
        },
        onError: (error) => debugPrint('Location tracking error: $error'),
      );
    } catch (e) {
      debugPrint('Start location tracking error: $e');
    }
  }

  void _addLocationPoint(Position position) {
    if (_routePoints.isNotEmpty) {
      final last = _routePoints.last;
      final distance = Geolocator.distanceBetween(
        last.latitude,
        last.longitude,
        position.latitude,
        position.longitude,
      );
      _totalDistance += distance;
    }
    _routePoints.add(position);
  }

  // ───────────── End workout ─────────────
  Future<ws.WorkoutSession?> endWorkout() async {
    try {
      if (!_isTracking || _workoutStartTime == null) {
        debugPrint('No active workout to end');
        return null;
      }

      final endTime = DateTime.now();
      final durationMin = endTime.difference(_workoutStartTime!).inMinutes;
      final workoutSteps = _currentSteps - _workoutStartSteps;

      final calories = await _calculateCalories('general', durationMin);

      double avgPace = 0.0; // min/km
      if (_totalDistance > 0 && durationMin > 0) {
        final km = _totalDistance / 1000.0;
        if (km > 0) avgPace = durationMin / km;
      }

      _currentSession = ws.WorkoutSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        workoutType: 'Workout',
        sessionDate: _workoutStartTime!,
        durationMinutes: durationMin,
        caloriesBurned: calories.toInt(),
        createdAt: DateTime.now(),
      );

      await _db.insertWorkoutSession(_currentSession!);

      // reset state
      _isTracking = false;
      _workoutStartTime = null;
      _routePoints.clear();
      _totalDistance = 0.0;
      _workoutStartSteps = 0;

      await _stopLocationTracking();

      debugPrint('Workout ended and saved: ${_currentSession!.id}');
      return _currentSession;
    } catch (e) {
      debugPrint('End workout error: $e');
      return null;
    }
  }

  Future<void> _stopLocationTracking() async {
    try {
      await _positionSubscription?.cancel();
      _positionSubscription = null;
    } catch (e) {
      debugPrint('Stop location tracking error: $e');
    }
  }

  // ───────────── Helpers ─────────────
  Future<double> _calculateCalories(String workoutType, int minutes) async {
    try {
      final UserProfile? profile = await _db.getUserProfile();
      final weight = profile?.weightKg ?? 70.0;

      final Map<String, double> metValues = {
        'running': 8.0,
        'walking': 3.8,
        'cycling': 6.8,
        'strength': 3.5,
        'yoga': 2.5,
        'general': 4.0,
      };

      final met = metValues[workoutType.toLowerCase()] ?? 4.0;
      // kcal = MET × 3.5 × weight(kg) / 200 × minutes
      return met * 3.5 * weight / 200 * minutes;
    } catch (e) {
      debugPrint('Calculate calories error: $e');
      return 0.0;
    }
  }

  String? _encodePolyline(List<Position> points) {
    if (points.isEmpty) return null;
    return points.map((p) => '${p.latitude},${p.longitude}').join(';');
    // ملاحظة: هذا ترميز بسيط. لاحقًا ممكن نستبدله بـ Google Polyline.
  }

  Future<int> getTodaysSteps() async {
    try {
      return _currentSteps;
    } catch (e) {
      debugPrint('Get today steps error: $e');
      return 0;
    }
  }

  Future<void> dispose() async {
    try {
      await _stepCountSubscription?.cancel();
      await _positionSubscription?.cancel();
      debugPrint('Tracking service disposed');
    } catch (e) {
      debugPrint('Dispose tracking service error: $e');
    }
  }
}