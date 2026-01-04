import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Premium login form with elegant validation and animations
class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.onForgotPassword,
    required this.isLoading,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final bool isLoading;

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget>
    with TickerProviderStateMixin {
  bool _isPasswordVisible = false;
  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  String _emailError = '';
  String _passwordError = '';

  late AnimationController _errorAnimationController;
  late Animation<double> _errorAnimation;

  @override
  void initState() {
    super.initState();
    _errorAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _errorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _errorAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _errorAnimationController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _isEmailValid &&
        _isPasswordValid &&
        widget.emailController.text.isNotEmpty &&
        widget.passwordController.text.isNotEmpty;
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _isEmailValid = false;
        _emailError = 'Email is required';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
        _isEmailValid = false;
        _emailError = 'Please enter a valid email';
      } else {
        _isEmailValid = true;
        _emailError = '';
      }
    });

    if (!_isEmailValid) {
      _errorAnimationController.forward().then((_) {
        _errorAnimationController.reverse();
      });
    }
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _isPasswordValid = false;
        _passwordError = 'Password is required';
      } else if (value.length < 6) {
        _isPasswordValid = false;
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _isPasswordValid = true;
        _passwordError = '';
      }
    });

    if (!_isPasswordValid) {
      _errorAnimationController.forward().then((_) {
        _errorAnimationController.reverse();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email field
        AnimatedBuilder(
          animation: _errorAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                  _errorAnimation.value * 2 * (1 - _errorAnimation.value), 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !_isEmailValid
                            ? theme.colorScheme.error
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                        width: !_isEmailValid ? 1.5 : 0.5,
                      ),
                    ),
                    child: TextField(
                      controller: widget.emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      enabled: !widget.isLoading,
                      onChanged: _validateEmail,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'email',
                            color: !_isEmailValid
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant,
                            size: 5.w,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 4.h,
                        ),
                      ),
                    ),
                  ),
                  if (!_isEmailValid && _emailError.isNotEmpty) ...[
                    SizedBox(height: 1.h),
                    Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Text(
                        _emailError,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),

        SizedBox(height: 3.h),

        // Password field
        AnimatedBuilder(
          animation: _errorAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                  _errorAnimation.value * 2 * (1 - _errorAnimation.value), 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !_isPasswordValid
                            ? theme.colorScheme.error
                            : theme.colorScheme.outline.withValues(alpha: 0.2),
                        width: !_isPasswordValid ? 1.5 : 0.5,
                      ),
                    ),
                    child: TextField(
                      controller: widget.passwordController,
                      obscureText: !_isPasswordVisible,
                      textInputAction: TextInputAction.done,
                      enabled: !widget.isLoading,
                      onChanged: _validatePassword,
                      onSubmitted: (_) {
                        if (_isFormValid) {
                          widget.onLogin();
                        }
                      },
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                        ),
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'lock',
                            color: !_isPasswordValid
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant,
                            size: 5.w,
                          ),
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: CustomIconWidget(
                              iconName: _isPasswordVisible
                                  ? 'visibility_off'
                                  : 'visibility',
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 5.w,
                            ),
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 4.h,
                        ),
                      ),
                    ),
                  ),
                  if (!_isPasswordValid && _passwordError.isNotEmpty) ...[
                    SizedBox(height: 1.h),
                    Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Text(
                        _passwordError,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),

        SizedBox(height: 2.h),

        // Forgot password link
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: widget.isLoading ? null : widget.onForgotPassword,
            child: Text(
              'Forgot Password?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        SizedBox(height: 4.h),

        // Login button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton(
            onPressed:
                (_isFormValid && !widget.isLoading) ? widget.onLogin : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFormValid
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              foregroundColor: _isFormValid
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              elevation: _isFormValid ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: widget.isLoading
                ? SizedBox(
                    width: 5.w,
                    height: 5.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    'Login',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: _isFormValid
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
