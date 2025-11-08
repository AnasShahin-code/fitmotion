import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AchievementBadgesWidget extends StatefulWidget {
  final List<Map<String, dynamic>> achievements;

  const AchievementBadgesWidget({
    super.key,
    required this.achievements,
  });

  @override
  State<AchievementBadgesWidget> createState() =>
      _AchievementBadgesWidgetState();
}

class _AchievementBadgesWidgetState extends State<AchievementBadgesWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => _showAllAchievements(context),
                child: Text(
                  'View All',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            height: 15.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.achievements.length,
              itemBuilder: (context, index) {
                final achievement = widget.achievements[index];
                final isUnlocked = achievement['unlocked'] as bool;
                final isNew = achievement['isNew'] as bool? ?? false;

                return GestureDetector(
                  onTap: () => _showAchievementDetails(context, achievement),
                  child: Container(
                    width: 25.w,
                    margin: EdgeInsets.only(right: 3.w),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: isNew ? _pulseAnimation.value : 1.0,
                                  child: Container(
                                    width: 20.w,
                                    height: 20.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: isUnlocked
                                          ? LinearGradient(
                                              colors: [
                                                AppTheme.energyOrange,
                                                AppTheme.warningAmber,
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : LinearGradient(
                                              colors: [
                                                AppTheme.neutralGray
                                                    .withValues(alpha: 0.3),
                                                AppTheme.neutralGray
                                                    .withValues(alpha: 0.2),
                                              ],
                                            ),
                                      boxShadow: isUnlocked
                                          ? [
                                              BoxShadow(
                                                color: AppTheme.energyOrange
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: CustomIconWidget(
                                        iconName: achievement['icon'] as String,
                                        color: isUnlocked
                                            ? AppTheme.pureWhite
                                            : AppTheme.neutralGray,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (isNew)
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.errorRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '!',
                                      style: AppTheme
                                          .lightTheme.textTheme.labelSmall
                                          ?.copyWith(
                                        color: AppTheme.pureWhite,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          achievement['title'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: isUnlocked
                                ? AppTheme.textDark
                                : AppTheme.neutralGray,
                            fontWeight:
                                isUnlocked ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAchievementDetails(
      BuildContext context, Map<String, dynamic> achievement) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(6.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: achievement['unlocked'] as bool
                        ? LinearGradient(
                            colors: [
                              AppTheme.energyOrange,
                              AppTheme.warningAmber,
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              AppTheme.neutralGray.withValues(alpha: 0.3),
                              AppTheme.neutralGray.withValues(alpha: 0.2),
                            ],
                          ),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: achievement['icon'] as String,
                      color: achievement['unlocked'] as bool
                          ? AppTheme.pureWhite
                          : AppTheme.neutralGray,
                      size: 32,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  achievement['title'] as String,
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  achievement['description'] as String,
                  textAlign: TextAlign.center,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.neutralGray,
                  ),
                ),
                if (achievement['unlocked'] as bool) ...[
                  SizedBox(height: 2.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Unlocked on ${achievement['unlockedDate']}',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 3.h),
                Row(
                  children: [
                    if (achievement['unlocked'] as bool)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _shareAchievement(achievement),
                          icon: CustomIconWidget(
                            iconName: 'share',
                            color: AppTheme.pureWhite,
                            size: 18,
                          ),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: AppTheme.pureWhite,
                          ),
                        ),
                      ),
                    if (achievement['unlocked'] as bool) SizedBox(width: 3.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAllAchievements(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 80.h,
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.neutralGray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'All Achievements',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 3.h),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 3.w,
                    mainAxisSpacing: 3.w,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: widget.achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = widget.achievements[index];
                    final isUnlocked = achievement['unlocked'] as bool;

                    return GestureDetector(
                      onTap: () =>
                          _showAchievementDetails(context, achievement),
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isUnlocked
                                ? AppTheme.energyOrange.withValues(alpha: 0.3)
                                : AppTheme.neutralGray.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 15.w,
                              height: 15.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isUnlocked
                                    ? LinearGradient(
                                        colors: [
                                          AppTheme.energyOrange,
                                          AppTheme.warningAmber,
                                        ],
                                      )
                                    : LinearGradient(
                                        colors: [
                                          AppTheme.neutralGray
                                              .withValues(alpha: 0.3),
                                          AppTheme.neutralGray
                                              .withValues(alpha: 0.2),
                                        ],
                                      ),
                              ),
                              child: Center(
                                child: CustomIconWidget(
                                  iconName: achievement['icon'] as String,
                                  color: isUnlocked
                                      ? AppTheme.pureWhite
                                      : AppTheme.neutralGray,
                                  size: 20,
                                ),
                              ),
                            ),
                            SizedBox(height: 2.w),
                            Expanded(
                              child: Text(
                                achievement['title'] as String,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: isUnlocked
                                      ? AppTheme.textDark
                                      : AppTheme.neutralGray,
                                  fontWeight: isUnlocked
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _shareAchievement(Map<String, dynamic> achievement) {
    // Implementation for sharing achievement
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${achievement['title']}" achievement!'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }
}
