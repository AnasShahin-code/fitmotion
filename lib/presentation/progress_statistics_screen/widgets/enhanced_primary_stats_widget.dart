import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EnhancedPrimaryStatsWidget extends StatefulWidget {
  final Map<String, dynamic> statsData;

  const EnhancedPrimaryStatsWidget({
    super.key,
    required this.statsData,
  });

  @override
  State<EnhancedPrimaryStatsWidget> createState() =>
      _EnhancedPrimaryStatsWidgetState();
}

class _EnhancedPrimaryStatsWidgetState extends State<EnhancedPrimaryStatsWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          _buildMainStatsCard(),
          SizedBox(height: 2.h),
          _buildQuickMetrics(),
        ],
      ),
    );
  }

  Widget _buildMainStatsCard() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue,
                  AppTheme.primaryBlue.withValues(alpha: 0.8),
                  AppTheme.accentTeal,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildMainMetric(),
                SizedBox(height: 4.h),
                _buildProgressIndicators(),
                SizedBox(height: 3.h),
                _buildWeeklyOverview(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainMetric() {
    return Column(
      children: [
        Text(
          'Total Workouts',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.pureWhite.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${widget.statsData['totalWorkouts'] ?? 0}',
              style: AppTheme.lightTheme.textTheme.displayLarge?.copyWith(
                color: AppTheme.pureWhite,
                fontWeight: FontWeight.w900,
                height: 1.0,
              ),
            ),
            SizedBox(width: 2.w),
            Container(
              margin: EdgeInsets.only(bottom: 1.h),
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.successGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'trending_up',
                    color: AppTheme.pureWhite,
                    size: 14,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '+${widget.statsData['workoutTrend'] ?? 0}%',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.pureWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          'This month vs last month',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.pureWhite.withValues(alpha: 0.7),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicators() {
    return Row(
      children: [
        Expanded(
          child: _buildCircularProgress(
            'Calories',
            widget.statsData['caloriesBurned'] ?? 0,
            3500,
            AppTheme.energyOrange,
            'local_fire_department',
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildCircularProgress(
            'Minutes',
            widget.statsData['activeMinutes'] ?? 0,
            2000,
            AppTheme.successGreen,
            'schedule',
          ),
        ),
      ],
    );
  }

  Widget _buildCircularProgress(
    String title,
    int current,
    int target,
    Color color,
    String iconName,
  ) {
    final percentage = (current / target).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 6,
                    backgroundColor: AppTheme.pureWhite.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation(
                        AppTheme.pureWhite.withValues(alpha: 0.2)),
                  ),
                  CircularProgressIndicator(
                    value: percentage * _progressAnimation.value,
                    strokeWidth: 6,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(color),
                    strokeCap: StrokeCap.round,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: iconName,
                        color: AppTheme.pureWhite,
                        size: 20,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${(percentage * 100).toInt()}%',
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.pureWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.pureWhite.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${_formatNumber(current)}/${_formatNumber(target)}',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.pureWhite.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeeklyOverview() {
    final weeklyData = [
      {'day': 'Mon', 'completed': true},
      {'day': 'Tue', 'completed': true},
      {'day': 'Wed', 'completed': false},
      {'day': 'Thu', 'completed': true},
      {'day': 'Fri', 'completed': true},
      {'day': 'Sat', 'completed': false},
      {'day': 'Sun', 'completed': false},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'This Week',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.pureWhite.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '4/7 Days',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.pureWhite.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weeklyData.map((day) {
            final isCompleted = day['completed'] as bool;
            return Column(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successGreen
                        : AppTheme.pureWhite.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.pureWhite.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: isCompleted
                      ? Icon(
                          Icons.check,
                          color: AppTheme.pureWhite,
                          size: 16,
                        )
                      : null,
                ),
                SizedBox(height: 1.h),
                Text(
                  day['day'] as String,
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.pureWhite.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Average Duration',
            '42 min',
            '+5 min',
            true,
            'timer',
            AppTheme.accentTeal,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildMetricCard(
            'Calories/Session',
            '287 cal',
            '+23 cal',
            true,
            'whatshot',
            AppTheme.energyOrange,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: _buildMetricCard(
            'Weekly Streak',
            '3 days',
            '0 days',
            false,
            'local_fire_department',
            AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String change,
    bool isPositive,
    String iconName,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              size: 18,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 0.5.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: isPositive ? 'trending_up' : 'trending_down',
                color:
                    isPositive ? AppTheme.successGreen : AppTheme.neutralGray,
                size: 12,
              ),
              SizedBox(width: 1.w),
              Text(
                change,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color:
                      isPositive ? AppTheme.successGreen : AppTheme.neutralGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.neutralGray,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
