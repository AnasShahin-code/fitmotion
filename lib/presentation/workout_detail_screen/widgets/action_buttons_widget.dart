import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatefulWidget {
  final VoidCallback onStartWorkout;
  final VoidCallback onAddToFavorites;
  final VoidCallback onShareWorkout;
  final bool isFavorite;
  final bool isPremium;
  final bool isUserPremium;

  const ActionButtonsWidget({
    Key? key,
    required this.onStartWorkout,
    required this.onAddToFavorites,
    required this.onShareWorkout,
    required this.isFavorite,
    required this.isPremium,
    required this.isUserPremium,
  }) : super(key: key);

  @override
  State<ActionButtonsWidget> createState() => _ActionButtonsWidgetState();
}

class _ActionButtonsWidgetState extends State<ActionButtonsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Secondary Actions Row
          Row(
            children: [
              // Favorite Button
              Expanded(
                child: GestureDetector(
                  onTap: widget.onAddToFavorites,
                  child: Container(
                    height: 7.h,
                    decoration: BoxDecoration(
                      color: widget.isFavorite
                          ? AppTheme.errorRed.withValues(alpha: 0.1)
                          : AppTheme.neutralGray.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.isFavorite
                            ? AppTheme.errorRed
                            : AppTheme.neutralGray.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: widget.isFavorite
                              ? 'favorite'
                              : 'favorite_border',
                          color: widget.isFavorite
                              ? AppTheme.errorRed
                              : AppTheme.neutralGray,
                          size: 24,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          widget.isFavorite ? 'Favorited' : 'Add to Favorites',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: widget.isFavorite
                                ? AppTheme.errorRed
                                : AppTheme.neutralGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 3.w),

              // Share Button
              GestureDetector(
                onTap: widget.onShareWorkout,
                child: Container(
                  width: 15.w,
                  height: 7.h,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'share',
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Primary Start Button
          GestureDetector(
            onTap: widget.isPremium && !widget.isUserPremium
                ? _showPremiumDialog
                : widget.onStartWorkout,
            child: Container(
              width: double.infinity,
              height: 8.h,
              decoration: BoxDecoration(
                gradient: widget.isPremium && !widget.isUserPremium
                    ? LinearGradient(
                        colors: [
                          AppTheme.neutralGray,
                          AppTheme.neutralGray.withValues(alpha: 0.8),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          AppTheme.primaryBlue,
                          AppTheme.energyOrange,
                        ],
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.isPremium && !widget.isUserPremium
                        ? AppTheme.neutralGray.withValues(alpha: 0.3)
                        : AppTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isPremium && !widget.isUserPremium) ...[
                          CustomIconWidget(
                            iconName: 'lock',
                            color: AppTheme.pureWhite,
                            size: 24,
                          ),
                          SizedBox(width: 2.w),
                        ],
                        CustomIconWidget(
                          iconName: 'play_arrow',
                          color: AppTheme.pureWhite,
                          size: 28,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          widget.isPremium && !widget.isUserPremium
                              ? 'Upgrade to Start'
                              : 'Start Workout',
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            color: AppTheme.pureWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Premium Badge
                  if (widget.isPremium && !widget.isUserPremium)
                    Positioned(
                      top: 1.h,
                      right: 4.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.warningAmber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'PREMIUM',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.pureWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'star',
                color: AppTheme.warningAmber,
                size: 28,
              ),
              SizedBox(width: 2.w),
              Text(
                'Premium Required',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'This workout is part of our premium collection. Upgrade to access advanced workouts, GPS tracking, nutrition tips, and ad-free experience.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Maybe Later',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.neutralGray,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to subscription screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Upgrade Now',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.pureWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
