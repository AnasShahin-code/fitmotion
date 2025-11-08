import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/demo_mode_service.dart';
import '../../services/tracking_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final DatabaseService _db = DatabaseService();
  final DemoModeService _demoMode = DemoModeService();
  final TrackingService _tracking = TrackingService();
  final AuthService _authService = AuthService.instance;

  UserProfile? _userProfile;
  Map<String, dynamic>? _supabaseProfile;
  bool _isLoading = true;
  bool _isDemoMode = false;
  String _units = 'metric';
  String? _userEmail;
  String? _userName;

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedGender = 'male';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    try {
      final supabase = Supabase.instance.client;

      // Sign out from Supabase
      await supabase.auth.signOut();

      // Remove any local session
      await supabase.removeAllChannels();

      debugPrint('✅ User signed out completely');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully logged out')),
        );

        // Navigate back to login screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.loginRegistrationScreen,
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during logout: $e')),
        );
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      // Load user profile from local database
      final profile = await _db.getUserProfile();
      final units = await _db.getSetting('units', defaultValue: 'metric');

      // Load user email from SharedPreferences
      final storedEmail = await _authService.getStoredEmail();

      // Load Supabase profile data
      Map<String, dynamic>? supabaseProfile;
      try {
        supabaseProfile = await _authService.getUserProfile();
      } catch (e) {
        debugPrint('Could not load Supabase profile: $e');
      }

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _supabaseProfile = supabaseProfile;
          _isDemoMode = _demoMode.isDemoMode;
          _units = units ?? 'metric';
          _userEmail = storedEmail ??
              supabaseProfile?['email'] ??
              _authService.currentUser?.email;
          _userName =
              supabaseProfile?['full_name'] ?? profile?.fullName ?? 'User';
          _isLoading = false;
        });

        // Populate form fields with Supabase data if available, fallback to local profile
        if (supabaseProfile != null) {
          _weightController.text = (supabaseProfile['weight_kg']?.toString() ??
              profile?.weightKg.toString() ??
              '');
          _heightController.text = (supabaseProfile['height_cm']?.toString() ??
              profile?.heightCm.toString() ??
              '');
          _ageController.text = (supabaseProfile['age']?.toString() ??
              profile?.age.toString() ??
              '');
          _selectedGender = supabaseProfile['gender']?.toString() ??
              profile?.gender ??
              'male';
        } else if (profile != null) {
          _weightController.text = profile.weightKg.toString();
          _heightController.text = profile.heightCm.toString();
          _ageController.text = profile.age.toString();
          _selectedGender = profile.gender ?? 'male';
        }
      }
    } catch (e) {
      debugPrint('Load user data error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Display Section
                  _buildSectionHeader('User Profile'),
                  SizedBox(height: 2.h),
                  _buildUserProfileDisplaySection(),

                  SizedBox(height: 4.h),

                  // Profile Settings Section
                  _buildSectionHeader('Profile Settings'),
                  SizedBox(height: 2.h),
                  _buildUserProfileSection(),

                  SizedBox(height: 4.h),

                  // App Preferences
                  _buildSectionHeader('App Preferences'),
                  SizedBox(height: 2.h),
                  _buildPreferencesSection(),

                  SizedBox(height: 4.h),

                  // Permissions
                  _buildSectionHeader('Permissions'),
                  SizedBox(height: 2.h),
                  _buildPermissionsSection(),

                  SizedBox(height: 4.h),

                  // Data Management
                  _buildSectionHeader('Data Management'),
                  SizedBox(height: 2.h),
                  _buildDataSection(),

                  SizedBox(height: 4.h),

                  // Developer Options
                  _buildSectionHeader('Developer Options'),
                  SizedBox(height: 2.h),
                  _buildDeveloperSection(),

                  SizedBox(height: 4.h),

                  // Logout Section
                  _buildSectionHeader('Account'),
                  SizedBox(height: 2.h),
                  _buildLogoutSection(),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.textDark,
      ),
    );
  }

  Widget _buildUserProfileDisplaySection() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profile Picture Placeholder
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryBlue,
                      AppTheme.energyOrange,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (_userName?.isNotEmpty == true)
                        ? _userName![0].toUpperCase()
                        : 'U',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.pureWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userName ?? 'User',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _userEmail ?? 'No email',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.neutralGray,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withAlpha(77),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _supabaseProfile?['role']?.toString().toUpperCase() ??
                            _userProfile?.role.toUpperCase() ??
                            'MEMBER',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection() {
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Weight (${_units == 'metric' ? 'kg' : 'lbs'})',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Height (${_units == 'metric' ? 'cm' : 'in'})',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value ?? 'male';
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveUserProfile,
              child: Text('Save Profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection() {
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
      child: Column(
        children: [
          ListTile(
            title: Text('Units'),
            subtitle: Text(
              _units == 'metric'
                  ? 'Metric (km, kg, cm)'
                  : 'Imperial (mi, lbs, in)',
            ),
            trailing: Switch(
              value: _units == 'imperial',
              onChanged: (value) {
                setState(() {
                  _units = value ? 'imperial' : 'metric';
                });
                _saveUnits();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsSection() {
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
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.location_on, color: AppTheme.primaryBlue),
            title: Text('Location Access'),
            subtitle: Text('Required for GPS tracking during runs'),
            trailing: TextButton(
              onPressed: _openPermissionSettings,
              child: Text('Manage'),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.directions_run, color: AppTheme.energyOrange),
            title: Text('Motion & Activity'),
            subtitle: Text('Required for step counting and activity detection'),
            trailing: TextButton(
              onPressed: _openPermissionSettings,
              child: Text('Manage'),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.notifications, color: AppTheme.accentTeal),
            title: Text('Notifications'),
            subtitle: Text('Workout reminders and achievements'),
            trailing: TextButton(
              onPressed: _openPermissionSettings,
              child: Text('Manage'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
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
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.download, color: AppTheme.primaryBlue),
            title: Text('Export Data'),
            subtitle: Text('Download your workout data as CSV/JSON'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: _exportData,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.refresh, color: AppTheme.energyOrange),
            title: Text('Reset Local Data'),
            subtitle: Text('Clear local storage and reset counters to zero'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: _showResetLocalDataDialog,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever, color: AppTheme.errorRed),
            title: Text('Reset All Data'),
            subtitle: Text('Permanently delete all workout data'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: _showResetDataDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection() {
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
      child: Column(
        children: [
          ListTile(
            title: Text('Demo Mode'),
            subtitle: Text(
              _isDemoMode ? 'Showing sample data' : 'Showing real data',
            ),
            trailing: Switch(
              value: _isDemoMode,
              onChanged: (value) {
                setState(() {
                  _isDemoMode = value;
                });
                _toggleDemoMode(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorRed, width: 2), // Red frame
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showLogoutDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.white),
                  SizedBox(width: 2.w),
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Future<void> _showLogoutDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.logout, color: AppTheme.errorRed),
              SizedBox(width: 2.w),
              Text('Logout'),
            ],
          ),
          content: Text(
            'Are you sure you want to logout? You will be redirected to the login screen.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Logout', style: TextStyle(color: AppTheme.errorRed)),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveUserProfile() async {
    try {
      final weight = double.tryParse(_weightController.text) ?? 70.0;
      final height = double.tryParse(_heightController.text) ?? 170.0;
      final age = int.tryParse(_ageController.text) ?? 25;

      // Update Supabase profile first
      try {
        await _authService.updateUserProfile(
          weightKg: weight,
          heightCm: height,
          age: age,
          gender: _selectedGender,
          units: _units,
        );
        debugPrint('✅ Supabase profile updated successfully');
      } catch (e) {
        debugPrint('❌ Supabase profile update failed: $e');
      }

      // Update local profile as fallback
      final profile = UserProfile(
        id: _userProfile?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        email: _userEmail ?? '',
        fullName: _userName ?? '',
        role: _supabaseProfile?['role'] ?? 'member',
        weightKg: weight,
        heightCm: height,
        age: age,
        gender: _selectedGender,
        units: _units,
        createdAt: _userProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.saveUserProfile(profile);

      if (mounted) {
        setState(() {
          _userProfile = profile;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile saved successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('Save user profile error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _saveUnits() async {
    try {
      await _db.setSetting('units', _units);
    } catch (e) {
      debugPrint('Save units error: $e');
    }
  }

  Future<void> _openPermissionSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('Open settings error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please check app settings manually'),
            backgroundColor: AppTheme.neutralGray,
          ),
        );
      }
    }
  }

  Future<void> _exportData() async {
    try {
      final sessions = await _db.getWorkoutSessions();
      final stats = await _db.getWorkoutStats();

      final data = {
        'exportDate': DateTime.now().toIso8601String(),
        'userProfile': _userProfile?.toMap(),
        'workoutSessions':
            sessions.map((s) => (s as WorkoutSession).toMap()).toList(),
        'stats': stats,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final filename =
          'fitmotion_export_${DateTime.now().millisecondsSinceEpoch}.json';

      if (kIsWeb) {
        final bytes = utf8.encode(jsonString);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(jsonString);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      debugPrint('Export data error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _showResetLocalDataDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Local Data'),
          content: Text(
            'This will clear local storage and reset all counters to zero. Your workout history will be cleared. Continue?',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Reset',
                style: TextStyle(color: AppTheme.energyOrange),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _resetLocalData();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetLocalData() async {
    try {
      // Clear all local data but keep user profile settings
      await _db.deleteAllData();

      // Ensure demo mode is OFF
      await _demoMode.setDemoMode(false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Local data cleared successfully. Counters reset to zero.',
            ),
            backgroundColor: AppTheme.successGreen,
          ),
        );

        // Reset UI state
        setState(() {
          _userProfile = null;
        });

        _weightController.clear();
        _heightController.clear();
        _ageController.clear();
        _selectedGender = 'male';
      }
    } catch (e) {
      debugPrint('Reset local data error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing local data'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _showResetDataDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset All Data'),
          content: Text(
            'Are you sure you want to delete all workout data? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Delete All',
                style: TextStyle(color: AppTheme.errorRed),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _resetAllData();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetAllData() async {
    try {
      await _db.deleteAllData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All data deleted successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );

        // Reset UI state
        setState(() {
          _userProfile = null;
        });

        _weightController.clear();
        _heightController.clear();
        _ageController.clear();
        _selectedGender = 'male';
      }
    } catch (e) {
      debugPrint('Reset all data error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting data'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _toggleDemoMode(bool enabled) async {
    try {
      await _demoMode.setDemoMode(enabled);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enabled ? 'Demo mode enabled' : 'Demo mode disabled'),
            backgroundColor: AppTheme.primaryBlue,
          ),
        );
      }
    } catch (e) {
      debugPrint('Toggle demo mode error: $e');
    }
  }
}