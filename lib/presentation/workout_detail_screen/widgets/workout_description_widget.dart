import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WorkoutDescriptionWidget extends StatefulWidget {
  final Map<String, dynamic> workoutData;

  const WorkoutDescriptionWidget({
    Key? key,
    required this.workoutData,
  }) : super(key: key);

  @override
  State<WorkoutDescriptionWidget> createState() =>
      _WorkoutDescriptionWidgetState();
}

class _WorkoutDescriptionWidgetState extends State<WorkoutDescriptionWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final description = widget.workoutData['description'] as String;
    final maxLines = _isExpanded ? null : 3;

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 2.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Text(
              description,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.neutralGray,
                height: 1.5,
              ),
              maxLines: maxLines,
              overflow:
                  _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 1.h),
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              children: [
                Text(
                  _isExpanded ? 'Read Less' : 'Read More',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 1.w),
                CustomIconWidget(
                  iconName:
                      _isExpanded ? 'keyboard_arrow_up' : 'keyboard_arrow_down',
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
