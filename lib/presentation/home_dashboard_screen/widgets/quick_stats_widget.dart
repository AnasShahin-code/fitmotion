import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickStatsWidget extends StatelessWidget {
  final Map<String, dynamic> stats;

  const QuickStatsWidget({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: 'fitness_center',
              value: '${stats['totalWorkouts'] ?? 0}',
              label: 'Workouts',
              color: AppTheme.primaryBlue,
            ),
          ),
          Container(
            width: 1,
            height: 6.h,
            color: AppTheme.neutralGray.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildStatItem(
              icon: 'schedule',
              value: '${stats['totalMinutes'] ?? 0}',
              label: 'Minutes',
              color: AppTheme.energyOrange,
            ),
          ),
          Container(
            width: 1,
            height: 6.h,
            color: AppTheme.neutralGray.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildStatItem(
              icon: 'local_fire_department',
              value: '${stats['caloriesBurned'] ?? 0}',
              label: 'Calories',
              color: AppTheme.errorRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.neutralGray,
          ),
        ),
      ],
    );
  }
}
