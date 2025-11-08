import 'package:fitmotion/presentation/workout_tracking_screen/workout_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/exercise_list_widget.dart';
import './widgets/preparation_controls_widget.dart';
import './widgets/workout_description_widget.dart';
import './widgets/workout_header_widget.dart';
import './widgets/workout_info_widget.dart';

class WorkoutDetailScreen extends StatefulWidget {
  const WorkoutDetailScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  bool _isFavorite = false;
  bool _isUserPremium = false; // Mock user premium status
  int _selectedTimer = 30;
  int _selectedReps = 12;
  List<String> _selectedEquipment = [];

  // Mock workout data
  final Map<String, dynamic> _workoutData = {
    "id": 1,
    "title": "Full Body HIIT Blast",
    "type": "hiit", // Added workout type for tracking
    "difficulty": "Intermediate",
    "duration": 45,
    "targetMuscles": ["Full Body", "Core", "Cardio"],
    "description":
        """This high-intensity interval training workout targets your entire body with a combination of strength and cardio exercises. Perfect for burning calories and building lean muscle mass. The workout includes compound movements that engage multiple muscle groups simultaneously, maximizing your time and effort. Each exercise is designed to push your limits while maintaining proper form and technique. Suitable for intermediate to advanced fitness levels with modifications available for beginners.""",
    "heroImage":
        "https://images.pexels.com/photos/416778/pexels-photo-416778.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "heroImageSemanticLabel":
        "Athletic woman in black workout clothes performing a plank exercise on a yoga mat in a bright modern gym with large windows",
    "isPremium": false,
    "defaultTimer": 30,
    "defaultReps": 12,
    "requiredEquipment": ["Dumbbells", "Yoga Mat"],
    "equipment": [
      {"name": "Dumbbells (5-15 lbs)", "required": true},
      {"name": "Yoga Mat", "required": true},
      {"name": "Water Bottle", "required": false},
      {"name": "Towel", "required": false}
    ]
  };

  final List<Map<String, dynamic>> _exercises = [
    {
      "id": 1,
      "name": "Burpees",
      "reps": "12",
      "restTime": "30",
      "thumbnail":
          "https://images.unsplash.com/photo-1518310952931-b1de897abd40",
      "thumbnailSemanticLabel":
          "Fit woman in athletic wear performing a burpee exercise on a wooden floor in a bright fitness studio"
    },
    {
      "id": 2,
      "name": "Mountain Climbers",
      "reps": "20",
      "restTime": "20",
      "thumbnail":
          "https://images.unsplash.com/photo-1526582722295-6438d8ef8a42",
      "thumbnailSemanticLabel":
          "Athletic person in plank position performing mountain climber exercise on a blue yoga mat"
    },
    {
      "id": 3,
      "name": "Dumbbell Thrusters",
      "reps": "15",
      "restTime": "45",
      "thumbnail":
          "https://images.unsplash.com/photo-1639653819798-5948f134d3d0",
      "thumbnailSemanticLabel":
          "Strong woman holding dumbbells overhead in a squat thrust position in a modern gym setting"
    },
    {
      "id": 4,
      "name": "Jump Squats",
      "reps": "15",
      "restTime": "30",
      "thumbnail":
          "https://images.unsplash.com/photo-1634788699152-8456796c14eb",
      "thumbnailSemanticLabel":
          "Energetic woman mid-jump during a squat jump exercise wearing black athletic clothing"
    },
    {
      "id": 5,
      "name": "Push-up to T",
      "reps": "10",
      "restTime": "30",
      "thumbnail":
          "https://images.unsplash.com/photo-1617431575816-62616971b345",
      "thumbnailSemanticLabel":
          "Fit person performing a push-up with one arm extended in T position on a yoga mat"
    },
    {
      "id": 6,
      "name": "High Knees",
      "reps": "30",
      "restTime": "20",
      "thumbnail":
          "https://images.unsplash.com/photo-1706550632130-333d8ec921ff",
      "thumbnailSemanticLabel":
          "Active woman performing high knee exercise with arms pumping in a bright fitness studio"
    }
  ];

  @override
  void initState() {
    super.initState();
    _selectedEquipment =
        List<String>.from(_workoutData['requiredEquipment'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workout Header with Hero Image
              WorkoutHeaderWidget(
                workoutData: _workoutData,
                onBackPressed: _handleBackPressed,
                onSharePressed: _handleSharePressed,
              ),

              // Workout Information
              WorkoutInfoWidget(
                workoutData: _workoutData,
              ),

              // Divider
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                height: 1,
                color: AppTheme.neutralGray.withValues(alpha: 0.2),
              ),

              SizedBox(height: 2.h),

              // Workout Description
              WorkoutDescriptionWidget(
                workoutData: _workoutData,
              ),

              // Divider
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                height: 1,
                color: AppTheme.neutralGray.withValues(alpha: 0.2),
              ),

              SizedBox(height: 2.h),

              // Exercise List
              ExerciseListWidget(
                exercises: _exercises,
              ),

              SizedBox(height: 3.h),

              // Divider
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                height: 1,
                color: AppTheme.neutralGray.withValues(alpha: 0.2),
              ),

              SizedBox(height: 2.h),

              // Preparation Controls
              PreparationControlsWidget(
                workoutData: _workoutData,
                onTimerChanged: _handleTimerChanged,
                onRepsChanged: _handleRepsChanged,
                onEquipmentChanged: _handleEquipmentChanged,
              ),

              SizedBox(height: 3.h),

              // Action Buttons
              ActionButtonsWidget(
                onStartWorkout: _handleStartWorkout,
                onAddToFavorites: _handleAddToFavorites,
                onShareWorkout: _handleSharePressed,
                isFavorite: _isFavorite,
                isPremium: _workoutData['isPremium'] as bool,
                isUserPremium: _isUserPremium,
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBackPressed() {
    Navigator.of(context).pop();
  }

  void _handleSharePressed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Workout shared successfully!',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.pureWhite,
          ),
        ),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _handleStartWorkout() {
    // Check if premium workout and user not premium
    if (_workoutData['isPremium'] as bool && !_isUserPremium) {
      _showPremiumRequiredDialog();
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'fitness_center',
                color: AppTheme.energyOrange,
                size: 28,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Ready to Start?',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your workout is configured with:',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'timer',
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Rest Timer: ${_selectedTimer}s',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'repeat',
                    color: AppTheme.energyOrange,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Default Reps: $_selectedReps',
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
              if (_selectedEquipment.isNotEmpty) ...[
                SizedBox(height: 1.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: AppTheme.successGreen,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Equipment Ready: ${_selectedEquipment.join(', ')}',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.neutralGray,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                
                // Navigate to WorkoutTrackingScreen with workout data
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WorkoutTrackingScreen(
                      category: {
                        'name': _workoutData['title'],
                        'type': _workoutData['type'],
                        'exercises': _exercises,
                        'restTimer': _selectedTimer,
                        'defaultReps': _selectedReps,
                        'equipment': _selectedEquipment,
                      },
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.energyOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              ),
              child: Text(
                'Let\'s Go!',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.pureWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPremiumRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.lock,
                color: AppTheme.energyOrange,
                size: 28,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Premium Required',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'This workout requires a premium subscription. Upgrade now to unlock all premium workouts and features!',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Maybe Later',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.neutralGray,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Navigate to premium subscription screen
                // Navigator.push(context, MaterialPageRoute(builder: (_) => PremiumScreen()));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Premium subscription coming soon!'),
                    backgroundColor: AppTheme.energyOrange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.energyOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Upgrade',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.pureWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleAddToFavorites() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Added to favorites!' : 'Removed from favorites',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.pureWhite,
          ),
        ),
        backgroundColor:
            _isFavorite ? AppTheme.successGreen : AppTheme.neutralGray,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _handleTimerChanged(int newTimer) {
    setState(() {
      _selectedTimer = newTimer;
    });
  }

  void _handleRepsChanged(int newReps) {
    setState(() {
      _selectedReps = newReps;
    });
  }

  void _handleEquipmentChanged(List<String> newEquipment) {
    setState(() {
      _selectedEquipment = newEquipment;
    });
  }
}
