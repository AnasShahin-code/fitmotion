import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WorkoutHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> workoutData;
  final VoidCallback onBackPressed;
  final VoidCallback onSharePressed;

  const WorkoutHeaderWidget({
    Key? key,
    required this.workoutData,
    required this.onBackPressed,
    required this.onSharePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.h,
      child: Stack(
        children: [
          // Hero Image/Video
          Container(
            width: double.infinity,
            height: 35.h,
            child: CustomImageWidget(
              imageUrl: workoutData['heroImage'] as String,
              width: double.infinity,
              height: 35.h,
              fit: BoxFit.cover,
              semanticLabel: workoutData['heroImageSemanticLabel'] as String,
            ),
          ),

          // Gradient Overlay
          Container(
            width: double.infinity,
            height: 35.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),

          // Header Controls
          Positioned(
            top: 6.h,
            left: 4.w,
            right: 4.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onBackPressed,
                  child: Container(
                    width: 12.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: AppTheme.pureWhite,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onSharePressed,
                  child: Container(
                    width: 12.w,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'share',
                        color: AppTheme.pureWhite,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Play Button Overlay
          Center(
            child: GestureDetector(
              onTap: () {
                // Handle video play
              },
              child: Container(
                width: 20.w,
                height: 10.h,
                decoration: BoxDecoration(
                  color: AppTheme.energyOrange.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'play_arrow',
                    color: AppTheme.pureWhite,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
