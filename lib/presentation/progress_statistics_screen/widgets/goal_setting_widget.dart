import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GoalSettingWidget extends StatefulWidget {
  final Map<String, dynamic> goalData;
  final Function(Map<String, dynamic>) onGoalUpdated;

  const GoalSettingWidget({
    super.key,
    required this.goalData,
    required this.onGoalUpdated,
  });

  @override
  State<GoalSettingWidget> createState() => _GoalSettingWidgetState();
}

class _GoalSettingWidgetState extends State<GoalSettingWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _celebrationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _celebrationAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );
    _celebrationAnimation = CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    );

    _progressController.forward();

    // Trigger celebration if goal is completed
    final progress = _calculateProgress();
    if (progress >= 1.0) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _celebrationController.forward();
      });
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weeklyGoal = widget.goalData['weeklyWorkouts'] as int? ?? 0;
    final currentProgress = widget.goalData['currentProgress'] as int? ?? 0;
    final progress = _calculateProgress();
    final isCompleted = progress >= 1.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Goals',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => _showGoalEditor(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'edit',
                        color: AppTheme.primaryBlue,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Edit',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Stack(
            children: [
              _buildGoalProgress(progress, isCompleted),
              if (isCompleted)
                AnimatedBuilder(
                  animation: _celebrationAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _celebrationAnimation.value,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.successGreen
                                    .withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CustomIconWidget(
                            iconName: 'celebration',
                            color: AppTheme.pureWhite,
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildGoalStat(
                'Current',
                '$currentProgress',
                'workouts',
                'fitness_center',
                AppTheme.primaryBlue,
              ),
              _buildGoalStat(
                'Target',
                '$weeklyGoal',
                'workouts',
                'flag',
                AppTheme.energyOrange,
              ),
              _buildGoalStat(
                'Remaining',
                '${(weeklyGoal - currentProgress).clamp(0, weeklyGoal)}',
                'workouts',
                'schedule',
                AppTheme.accentTeal,
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppTheme.successGreen.withValues(alpha: 0.1)
                  : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: isCompleted
                  ? Border.all(
                      color: AppTheme.successGreen.withValues(alpha: 0.3))
                  : null,
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: isCompleted ? 'check_circle' : 'info',
                  color: isCompleted
                      ? AppTheme.successGreen
                      : AppTheme.primaryBlue,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    _getMotivationalMessage(
                        progress, currentProgress, weeklyGoal),
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: isCompleted
                          ? AppTheme.successGreen
                          : AppTheme.textDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isCompleted) ...[
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startWorkout(context),
                icon: CustomIconWidget(
                  iconName: 'play_arrow',
                  color: AppTheme.pureWhite,
                  size: 20,
                ),
                label: const Text('Start Workout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: AppTheme.pureWhite,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalProgress(double progress, bool isCompleted) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weekly Progress',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color:
                    isCompleted ? AppTheme.successGreen : AppTheme.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              height: 2.h,
              decoration: BoxDecoration(
                color: AppTheme.neutralGray.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor:
                    (progress * _progressAnimation.value).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCompleted
                          ? [
                              AppTheme.successGreen,
                              AppTheme.successGreen.withValues(alpha: 0.8)
                            ]
                          : [AppTheme.primaryBlue, AppTheme.accentTeal],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGoalStat(
    String title,
    String value,
    String unit,
    String iconName,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 20,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          unit,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.neutralGray,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showGoalEditor(BuildContext context) {
    int newGoal = widget.goalData['weeklyWorkouts'] as int? ?? 3;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: EdgeInsets.all(6.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Set Weekly Goal',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'How many workouts do you want to complete this week?',
                      textAlign: TextAlign.center,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.neutralGray,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: newGoal > 1
                              ? () => setState(() => newGoal--)
                              : null,
                          icon: CustomIconWidget(
                            iconName: 'remove_circle',
                            color: newGoal > 1
                                ? AppTheme.primaryBlue
                                : AppTheme.neutralGray,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.primaryBlue),
                          ),
                          child: Text(
                            '$newGoal',
                            style: AppTheme.lightTheme.textTheme.headlineMedium
                                ?.copyWith(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        IconButton(
                          onPressed: newGoal < 14
                              ? () => setState(() => newGoal++)
                              : null,
                          icon: CustomIconWidget(
                            iconName: 'add_circle',
                            color: newGoal < 14
                                ? AppTheme.primaryBlue
                                : AppTheme.neutralGray,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final updatedGoal =
                                  Map<String, dynamic>.from(widget.goalData);
                              updatedGoal['weeklyWorkouts'] = newGoal;
                              widget.onGoalUpdated(updatedGoal);
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Weekly goal updated to $newGoal workouts!'),
                                  backgroundColor: AppTheme.successGreen,
                                ),
                              );
                            },
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _startWorkout(BuildContext context) {
    Navigator.pushNamed(context, '/workout-detail-screen');
  }

  double _calculateProgress() {
    final weeklyGoal = widget.goalData['weeklyWorkouts'] as int? ?? 1;
    final currentProgress = widget.goalData['currentProgress'] as int? ?? 0;
    return weeklyGoal > 0
        ? (currentProgress / weeklyGoal).clamp(0.0, 1.0)
        : 0.0;
  }

  String _getMotivationalMessage(double progress, int current, int target) {
    if (progress >= 1.0) {
      return "🎉 Congratulations! You've achieved your weekly goal!";
    } else if (progress >= 0.8) {
      return "Almost there! Just ${target - current} more workout${target - current == 1 ? '' : 's'} to reach your goal.";
    } else if (progress >= 0.5) {
      return "Great progress! You're halfway to your weekly goal.";
    } else if (progress > 0) {
      return "Good start! Keep going to reach your weekly target.";
    } else {
      return "Ready to start your week strong? Let's begin with your first workout!";
    }
  }
}
