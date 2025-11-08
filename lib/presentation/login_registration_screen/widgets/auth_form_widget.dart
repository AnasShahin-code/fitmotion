import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AuthFormWidget extends StatefulWidget {
  final bool isLogin;
  final Function(String email, String password, {String? name}) onSubmit;
  final VoidCallback onForgotPassword;
  final bool isLoading; // Add loading state parameter

  const AuthFormWidget({
    Key? key,
    required this.isLogin,
    required this.onSubmit,
    required this.onForgotPassword,
    this.isLoading = false, // Default to false
  }) : super(key: key);

  @override
  State<AuthFormWidget> createState() => _AuthFormWidgetState();
}

class _AuthFormWidgetState extends State<AuthFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (widget.isLoading) return; // Prevent multiple submissions

    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text,
        name: widget.isLogin ? null : _nameController.text.trim(),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (!widget.isLogin && (value == null || value.isEmpty)) {
      return 'Name is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name field for registration
          if (!widget.isLogin) ...[
            TextFormField(
              controller: _nameController,
              validator: _validateName,
              enabled: !widget.isLoading, // Disable when loading
              decoration: InputDecoration(
                hintText: 'Full Name',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.neutralGray,
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: widget.isLoading
                    ? AppTheme.surfaceLight.withValues(alpha: 0.5)
                    : AppTheme.surfaceLight,
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.errorRed,
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.errorRed,
                    width: 2,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
          ],

          // Email field
          TextFormField(
            controller: _emailController,
            validator: _validateEmail,
            enabled: !widget.isLoading, // Disable when loading
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Email Address',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'email',
                  color: AppTheme.neutralGray,
                  size: 20,
                ),
              ),
              filled: true,
              fillColor: widget.isLoading
                  ? AppTheme.surfaceLight.withValues(alpha: 0.5)
                  : AppTheme.surfaceLight,
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.errorRed,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.errorRed,
                  width: 2,
                ),
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Password field
          TextFormField(
            controller: _passwordController,
            validator: _validatePassword,
            enabled: !widget.isLoading, // Disable when loading
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'lock',
                  color: AppTheme.neutralGray,
                  size: 20,
                ),
              ),
              suffixIcon: GestureDetector(
                onTap: widget.isLoading
                    ? null
                    : () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                        HapticFeedback.lightImpact();
                      },
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName:
                        _obscurePassword ? 'visibility_off' : 'visibility',
                    color: AppTheme.neutralGray,
                    size: 20,
                  ),
                ),
              ),
              filled: true,
              fillColor: widget.isLoading
                  ? AppTheme.surfaceLight.withValues(alpha: 0.5)
                  : AppTheme.surfaceLight,
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.errorRed,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.errorRed,
                  width: 2,
                ),
              ),
            ),
          ),

          // Forgot password for login
          if (widget.isLogin) ...[
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: widget.isLoading ? null : widget.onForgotPassword,
                  child: Text(
                    'Forgot Password?',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: widget.isLoading
                          ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                          : AppTheme.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 4.h),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isLoading
                    ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                    : AppTheme.primaryBlue,
                foregroundColor: AppTheme.pureWhite,
                elevation: widget.isLoading ? 0 : 3,
                shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: widget.isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.pureWhite,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          widget.isLogin
                              ? 'Signing In...'
                              : 'Creating Account...',
                          style: AppTheme.lightTheme.textTheme.labelLarge
                              ?.copyWith(
                            color: AppTheme.pureWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      widget.isLogin ? 'Sign In' : 'Create Account',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.pureWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
