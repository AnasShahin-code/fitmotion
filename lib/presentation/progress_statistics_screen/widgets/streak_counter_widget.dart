import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StreakCounterWidget extends StatefulWidget {
  final Map<String, dynamic> streakData;

  const StreakCounterWidget({
    super.key,
    required this.streakData,
  });

  @override
  State<StreakCounterWidget> createState() => _StreakCounterWidgetState();
}

class _StreakCounterWidgetState extends State<StreakCounterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStreak = widget.streakData['currentStreak'] as int? ?? 0;
    final longestStreak = widget.streakData['longestStreak'] as int? ?? 0;
    final isActive = widget.streakData['isActive'] as bool? ?? false;
    final lastWorkoutDate =
        widget.streakData['lastWorkoutDate'] as String? ?? '';

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isActive
                      ? [
                          AppTheme.successGreen,
                          AppTheme.successGreen.withValues(alpha: 0.8),
                        ]
                      : [
                          AppTheme.neutralGray.withValues(alpha: 0.3),
                          AppTheme.neutralGray.withValues(alpha: 0.2),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isActive
                        ? AppTheme.successGreen.withValues(alpha: 0.3)
                        : AppTheme.shadowLight,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Workout Streak',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color:
                              isActive ? AppTheme.pureWhite : AppTheme.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.pureWhite.withValues(alpha: 0.2)
                              : AppTheme.energyOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: isActive
                                  ? 'local_fire_department'
                                  : 'schedule',
                              color: isActive
                                  ? AppTheme.pureWhite
                                  : AppTheme.energyOrange,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              isActive ? 'Active' : 'Inactive',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                color: isActive
                                    ? AppTheme.pureWhite
                                    : AppTheme.energyOrange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStreakItem(
                          'Current Streak',
                          '$currentStreak',
                          'days',
                          'local_fire_department',
                          isActive,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 10.h,
                        color: isActive
                            ? AppTheme.pureWhite.withValues(alpha: 0.3)
                            : AppTheme.neutralGray.withValues(alpha: 0.3),
                      ),
                      Expanded(
                        child: _buildStreakItem(
                          'Longest Streak',
                          '$longestStreak',
                          'days',
                          'emoji_events',
                          isActive,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.pureWhite.withValues(alpha: 0.1)
                          : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _getMotivationalMessage(currentStreak, isActive),
                          textAlign: TextAlign.center,
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: isActive
                                ? AppTheme.pureWhite
                                : AppTheme.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (lastWorkoutDate.isNotEmpty) ...[
                          SizedBox(height: 1.h),
                          Text(
                            'Last workout: $lastWorkoutDate',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: isActive
                                  ? AppTheme.pureWhite.withValues(alpha: 0.8)
                                  : AppTheme.neutralGray,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  _buildStreakProgress(currentStreak, longestStreak, isActive),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStreakItem(
    String title,
    String value,
    String unit,
    String iconName,
    bool isActive,
  ) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: isActive ? AppTheme.pureWhite : AppTheme.energyOrange,
          size: 24,
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
            color: isActive ? AppTheme.pureWhite : AppTheme.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          unit,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: isActive
                ? AppTheme.pureWhite.withValues(alpha: 0.8)
                : AppTheme.neutralGray,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: isActive
                ? AppTheme.pureWhite.withValues(alpha: 0.9)
                : AppTheme.textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakProgress(int current, int longest, bool isActive) {
    final progress = longest > 0 ? (current / longest).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress to Personal Best',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isActive
                    ? AppTheme.pureWhite.withValues(alpha: 0.8)
                    : AppTheme.neutralGray,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isActive ? AppTheme.pureWhite : AppTheme.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          height: 1.h,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.pureWhite.withValues(alpha: 0.3)
                : AppTheme.neutralGray.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: isActive ? AppTheme.pureWhite : AppTheme.energyOrange,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getMotivationalMessage(int streak, bool isActive) {
    if (!isActive) {
      return "Ready to start a new streak? Every journey begins with a single step!";
    }

    if (streak == 0) {
      return "Start your fitness journey today! Consistency is key to success.";
    } else if (streak < 7) {
      return "Great start! Keep going to build a strong habit.";
    } else if (streak < 30) {
      return "Amazing! You're building incredible momentum.";
    } else if (streak < 100) {
      return "Outstanding dedication! You're a fitness champion.";
    } else {
      return "Legendary streak! You're an inspiration to others.";
    }
  }
}
