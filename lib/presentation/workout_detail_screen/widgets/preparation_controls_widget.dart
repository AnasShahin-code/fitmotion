import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PreparationControlsWidget extends StatefulWidget {
  final Map<String, dynamic> workoutData;
  final Function(int) onTimerChanged;
  final Function(int) onRepsChanged;
  final Function(List<String>) onEquipmentChanged;

  const PreparationControlsWidget({
    Key? key,
    required this.workoutData,
    required this.onTimerChanged,
    required this.onRepsChanged,
    required this.onEquipmentChanged,
  }) : super(key: key);

  @override
  State<PreparationControlsWidget> createState() =>
      _PreparationControlsWidgetState();
}

class _PreparationControlsWidgetState extends State<PreparationControlsWidget> {
  int _timerMinutes = 30;
  int _repsCount = 12;
  List<String> _selectedEquipment = [];

  @override
  void initState() {
    super.initState();
    _timerMinutes = widget.workoutData['defaultTimer'] ?? 30;
    _repsCount = widget.workoutData['defaultReps'] ?? 12;
    _selectedEquipment =
        List<String>.from(widget.workoutData['requiredEquipment'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preparation',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),

          SizedBox(height: 3.h),

          // Timer Settings
          _buildTimerSettings(),

          SizedBox(height: 3.h),

          // Reps Counter
          _buildRepsCounter(),

          SizedBox(height: 3.h),

          // Equipment Checklist
          _buildEquipmentChecklist(),
        ],
      ),
    );
  }

  Widget _buildTimerSettings() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.neutralGray.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'timer',
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Rest Timer',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (_timerMinutes > 15) {
                    setState(() {
                      _timerMinutes -= 15;
                    });
                    widget.onTimerChanged(_timerMinutes);
                  }
                },
                child: Container(
                  width: 12.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'remove',
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_timerMinutes}s',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.pureWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_timerMinutes < 120) {
                    setState(() {
                      _timerMinutes += 15;
                    });
                    widget.onTimerChanged(_timerMinutes);
                  }
                },
                child: Container(
                  width: 12.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'add',
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRepsCounter() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.neutralGray.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'repeat',
                color: AppTheme.energyOrange,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Default Reps',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (_repsCount > 5) {
                    setState(() {
                      _repsCount -= 1;
                    });
                    widget.onRepsChanged(_repsCount);
                  }
                },
                child: Container(
                  width: 12.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: AppTheme.energyOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'remove',
                      color: AppTheme.energyOrange,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.energyOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_repsCount',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.pureWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_repsCount < 30) {
                    setState(() {
                      _repsCount += 1;
                    });
                    widget.onRepsChanged(_repsCount);
                  }
                },
                child: Container(
                  width: 12.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: AppTheme.energyOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'add',
                      color: AppTheme.energyOrange,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentChecklist() {
    final equipment =
        widget.workoutData['equipment'] as List<Map<String, dynamic>>? ?? [];

    if (equipment.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.neutralGray.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'fitness_center',
                color: AppTheme.accentTeal,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Equipment Checklist',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...equipment.map((item) {
            final isSelected =
                _selectedEquipment.contains(item['name'] as String);
            return Padding(
              padding: EdgeInsets.only(bottom: 1.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedEquipment.remove(item['name'] as String);
                        } else {
                          _selectedEquipment.add(item['name'] as String);
                        }
                      });
                      widget.onEquipmentChanged(_selectedEquipment);
                    },
                    child: Container(
                      width: 6.w,
                      height: 3.h,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.accentTeal
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.accentTeal
                              : AppTheme.neutralGray,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: isSelected
                          ? Center(
                              child: CustomIconWidget(
                                iconName: 'check',
                                color: AppTheme.pureWhite,
                                size: 16,
                              ),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      item['name'] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textDark,
                        decoration:
                            isSelected ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
