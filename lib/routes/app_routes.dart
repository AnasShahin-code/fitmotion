import 'package:flutter/material.dart';
import '../presentation/progress_statistics_screen/progress_statistics_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_registration_screen/login_registration_screen.dart';
import '../presentation/welcome_onboarding_screen/welcome_onboarding_screen.dart';
import '../presentation/home_dashboard_screen/home_dashboard_screen.dart';
import '../presentation/workout_detail_screen/workout_detail_screen.dart';
import '../presentation/permissions_consent_screen/permissions_consent_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/workout_tracking_screen/workout_tracking_screen.dart';

class AppRoutes {
  // Route constants
  static const String initial = '/splash-screen';
  static const String splashScreen = '/splash-screen';
  static const String welcomeOnboardingScreen = '/welcome-onboarding-screen';
  static const String loginRegistrationScreen = '/login-registration-screen';
  static const String homeDashboardScreen = '/home-dashboard-screen';
  static const String workoutDetailScreen = '/workout-detail-screen';
  static const String progressStatisticsScreen = '/progress-statistics-screen';
  static const String permissionsConsentScreen = '/permissions-consent-screen';
  static const String settingsScreen = '/settings-screen';
  static const String workoutTrackingScreen = '/workout-tracking-screen';

  // Routes map
  static Map<String, WidgetBuilder> get routes => {
        splashScreen: (context) => const SplashScreen(),
        welcomeOnboardingScreen: (context) => const WelcomeOnboardingScreen(),
        loginRegistrationScreen: (context) => const LoginRegistrationScreen(),
        homeDashboardScreen: (context) => const HomeDashboardScreen(),
        workoutDetailScreen: (context) => const WorkoutDetailScreen(),
        progressStatisticsScreen: (context) => const ProgressStatisticsScreen(),
        permissionsConsentScreen: (context) => const PermissionsConsentScreen(),
        settingsScreen: (context) => const SettingsScreen(),
        workoutTrackingScreen: (context) {
          // Get arguments from route
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return WorkoutTrackingScreen(category: args);
        },
      };
}
