import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Save email to SharedPreferences
  Future<void> _saveUserEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      debugPrint('✅ User email saved to SharedPreferences: $email');
    } catch (e) {
      debugPrint('❌ Failed to save email to SharedPreferences: $e');
    }
  }

  // Remove email from SharedPreferences
  Future<void> _removeUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      debugPrint('✅ User email removed from SharedPreferences');
    } catch (e) {
      debugPrint('❌ Failed to remove email from SharedPreferences: $e');
    }
  }

  // Get stored email from SharedPreferences
  Future<String?> getStoredEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('user_email');
    } catch (e) {
      debugPrint('❌ Failed to get email from SharedPreferences: $e');
      return null;
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      if (response.user != null) {
        await _saveUserEmail(email);
      }

      return response;
    } catch (error) {
      throw Exception('Sign up failed: $error');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _saveUserEmail(email);
      }

      return response;
    } catch (error) {
      throw Exception('Sign in failed: $error');
    }
  }

  // Sign out (basic)
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      await _removeUserEmail();
    } catch (error) {
      throw Exception('Sign out failed: $error');
    }
  }

  // 🔥 Enhanced sign out with Google session cleanup
  Future<void> logoutWithNavigation(BuildContext context) async {
    try {
      // 1. تأكيد تسجيل الخروج
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes, Logout'),
              ),
            ],
          );
        },
      );

      if (confirm != true) return;

      // 2. تسجيل خروج من Supabase
      await _client.auth.signOut();

      // 3. مسح البيانات المحلية
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      debugPrint('✅ Logged out from Supabase and local data cleared');

      // 4. تسجيل خروج من Google نفسه
      if (kIsWeb) {
        final logoutUrl = Uri.parse('https://accounts.google.com/Logout');
        try {
          // نفتح الرابط في نافذة جديدة
          await launchUrl(
            logoutUrl,
            webOnlyWindowName: '_blank',
          );

          debugPrint('✅ Google session cleared — waiting 2 seconds...');
          await Future.delayed(const Duration(seconds: 2)); // ننتظر شوي
        } catch (e) {
          debugPrint('⚠️ Could not open Google logout URL: $e');
        }
      }

      // 5. إعادة التوجيه لصفحة البداية
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint('❌ Error during logout: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred during logout')),
        );
      }
    }
  }

  // Send password reset email
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? fullName,
    int? age,
    String? gender,
    double? weightKg,
    double? heightCm,
    String? activityLevel,
    String? units,
    int? dailyCalorieGoal,
    int? weeklyWorkoutGoal,
    int? preferredWorkoutDuration,
    bool? notificationsEnabled,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (age != null) updates['age'] = age;
      if (gender != null) updates['gender'] = gender;
      if (weightKg != null) updates['weight_kg'] = weightKg;
      if (heightCm != null) updates['height_cm'] = heightCm;
      if (activityLevel != null) updates['activity_level'] = activityLevel;
      if (units != null) updates['units'] = units;
      if (dailyCalorieGoal != null)
        updates['daily_calorie_goal'] = dailyCalorieGoal;
      if (weeklyWorkoutGoal != null)
        updates['weekly_workout_goal'] = weeklyWorkoutGoal;
      if (preferredWorkoutDuration != null)
        updates['preferred_workout_duration'] = preferredWorkoutDuration;
      if (notificationsEnabled != null)
        updates['notifications_enabled'] = notificationsEnabled;

      if (updates.isNotEmpty) {
        updates['updated_at'] = DateTime.now().toIso8601String();

        await _client.from('user_profiles').update(updates).eq('id', user.id);
      }
    } catch (error) {
      throw Exception('Failed to update profile: $error');
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ✅ Fixed Sign in with Google OAuth for Web + Mobile
  Future<bool> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final response = await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo:
              'https://pnydbwibckublrajloxo.supabase.co/auth/v1/callback',
          authScreenLaunchMode: LaunchMode.platformDefault,
        );

        if (response && currentUser?.email != null) {
          await _saveUserEmail(currentUser!.email!);
        }

        return response;
      } else {
        final response = await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'io.supabase.flutter://login-callback/',
          authScreenLaunchMode: LaunchMode.externalApplication,
        );

        if (response && currentUser?.email != null) {
          await _saveUserEmail(currentUser!.email!);
        }

        return response;
      }
    } catch (error) {
      print('Google OAuth Error Details: $error');

      if (error.toString().contains('403')) {
        throw Exception(
            'Google OAuth configuration error. Please check domain authorization.');
      } else if (error.toString().contains('popup_blocked')) {
        throw Exception('Popup blocked. Please allow popups for this site.');
      } else if (error.toString().contains('access_denied')) {
        throw Exception('Access denied. Please try again.');
      }

      throw Exception('Google sign in failed: $error');
    }
  }

  // Sign in with Apple OAuth
  Future<bool> signInWithApple() async {
    try {
      final response = await _client.auth.signInWithOAuth(OAuthProvider.apple);

      if (response && currentUser?.email != null) {
        await _saveUserEmail(currentUser!.email!);
      }

      return response;
    } catch (error) {
      throw Exception('Apple sign in failed: $error');
    }
  }

  // Check if email is available for registration
  Future<bool> isEmailAvailable(String email) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('email', email.toLowerCase());

      return (response as List).isEmpty;
    } catch (error) {
      return true;
    }
  }

  // Get workout sessions for current user
  Future<List<Map<String, dynamic>>> getWorkoutSessions({
    int limit = 10,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');

      final response = await _client
          .from('workout_sessions')
          .select()
          .eq('user_id', user.id)
          .order('session_date', ascending: false)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get workout sessions: $error');
    }
  }

  // Add new workout session
  Future<void> addWorkoutSession({
    required String workoutType,
    required int durationMinutes,
    int? caloriesBurned,
    String? notes,
    DateTime? sessionDate,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');

      await _client.from('workout_sessions').insert({
        'user_id': user.id,
        'workout_type': workoutType,
        'duration_minutes': durationMinutes,
        'calories_burned': caloriesBurned,
        'notes': notes,
        'session_date':
            (sessionDate ?? DateTime.now()).toIso8601String().split('T')[0],
      });
    } catch (error) {
      throw Exception('Failed to add workout session: $error');
    }
  }

  // Get fitness goals for current user
  Future<List<Map<String, dynamic>>> getFitnessGoals() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');

      final response = await _client
          .from('fitness_goals')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get fitness goals: $error');
    }
  }

  // Add new fitness goal
  Future<void> addFitnessGoal({
    required String goalType,
    required double targetValue,
    double currentValue = 0,
    DateTime? targetDate,
  }) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');

      await _client.from('fitness_goals').insert({
        'user_id': user.id,
        'goal_type': goalType,
        'target_value': targetValue,
        'current_value': currentValue,
        'target_date': targetDate?.toIso8601String().split('T')[0],
      });
    } catch (error) {
      throw Exception('Failed to add fitness goal: $error');
    }
  }
}
