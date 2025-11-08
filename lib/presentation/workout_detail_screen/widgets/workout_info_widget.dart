import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WorkoutInfoWidget extends StatelessWidget {
  final Map<String, dynamic> workoutData;

  const WorkoutInfoWidget({
    Key? key,
    required this.workoutData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Difficulty Badge
          Row(
            children: [
              Expanded(
                child: Text(
                  workoutData['title'] as String,
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 3.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color:
                      _getDifficultyColor(workoutData['difficulty'] as String),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  workoutData['difficulty'] as String,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.pureWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Duration and Target Muscles
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                '${workoutData['duration']} min',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.neutralGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 6.w),
              CustomIconWidget(
                iconName: 'fitness_center',
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  (workoutData['targetMuscles'] as List).join(', '),
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.neutralGray,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Target Muscle Tags
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: (workoutData['targetMuscles'] as List).map((muscle) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  muscle as String,
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppTheme.successGreen;
      case 'intermediate':
        return AppTheme.warningAmber;
      case 'advanced':
        return AppTheme.errorRed;
      default:
        return AppTheme.neutralGray;
    }
  }
}
