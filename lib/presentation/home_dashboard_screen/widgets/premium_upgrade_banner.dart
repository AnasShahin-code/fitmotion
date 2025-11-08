import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PremiumUpgradeBanner extends StatelessWidget {
  final VoidCallback onUpgradeTap;

  const PremiumUpgradeBanner({
    Key? key,
    required this.onUpgradeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.energyOrange,
            AppTheme.energyOrange.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.energyOrange.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Unlock Premium',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.pureWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Get access to advanced workouts, GPS tracking, and more!',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.pureWhite.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: onUpgradeTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.pureWhite,
                    foregroundColor: AppTheme.energyOrange,
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Upgrade Now',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomIconWidget(
              iconName: 'star',
              color: AppTheme.pureWhite,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
