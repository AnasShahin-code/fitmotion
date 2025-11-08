import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './widgets/auth_form_widget.dart';
import './widgets/auth_toggle_widget.dart';
import './widgets/social_login_buttons_widget.dart';

class LoginRegistrationScreen extends StatefulWidget {
  const LoginRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<LoginRegistrationScreen> createState() =>
      _LoginRegistrationScreenState();
}

class _LoginRegistrationScreenState extends State<LoginRegistrationScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleToggle(bool isLogin) {
    if (_isLogin != isLogin) {
      setState(() {
        _isLogin = isLogin;
      });
      HapticFeedback.lightImpact();
    }
  }

  void _handleAuth(String email, String password, {String? name}) {
    if (_isLogin) {
      _handleLogin(email, password);
    } else {
      _handleRegister(email, password, name ?? '');
    }
  }

  void _handleLogin(String email, String password) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.instance.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        HapticFeedback.mediumImpact();
        Fluttertoast.showToast(
          msg: "Login successful! Welcome back.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.successGreen,
          textColor: AppTheme.pureWhite,
        );
        Navigator.pushReplacementNamed(context, '/home-dashboard-screen');
      } else {
        _showErrorMessage("Login failed. Please check your credentials.");
      }
    } catch (error) {
      HapticFeedback.heavyImpact();
      String errorMessage = "Login failed. Please try again.";

      // Handle specific error cases
      if (error.toString().contains('Invalid login credentials')) {
        errorMessage =
            "Invalid email or password. Please check your credentials.";
      } else if (error.toString().contains('Email not confirmed')) {
        errorMessage = "Please confirm your email before signing in.";
      }

      _showErrorMessage(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleRegister(String email, String password, String name) async {
    if (_isLoading) return;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      HapticFeedback.heavyImpact();
      _showErrorMessage("Please fill in all required fields.");
      return;
    }

    if (password.length < 6) {
      HapticFeedback.heavyImpact();
      _showErrorMessage("Password must be at least 6 characters long.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.instance.signUp(
        email: email,
        password: password,
        fullName: name,
      );

      if (response.user != null) {
        HapticFeedback.mediumImpact();
        Fluttertoast.showToast(
          msg: "Account created successfully! Welcome to FitMotion.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.successGreen,
          textColor: AppTheme.pureWhite,
        );
        Navigator.pushReplacementNamed(context, '/home-dashboard-screen');
      } else {
        _showErrorMessage("Registration failed. Please try again.");
      }
    } catch (error) {
      HapticFeedback.heavyImpact();
      String errorMessage = "Registration failed. Please try again.";

      // Handle specific error cases
      if (error.toString().contains('already registered')) {
        errorMessage =
            "This email is already registered. Try signing in instead.";
      } else if (error.toString().contains('Invalid email')) {
        errorMessage = "Please enter a valid email address.";
      } else if (error.toString().contains('Password should be')) {
        errorMessage = "Password must be at least 6 characters long.";
      }

      _showErrorMessage(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AuthService.instance.signInWithGoogle();

      if (success) {
        HapticFeedback.lightImpact();
        Fluttertoast.showToast(
          msg: "Google Sign-In successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.successGreen,
          textColor: AppTheme.pureWhite,
        );
        Navigator.pushReplacementNamed(context, '/home-dashboard-screen');
      } else {
        _showErrorMessage("Google Sign-In was cancelled or failed.");
      }
    } catch (error) {
      HapticFeedback.heavyImpact();
      _showErrorMessage("Google Sign-In failed. Please try again.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleAppleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await AuthService.instance.signInWithApple();

      if (success) {
        HapticFeedback.lightImpact();
        Fluttertoast.showToast(
          msg: "Apple Sign-In successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.successGreen,
          textColor: AppTheme.pureWhite,
        );
        Navigator.pushReplacementNamed(context, '/home-dashboard-screen');
      } else {
        _showErrorMessage("Apple Sign-In was cancelled or failed.");
      }
    } catch (error) {
      HapticFeedback.heavyImpact();
      _showErrorMessage("Apple Sign-In failed. Please try again.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleGuestAccess() {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Welcome! You're using FitMotion as a guest.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.accentTeal,
      textColor: AppTheme.pureWhite,
    );
    Navigator.pushReplacementNamed(context, '/home-dashboard-screen');
  }

  void _handleForgotPassword() {
    _showForgotPasswordDialog();
  }

  void _showErrorMessage(String message) {
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
                iconName: 'error',
                color: AppTheme.errorRed,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Authentication Error',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.errorRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textDark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();

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
                iconName: 'lock_reset',
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Reset Password',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your email address and we will send you a link to reset your password.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'email',
                      color: AppTheme.neutralGray,
                      size: 20,
                    ),
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.neutralGray.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.neutralGray.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryBlue,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.neutralGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  Fluttertoast.showToast(
                    msg: "Please enter your email address",
                    backgroundColor: AppTheme.errorRed,
                    textColor: AppTheme.pureWhite,
                  );
                  return;
                }

                try {
                  await AuthService.instance.resetPassword(email: email);
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(
                    msg: "Password reset link sent to your email!",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: AppTheme.successGreen,
                    textColor: AppTheme.pureWhite,
                  );
                } catch (error) {
                  Fluttertoast.showToast(
                    msg: "Failed to send reset email. Please try again.",
                    backgroundColor: AppTheme.errorRed,
                    textColor: AppTheme.pureWhite,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.pureWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Send Link',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureWhite,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 4.h),
                  _buildLogo(),
                  SizedBox(height: 4.h),
                  _buildWelcomeText(),
                  SizedBox(height: 4.h),
                  AuthToggleWidget(
                    isLogin: _isLogin,
                    onToggle: _handleToggle,
                  ),
                  SizedBox(height: 3.h),
                  AuthFormWidget(
                    isLogin: _isLogin,
                    onSubmit: _handleAuth,
                    onForgotPassword: _handleForgotPassword,
                    isLoading: _isLoading,
                  ),
                  SizedBox(height: 3.h),
                  SocialLoginButtonsWidget(
                    onGoogleSignIn: _handleGoogleSignIn,
                    onAppleSignIn: _handleAppleSignIn,
                    isLoading: _isLoading,
                  ),
                  SizedBox(height: 3.h),
                  _buildGuestAccessButton(),
                  SizedBox(height: 2.h),
                  _buildDemoCredentials(),
                  SizedBox(height: 4.h),
                  _buildBottomText(),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 25.w,
      height: 25.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.energyOrange,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'FM',
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.pureWhite,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'Welcome to FitMotion',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          _isLogin
              ? 'Sign in to continue your fitness journey'
              : 'Create your account and start your fitness journey',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.neutralGray,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBottomText() {
    return Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy',
      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
        color: AppTheme.neutralGray,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildGuestAccessButton() {
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
                'Or',
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
        GestureDetector(
          onTap: _isLoading ? null : _handleGuestAccess,
          child: Container(
            width: double.infinity,
            height: 6.h,
            decoration: BoxDecoration(
              color: _isLoading
                  ? AppTheme.surfaceLight.withValues(alpha: 0.5)
                  : AppTheme.surfaceLight,
              border: Border.all(
                color: AppTheme.accentTeal
                    .withValues(alpha: _isLoading ? 0.3 : 0.5),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'visibility',
                  color: _isLoading
                      ? AppTheme.accentTeal.withValues(alpha: 0.5)
                      : AppTheme.accentTeal,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Continue as Guest',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: _isLoading
                        ? AppTheme.accentTeal.withValues(alpha: 0.5)
                        : AppTheme.accentTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Limited features available in guest mode',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.neutralGray,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDemoCredentials() {
    return Container(
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: AppTheme.accentTeal.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentTeal.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔐 Demo Credentials',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.accentTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          _buildCredentialRow('Admin', 'admin@fitmotion.com', 'admin123'),
          SizedBox(height: 1.h),
          _buildCredentialRow('Trainer', 'trainer@fitmotion.com', 'trainer123'),
          SizedBox(height: 1.h),
          _buildCredentialRow('User', 'user@fitmotion.com', 'user123'),
        ],
      ),
    );
  }

  Widget _buildCredentialRow(String type, String email, String password) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$type:',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.accentTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$email / $password',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textDark,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
