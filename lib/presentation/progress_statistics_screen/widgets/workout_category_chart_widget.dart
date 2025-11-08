import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WorkoutCategoryChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> categoryData;

  const WorkoutCategoryChartWidget({
    super.key,
    required this.categoryData,
  });

  @override
  State<WorkoutCategoryChartWidget> createState() =>
      _WorkoutCategoryChartWidgetState();
}

class _WorkoutCategoryChartWidgetState extends State<WorkoutCategoryChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int touchedIndex = -1;

  final List<Color> categoryColors = [
    AppTheme.primaryBlue,
    AppTheme.energyOrange,
    AppTheme.accentTeal,
    AppTheme.successGreen,
    AppTheme.warningAmber,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
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
          Text(
            'Workout Categories',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 25.h,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  touchedIndex = -1;
                                  return;
                                }
                                touchedIndex = pieTouchResponse
                                    .touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 8.w,
                          sections: _buildPieChartSections(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.categoryData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    final color = categoryColors[index % categoryColors.length];

                    return Container(
                      margin: EdgeInsets.only(bottom: 2.h),
                      child: Row(
                        children: [
                          Container(
                            width: 4.w,
                            height: 4.w,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category['name'] as String,
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.textDark,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${category['percentage']}%',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.neutralGray,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Sessions',
                  '${_getTotalSessions()}',
                  'fitness_center',
                ),
                Container(
                  width: 1,
                  height: 6.h,
                  color: AppTheme.neutralGray.withValues(alpha: 0.3),
                ),
                _buildStatItem(
                  'Avg Duration',
                  '${_getAverageDuration()} min',
                  'schedule',
                ),
                Container(
                  width: 1,
                  height: 6.h,
                  color: AppTheme.neutralGray.withValues(alpha: 0.3),
                ),
                _buildStatItem(
                  'Most Active',
                  _getMostActiveCategory(),
                  'trending_up',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    return widget.categoryData.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 12.w : 10.w;
      final color = categoryColors[index % categoryColors.length];

      return PieChartSectionData(
        color: color,
        value: (category['percentage'] as num).toDouble() * _animation.value,
        title: isTouched ? '${category['percentage']}%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppTheme.pureWhite,
        ),
        badgeWidget: isTouched
            ? Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  category['name'] as String,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    }).toList();
  }

  Widget _buildStatItem(String title, String value, String iconName) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.primaryBlue,
          size: 20,
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.neutralGray,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  int _getTotalSessions() {
    return widget.categoryData
        .fold(0, (sum, category) => sum + (category['sessions'] as int? ?? 0));
  }

  int _getAverageDuration() {
    if (widget.categoryData.isEmpty) return 0;
    final totalDuration = widget.categoryData
        .fold(0, (sum, category) => sum + (category['duration'] as int? ?? 0));
    return (totalDuration / widget.categoryData.length).round();
  }

  String _getMostActiveCategory() {
    if (widget.categoryData.isEmpty) return 'N/A';
    final mostActive = widget.categoryData.reduce(
        (a, b) => (a['percentage'] as num) > (b['percentage'] as num) ? a : b);
    return mostActive['name'] as String;
  }
}
