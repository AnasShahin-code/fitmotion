import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExerciseListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;

  const ExerciseListWidget({
    Key? key,
    required this.exercises,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exercises (${exercises.length})',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exercises.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return _buildExerciseCard(exercise, index + 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, int index) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              // Handle modification options
            },
            backgroundColor: AppTheme.energyOrange,
            foregroundColor: AppTheme.pureWhite,
            icon: Icons.tune,
            label: 'Modify',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.neutralGray.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Exercise Number
            Container(
              width: 12.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  index.toString(),
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.pureWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(width: 4.w),

            // Exercise Thumbnail
            Container(
              width: 16.w,
              height: 8.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomImageWidget(
                imageUrl: exercise['thumbnail'] as String,
                width: 16.w,
                height: 8.h,
                fit: BoxFit.cover,
                semanticLabel: exercise['thumbnailSemanticLabel'] as String,
              ),
            ),

            SizedBox(width: 4.w),

            // Exercise Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise['name'] as String,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'repeat',
                        color: AppTheme.neutralGray,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${exercise['reps']} reps',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.neutralGray,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      CustomIconWidget(
                        iconName: 'timer',
                        color: AppTheme.neutralGray,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${exercise['restTime']}s rest',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.neutralGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Play Button
            GestureDetector(
              onTap: () {
                // Handle exercise preview
              },
              child: Container(
                width: 10.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'play_arrow',
                    color: AppTheme.primaryBlue,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
