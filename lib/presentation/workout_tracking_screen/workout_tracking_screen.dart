import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/tracking_service.dart';
import '../../theme/app_theme.dart';

class WorkoutTrackingScreen extends StatefulWidget {
  final Map<String, dynamic>? category;

  const WorkoutTrackingScreen({
    Key? key,
    this.category,
  }) : super(key: key);

  @override
  State<WorkoutTrackingScreen> createState() => _WorkoutTrackingScreenState();
}

class _WorkoutTrackingScreenState extends State<WorkoutTrackingScreen> {
  final TrackingService _tracking = TrackingService();
  Map<String, dynamic>? category;

  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  bool _isPaused = false;

  // Real-time stats
  int _currentSteps = 0;
  double _currentDistance = 0.0;
  double _currentPace = 0.0;
  int _estimatedCalories = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        category = args;
        setState(() {});
      }
      _startTracking();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTracking() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && _tracking.isTracking) {
        setState(() {
          _elapsedTime = _elapsedTime + const Duration(seconds: 1);
          _currentSteps = _tracking.currentSteps;
          _currentDistance = _tracking.currentDistance;

          // Calculate pace (minutes per km)
          if (_currentDistance > 0 && _elapsedTime.inMinutes > 0) {
            final kmDistance = _currentDistance / 1000;
            _currentPace = _elapsedTime.inMinutes / kmDistance;
          }

          // Estimate calories (simple calculation)
          final minutes = _elapsedTime.inMinutes;
          if (minutes > 0) {
            _estimatedCalories = _calculateEstimatedCalories(minutes);
          }
        });
      }
    });
  }

  int _calculateEstimatedCalories(int minutes) {
    // Simple calorie calculation based on workout type
    final Map<String, double> metValues = {
      'running': 8.0,
      'walking': 3.8,
      'strength': 3.5,
      'general': 4.0,
    };

    final workoutType = category?['type'] ?? 'general';
    final met = metValues[workoutType.toLowerCase()] ?? 4.0;
    const weight = 70.0; // Default weight - would come from user profile

    // Calories = MET × 3.5 × weight(kg) / 200 × minutes
    return (met * 3.5 * weight / 200 * minutes).round();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String _formatPace(double pace) {
    if (pace == 0 || pace.isInfinite || pace.isNaN) return '--:--';
    final minutes = pace.floor();
    final seconds = ((pace - minutes) * 60).round();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)}km';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(category?['name'] ?? 'Workout'),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => _showExitDialog(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              // Timer Display
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Workout Time',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.neutralGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      _formatDuration(_elapsedTime),
                      style:
                          AppTheme.lightTheme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4.h),

              // Stats Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 4.w,
                  mainAxisSpacing: 3.h,
                  children: [
                    _buildStatCard(
                      'Steps',
                      _currentSteps.toString(),
                      Icons.directions_walk,
                      AppTheme.energyOrange,
                    ),
                    _buildStatCard(
                      'Distance',
                      _formatDistance(_currentDistance),
                      Icons.straighten,
                      AppTheme.accentTeal,
                    ),
                    _buildStatCard(
                      'Pace',
                      '${_formatPace(_currentPace)}/km',
                      Icons.speed,
                      AppTheme.primaryBlue,
                    ),
                    _buildStatCard(
                      'Calories',
                      _estimatedCalories.toString(),
                      Icons.local_fire_department,
                      AppTheme.errorRed,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 4.h),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pause/Resume Button
                  SizedBox(
                    width: 35.w,
                    height: 6.h,
                    child: ElevatedButton.icon(
                      onPressed: _togglePause,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPaused
                            ? AppTheme.successGreen
                            : AppTheme.energyOrange,
                        foregroundColor: AppTheme.pureWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                      label: Text(_isPaused ? 'Resume' : 'Pause'),
                    ),
                  ),

                  // End Workout Button
                  SizedBox(
                    width: 35.w,
                    height: 6.h,
                    child: ElevatedButton.icon(
                      onPressed: _endWorkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed,
                        foregroundColor: AppTheme.pureWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(Icons.stop),
                      label: Text('End'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.neutralGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isPaused ? 'Workout paused' : 'Workout resumed'),
        backgroundColor:
            _isPaused ? AppTheme.energyOrange : AppTheme.successGreen,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _endWorkout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('End Workout'),
        content: Text('Are you sure you want to end this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _finishWorkout();
            },
            child: Text(
              'End Workout',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishWorkout() async {
    try {
      _timer?.cancel();

      final session = await _tracking.endWorkout();

      if (session != null && mounted) {
        // Show workout summary
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Workout Complete!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Duration: ${_formatDuration(_elapsedTime)}'),
                Text('Steps: ${_currentSteps}'),
                Text('Distance: ${_formatDistance(_currentDistance)}'),
                Text('Calories: ${session.caloriesBurned?.round() ?? _estimatedCalories}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to home
                },
                child: Text('Done'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to home
                  Navigator.pushNamed(context, '/progress-statistics-screen');
                },
                child: Text('View Stats'),
              ),
            ],
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving workout'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Finish workout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error ending workout'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit Workout'),
        content: Text('Your workout progress will be lost. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            child: Text(
              'Exit',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}