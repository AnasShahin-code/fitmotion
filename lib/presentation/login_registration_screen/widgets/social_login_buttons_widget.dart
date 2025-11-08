import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SocialLoginButtonsWidget extends StatelessWidget {
  final VoidCallback onGoogleSignIn;
  final VoidCallback onAppleSignIn;
  final bool isLoading; // Add loading state parameter

  const SocialLoginButtonsWidget({
    Key? key,
    required this.onGoogleSignIn,
    required this.onAppleSignIn,
    this.isLoading = false, // Default to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Or continue with',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.neutralGray,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.lightTheme.colorScheme.outline,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        Row(
          children: [
            // Google Sign In Button
            Expanded(
              child: GestureDetector(
                onTap: isLoading
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onGoogleSignIn();
                      },
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: isLoading
                        ? AppTheme.surfaceLight.withValues(alpha: 0.5)
                        : AppTheme.surfaceLight,
                    border: Border.all(
                      color: AppTheme.neutralGray
                          .withValues(alpha: isLoading ? 0.2 : 0.3),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google Icon - using a simple placeholder since we can't use assets
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isLoading
                              ? Colors.red.withValues(alpha: 0.3)
                              : Colors.red,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              color: AppTheme.pureWhite,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Google',
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: isLoading
                              ? AppTheme.textDark.withValues(alpha: 0.5)
                              : AppTheme.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: 4.w),

            // Apple Sign In Button
            Expanded(
              child: GestureDetector(
                onTap: isLoading
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onAppleSignIn();
                      },
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: isLoading
                        ? AppTheme.textDark.withValues(alpha: 0.5)
                        : AppTheme.textDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Apple Icon - using a simple placeholder
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: isLoading
                              ? AppTheme.pureWhite.withValues(alpha: 0.5)
                              : AppTheme.pureWhite,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Center(
                          child: Text(
                            '',
                            style: TextStyle(
                              color: isLoading
                                  ? AppTheme.textDark.withValues(alpha: 0.5)
                                  : AppTheme.textDark,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Apple',
                        style:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: isLoading
                              ? AppTheme.pureWhite.withValues(alpha: 0.5)
                              : AppTheme.pureWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // Loading indicator for social logins
        if (isLoading) ...[
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryBlue,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                'Signing you in...',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.neutralGray,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
