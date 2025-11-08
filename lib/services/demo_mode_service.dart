import 'package:flutter/foundation.dart';

import '../models/user_profile.dart' as models;
import './fitness_data_service.dart';
import './supabase_service.dart';

class DemoModeService {
  static final DemoModeService _instance = DemoModeService._internal();
  factory DemoModeService() => _instance;
  DemoModeService._internal();

  final FitnessDataService _fitnessService = FitnessDataService.instance;
  bool _isDemoMode = false;
  bool _isSupabaseConnected = false;

  bool get isDemoMode => _isDemoMode || !_isSupabaseConnected;

  Future<void> initialize() async {
    try {
      // Check Supabase connection status
      _isSupabaseConnected = await _checkSupabaseConnection();

      // If connected to Supabase, disable demo mode
      if (_isSupabaseConnected) {
        _isDemoMode = false;
        debugPrint('Supabase connected - Demo mode: OFF');
      } else {
        _isDemoMode = true;
        debugPrint('Supabase not connected - Demo mode: ON');
      }
    } catch (e) {
      debugPrint('Demo mode initialization error: $e');
      _isDemoMode = true; // Default to demo mode on error
      _isSupabaseConnected = false;
    }
  }

  Future<bool> _checkSupabaseConnection() async {
    try {
      return await SupabaseService.instance.isConnected();
    } catch (e) {
      debugPrint('Supabase connection check failed: $e');
      return false;
    }
  }

  Future<void> setDemoMode(bool enabled) async {
    try {
      _isDemoMode = enabled;
      debugPrint('Demo mode manually set to: $_isDemoMode');
    } catch (e) {
      debugPrint('Set demo mode error: $e');
    }
  }

  // Mock user for demo mode
  static models.UserProfile get currentUser => models.UserProfile(
        id: 'd3bac2c5-5141-494d-9c19-62deaa46b52a',
        email: 'demo@fitmotion.com',
        fullName: 'Demo User',
        role: 'member',
        age: 25,
        gender: 'male',
        weightKg: 70.0,
        heightCm: 175.0,
        activityLevel: 'moderately_active',
        units: 'metric',
        dailyCalorieGoal: 2200,
        weeklyWorkoutGoal: 4,
        preferredWorkoutDuration: 45,
        notificationsEnabled: true,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );

  // Get workout data - real or mock based on connection
  Future<List<Map<String, dynamic>>> getWorkouts({String? type}) async {
    if (!isDemoMode && _isSupabaseConnected) {
      try {
        // Get real data from Supabase
        final sessions = await _fitnessService.getWorkoutSessions(limit: 10);
        return sessions
            .map((session) => {
                  'id': (session as dynamic).id,
                  'name': _formatWorkoutName((session as dynamic).workoutType),
                  'type': (session as dynamic).workoutType,
                  'duration': (session as dynamic).durationMinutes,
                  'calories': (session as dynamic).caloriesBurned ?? 0,
                  'lastCompleted': _formatLastCompleted((session as dynamic).sessionDate),
                  'difficulty': _getDifficulty((session as dynamic).durationMinutes),
                  'image': _getWorkoutImage((session as dynamic).workoutType),
                  'semanticLabel': _getSemanticLabel((session as dynamic).workoutType),
                })
            .toList();
      } catch (e) {
        debugPrint(
            'Failed to load real workout data, falling back to mock: $e');
        return await _fitnessService.getMockWorkouts();
      }
    } else {
      // Return mock data
      return await _fitnessService.getMockWorkouts();
    }
  }

  // Get statistics - real or mock based on connection
  Future<Map<String, dynamic>> getStats() async {
    if (!isDemoMode && _isSupabaseConnected) {
      try {
        // Get real stats from Supabase
        final stats = await _fitnessService.getWorkoutStats();
        final streak = await _fitnessService.getCurrentStreak();

        return {
          'totalWorkouts': stats['totalWorkouts'],
          'totalMinutes': stats['totalMinutes'],
          'totalCalories': stats['totalCalories'],
          'currentStreak': streak,
          'averageDuration': stats['averageDuration'],
          'weeklyGoal': 4, // Could be fetched from user profile
          'weeklyProgress': (stats['totalWorkouts'] as int) / 4,
        };
      } catch (e) {
        debugPrint('Failed to load real stats, falling back to mock: $e');
        return await _fitnessService.getMockStats();
      }
    } else {
      // Return mock stats
      return await _fitnessService.getMockStats();
    }
  }

  // Get fitness goals - real or mock based on connection
  Future<List<FitnessGoal>> getFitnessGoals() async {
    if (!isDemoMode && _isSupabaseConnected) {
      try {
        return await _fitnessService.getFitnessGoals();
      } catch (e) {
        debugPrint('Failed to load real goals, falling back to mock: $e');
        return _getMockFitnessGoals();
      }
    } else {
      return _getMockFitnessGoals();
    }
  }

  // Get workout categories with mock data
  Future<List<Map<String, dynamic>>> getWorkoutCategories() async {
    await Future.delayed(
        const Duration(milliseconds: 200)); // Simulate network delay
    return [
      {
        'id': 'cardio',
        'name': 'Cardio',
        'description': 'Heart-pumping cardio workouts',
        'icon': 'favorite',
        'color': '0xFFE57373',
        'workoutCount': 24,
        'estimatedTime': '15-45 min',
        'image':
            'https://images.unsplash.com/photo-1654506303412-d20a5f5496a3',
        'semanticLabel': 'Person running on treadmill in modern gym',
      },
      {
        'id': 'strength',
        'name': 'Strength',
        'description': 'Build muscle and increase strength',
        'icon': 'fitness_center',
        'color': '0xFF81C784',
        'workoutCount': 32,
        'estimatedTime': '20-60 min',
        'image':
            'https://images.unsplash.com/photo-1639653822674-b4daa880b4d9',
        'semanticLabel': 'Athlete lifting heavy barbell in weightlifting gym',
      },
      {
        'id': 'yoga',
        'name': 'Yoga',
        'description': 'Improve flexibility and mindfulness',
        'icon': 'self_improvement',
        'color': '0xFF9575CD',
        'workoutCount': 18,
        'estimatedTime': '15-90 min',
        'image':
            'https://images.unsplash.com/photo-1686243693635-54b439470428',
        'semanticLabel':
            'Group of people in warrior pose during outdoor yoga class',
      },
      {
        'id': 'pilates',
        'name': 'Pilates',
        'description': 'Core strength and body alignment',
        'icon': 'accessibility_new',
        'color': '0xFF64B5F6',
        'workoutCount': 15,
        'estimatedTime': '30-60 min',
        'image':
            'https://images.unsplash.com/photo-1613063373939-fad101bf3ecc',
        'semanticLabel':
            'Woman performing pilates exercise on reformer machine',
      },
    ];
  }

  // Get achievements with mock data
  Future<List<Map<String, dynamic>>> getAchievements() async {
    await Future.delayed(
        const Duration(milliseconds: 400)); // Simulate network delay
    return [
      {
        'id': 'first_workout',
        'name': 'First Steps',
        'description': 'Completed your first workout',
        'icon': 'emoji_events',
        'earned': true,
        'earnedDate': '2024-01-15',
        'category': 'milestone',
      },
      {
        'id': 'week_streak',
        'name': 'Week Warrior',
        'description': 'Workout streak of 7 days',
        'icon': 'local_fire_department',
        'earned': false,
        'progress': 3,
        'target': 7,
        'category': 'streak',
      },
      {
        'id': 'cardio_master',
        'name': 'Cardio Master',
        'description': 'Complete 25 cardio workouts',
        'icon': 'favorite',
        'earned': false,
        'progress': 18,
        'target': 25,
        'category': 'workout_type',
      },
    ];
  }

  // Helper methods for formatting data
  String _formatWorkoutName(String workoutType) {
    switch (workoutType.toLowerCase()) {
      case 'hiit cardio':
        return 'HIIT Cardio Blast';
      case 'strength training':
        return 'Strength Training';
      case 'yoga':
        return 'Morning Yoga';
      case 'running':
        return 'Morning Run';
      case 'cycling':
        return 'Cycling Session';
      default:
        return workoutType;
    }
  }

  String _formatLastCompleted(DateTime sessionDate) {
    final now = DateTime.now();
    final difference = now.difference(sessionDate).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference <= 7) {
      return '$difference days ago';
    } else {
      return '${sessionDate.day}/${sessionDate.month}/${sessionDate.year}';
    }
  }

  String _getDifficulty(int duration) {
    if (duration <= 20) return 'Beginner';
    if (duration <= 40) return 'Intermediate';
    return 'Advanced';
  }

  String _getWorkoutImage(String workoutType) {
    switch (workoutType.toLowerCase()) {
      case 'hiit cardio':
        return 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=200&fit=crop';
      case 'strength training':
        return 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=300&h=200&fit=crop';
      case 'yoga':
        return 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=300&h=200&fit=crop';
      default:
        return 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=300&h=200&fit=crop';
    }
  }

  String _getSemanticLabel(String workoutType) {
    switch (workoutType.toLowerCase()) {
      case 'hiit cardio':
        return 'High intensity interval training workout with jumping exercises';
      case 'strength training':
        return 'Weight training session with dumbbells and barbells';
      case 'yoga':
        return 'Peaceful yoga session on a mat in morning sunlight';
      default:
        return 'Fitness workout session';
    }
  }

  List<FitnessGoal> _getMockFitnessGoals() {
    return [
      FitnessGoal(
        id: 'goal_1',
        userId: 'd3bac2c5-5141-494d-9c19-62deaa46b52a',
        goalType: 'weight_loss',
        targetValue: 75,
        currentValue: 78.5,
        targetDate: DateTime.now().add(const Duration(days: 90)),
        isAchieved: false,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      FitnessGoal(
        id: 'goal_2',
        userId: 'd3bac2c5-5141-494d-9c19-62deaa46b52a',
        goalType: 'workout_streak',
        targetValue: 30,
        currentValue: 12,
        targetDate: DateTime.now().add(const Duration(days: 60)),
        isAchieved: false,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Check if Supabase is connected (for UI feedback)
  Future<bool> checkSupabaseConnection() async {
    _isSupabaseConnected = await _checkSupabaseConnection();
    return _isSupabaseConnected;
  }

  // Get connection status message
  Future<String> getConnectionStatus() async {
    await checkSupabaseConnection();
    if (_isSupabaseConnected) {
      return 'Connected to Supabase';
    } else {
      return 'Running in Demo Mode - Limited functionality';
    }
  }

  // Authentication methods that work with real Supabase or demo mode
  Future<bool> signIn(String email, String password) async {
    if (!isDemoMode && _isSupabaseConnected) {
      try {
        final response =
            await SupabaseService.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        return response.user != null;
      } catch (e) {
        debugPrint('Real sign-in failed: $e');
        return false;
      }
    } else {
      // Demo mode - accept any valid credentials
      await Future.delayed(const Duration(seconds: 1)); // Simulate auth delay
      return email.isNotEmpty && password.isNotEmpty;
    }
  }

  Future<bool> signUp(String email, String password, String fullName) async {
    if (!isDemoMode && _isSupabaseConnected) {
      try {
        final response = await SupabaseService.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        if (response.user != null) {
          // Create user profile in Supabase
          final profile = models.UserProfile(
            id: response.user!.id,
            email: email,
            fullName: fullName,
            role: 'member',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _fitnessService.createUserProfile(profile);
        }

        return response.user != null;
      } catch (e) {
        debugPrint('Real sign-up failed: $e');
        return false;
      }
    } else {
      // Demo mode - accept any valid credentials
      await Future.delayed(const Duration(seconds: 1)); // Simulate auth delay
      return email.isNotEmpty && password.isNotEmpty && fullName.isNotEmpty;
    }
  }

  Future<void> signOut() async {
    if (!isDemoMode && _isSupabaseConnected) {
      try {
        await SupabaseService.instance.client.auth.signOut();
      } catch (e) {
        debugPrint('Real sign-out failed: $e');
      }
    } else {
      // Demo mode - just simulate delay
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<bool> isSignedIn() async {
    if (!isDemoMode && _isSupabaseConnected) {
      return SupabaseService.instance.client.auth.currentUser != null;
    } else {
      // In demo mode, user is always signed in
      return true;
    }
  }
}