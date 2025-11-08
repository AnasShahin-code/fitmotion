import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  String _loadingText = 'Initializing FitMotion...';
  bool _isInitializationComplete = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    try {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      );

      _scaleAnimation = Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ));

      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      _animationController.forward().catchError((error) {
        debugPrint('Animation error: $error');
      });
    } catch (e) {
      debugPrint('Animation initialization failed: $e');
      // Continue without animations if they fail
    }
  }

  Future<void> _initializeApp() async {
    try {
      await _updateLoadingText('Checking system resources...');
      await _performSystemChecks();

      await _updateLoadingText('Loading user preferences...');
      await _loadUserPreferences();

      await _updateLoadingText('Finalizing startup...');
      await Future.delayed(const Duration(milliseconds: 800));

      _isInitializationComplete = true;

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      debugPrint('Initialization error: $e');
      if (mounted) {
        _handleInitializationError(e.toString());
      }
    }
  }

  Future<void> _updateLoadingText(String text) async {
    if (mounted) {
      setState(() {
        _loadingText = text;
      });
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> _performSystemChecks() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      // Safe system UI initialization
      try {
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        );
      } catch (e) {
        debugPrint('System UI styling failed: $e');
        // Continue without custom styling
      }

      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      debugPrint('System check failed: $e');
      // Continue initialization even if system checks fail
    }
  }

  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint('SharedPreferences timeout - using defaults');
          throw Exception('Preferences timeout');
        },
      );

      // Safe preference loading with defaults
      final isFirstLaunch = prefs.getBool('first_launch') ?? true;
      final hasSeenOnboarding = prefs.getBool('seen_onboarding') ?? false;
      final lastAppVersion = prefs.getString('app_version') ?? '1.0.0';

      debugPrint(
          'Preferences loaded - First launch: $isFirstLaunch, Seen onboarding: $hasSeenOnboarding, Version: $lastAppVersion');

      // Store current session info
      await prefs.setString(
          'last_successful_startup', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Preferences loading failed: $e');
      // Continue with default values - app should still work
    }
  }

  void _navigateToNextScreen() {
    if (!_isInitializationComplete) {
      debugPrint('Navigation attempted before initialization complete');
      return;
    }

    setState(() {
      _isLoading = false;
    });

    try {
      _attemptNavigation();
    } catch (e) {
      debugPrint('Navigation failed: $e');
      _handleNavigationError(e.toString());
    }
  }

  void _attemptNavigation() {
    try {
      Navigator.of(context)
          .pushReplacementNamed(AppRoutes.welcomeOnboardingScreen)
          .catchError((error) {
        debugPrint('Primary navigation error: $error');
        _attemptFallbackNavigation();
      });
    } catch (e) {
      debugPrint('Navigation attempt failed: $e');
      _attemptFallbackNavigation();
    }
  }

  void _attemptFallbackNavigation() {
    try {
      // Fallback to login screen if onboarding fails
      Navigator.of(context)
          .pushReplacementNamed(AppRoutes.loginRegistrationScreen)
          .catchError((error) {
        debugPrint('Fallback navigation error: $error');
        _showNavigationFailureDialog();
      });
    } catch (e) {
      debugPrint('Fallback navigation failed: $e');
      _showNavigationFailureDialog();
    }
  }

  void _handleInitializationError(String error) {
    _showErrorDialog(
      'Startup Issue',
      'The app encountered an issue during startup. Please try again.',
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _attemptNavigation();
          },
          child: const Text('Continue Anyway'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _initializeApp();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
          ),
          child: const Text('Retry Startup'),
        ),
      ],
    );
  }

  void _handleNavigationError(String error) {
    _showErrorDialog(
      'Navigation Error',
      'Unable to proceed to the next screen. Please try restarting the app.',
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _attemptFallbackNavigation();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
          ),
          child: const Text('Try Again'),
        ),
      ],
    );
  }

  void _showNavigationFailureDialog() {
    _showErrorDialog(
      'Critical Error',
      'Unable to start the app properly. Please restart the application.',
      actions: [
        ElevatedButton(
          onPressed: () {
            if (!kIsWeb && Platform.isAndroid || Platform.isIOS) {
              SystemNavigator.pop();
            } else {
              // For web, just reload
              Navigator.of(context).pop();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Close App'),
        ),
      ],
    );
  }

  void _showErrorDialog(String title, String message,
      {required List<Widget> actions}) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
          actions: actions,
        );
      },
    );
  }

  @override
  void dispose() {
    try {
      _animationController.dispose();
    } catch (e) {
      debugPrint('Animation controller disposal error: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryBlue,
              AppTheme.energyOrange,
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: _buildAnimatedLogo(),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading) _buildLoadingIndicator(),
                    SizedBox(height: 4.h),
                    _buildVersionInfo(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    try {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogo(),
                  SizedBox(height: 3.h),
                  _buildAppName(),
                  SizedBox(height: 1.h),
                  _buildTagline(),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Animated logo build error: $e');
      // Fallback to static logo if animation fails
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(),
          SizedBox(height: 3.h),
          _buildAppName(),
          SizedBox(height: 1.h),
          _buildTagline(),
        ],
      );
    }
  }

  Widget _buildLogo() {
    return Container(
      width: 25.w,
      height: 25.w,
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: 'fitness_center',
          color: AppTheme.primaryBlue,
          size: 12.w,
        ),
      ),
    );
  }

  Widget _buildAppName() {
    return Text(
      'FitMotion',
      style: AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
        color: AppTheme.pureWhite,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTagline() {
    return Text(
      'Your Fitness Journey Starts Here',
      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
        color: AppTheme.pureWhite.withAlpha(230),
        fontWeight: FontWeight.w400,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 8.w,
          height: 8.w,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.pureWhite,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Text(
            _loadingText,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.pureWhite.withAlpha(204),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildVersionInfo() {
    return Text(
      'Version 1.0.0',
      style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
        color: AppTheme.pureWhite.withAlpha(179),
      ),
    );
  }
}
