import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PrimaryStatsCardWidget extends StatelessWidget {
  final Map<String, dynamic> statsData;

  const PrimaryStatsCardWidget({
    super.key,
    required this.statsData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Workouts',
                  '${statsData['totalWorkouts'] ?? 0}',
                  '${statsData['workoutTrend'] ?? '+0'}%',
                  statsData['workoutTrend'] != null &&
                      statsData['workoutTrend'] > 0,
                  'fitness_center',
                ),
              ),
              Container(
                width: 1,
                height: 8.h,
                color: AppTheme.pureWhite.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Calories Burned',
                  '${statsData['caloriesBurned'] ?? 0}',
                  '${statsData['caloriesTrend'] ?? '+0'}%',
                  statsData['caloriesTrend'] != null &&
                      statsData['caloriesTrend'] > 0,
                  'local_fire_department',
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Container(
            height: 1,
            color: AppTheme.pureWhite.withValues(alpha: 0.3),
          ),
          SizedBox(height: 3.h),
          _buildStatItem(
            'Active Minutes',
            '${statsData['activeMinutes'] ?? 0}',
            '${statsData['minutesTrend'] ?? '+0'}%',
            statsData['minutesTrend'] != null && statsData['minutesTrend'] > 0,
            'schedule',
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    String trend,
    bool isPositive,
    String iconName, {
    bool isFullWidth = false,
  }) {
    return Column(
      crossAxisAlignment:
          isFullWidth ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              isFullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: AppTheme.pureWhite.withValues(alpha: 0.8),
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.pureWhite.withValues(alpha: 0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.pureWhite,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 0.5.h),
        Row(
          mainAxisAlignment:
              isFullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            CustomIconWidget(
              iconName: isPositive ? 'trending_up' : 'trending_down',
              color: isPositive ? AppTheme.successGreen : AppTheme.errorRed,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Text(
              trend,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isPositive ? AppTheme.successGreen : AppTheme.errorRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
