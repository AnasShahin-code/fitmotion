import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/database_service.dart';

class PermissionsConsentScreen extends StatefulWidget {
  const PermissionsConsentScreen({super.key});

  @override
  State<PermissionsConsentScreen> createState() =>
      _PermissionsConsentScreenState();
}

class _PermissionsConsentScreenState extends State<PermissionsConsentScreen> {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4.h),

              // Header
              Text(
                'Permissions Required',
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),

              SizedBox(height: 2.h),

              Text(
                'FitMotion needs access to device sensors to track your workouts and provide accurate fitness data.',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.neutralGray,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 4.h),

              Expanded(
                child: ListView(
                  children: [
                    _buildPermissionCard(
                      'Location Access',
                      'Track running routes, distance, and pace during outdoor workouts',
                      Icons.location_on,
                      AppTheme.primaryBlue,
                      'Used only during active workouts',
                    ),
                    SizedBox(height: 2.h),
                    _buildPermissionCard(
                      'Motion & Activity',
                      'Count steps, detect movement, and calculate calories burned',
                      Icons.directions_run,
                      AppTheme.energyOrange,
                      'Accesses device pedometer and accelerometer',
                    ),
                    SizedBox(height: 2.h),
                    _buildPermissionCard(
                      'Notifications',
                      'Remind you about workouts and celebrate achievements',
                      Icons.notifications,
                      AppTheme.accentTeal,
                      'Can be disabled anytime in settings',
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.successGreen.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                color: AppTheme.successGreen,
                                size: 20,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Privacy First',
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                  color: AppTheme.successGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            '• All data stays on your device\n• No data shared with third parties\n• You control what gets tracked\n• Full data deletion available',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.successGreen,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 2.h),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _grantPermissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: AppTheme.pureWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.pureWhite,
                                ),
                              ),
                            )
                          : Text(
                              'Grant Permissions & Continue',
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                color: AppTheme.pureWhite,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextButton(
                    onPressed: _isLoading ? null : _continueWithoutPermissions,
                    child: Text(
                      'Continue with Limited Features',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.neutralGray,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard(
    String title,
    String description,
    IconData icon,
    Color color,
    String usage,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.neutralGray,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  usage,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _grantPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Request permissions one by one
      final locationStatus = await Permission.location.request();
      final activityStatus = await Permission.activityRecognition.request();
      final notificationStatus = await Permission.notification.request();

      // Save consent status
      await _db.setSetting('permissions_requested', 'true');
      await _db.setSetting(
          'location_permission', locationStatus.isGranted.toString());
      await _db.setSetting(
          'activity_permission', activityStatus.isGranted.toString());
      await _db.setSetting(
          'notification_permission', notificationStatus.isGranted.toString());

      // Navigate to home screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.homeDashboardScreen);
      }
    } catch (e) {
      debugPrint('Grant permissions error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting permissions. Please try again.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _continueWithoutPermissions() async {
    try {
      // Save that user declined permissions
      await _db.setSetting('permissions_requested', 'true');
      await _db.setSetting('permissions_granted', 'false');

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.homeDashboardScreen);
      }
    } catch (e) {
      debugPrint('Continue without permissions error: $e');
    }
  }
}
