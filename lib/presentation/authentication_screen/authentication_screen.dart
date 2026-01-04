import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/app_logo_widget.dart';
import './widgets/biometric_login_widget.dart';
import './widgets/login_form_widget.dart';

/// Premium authentication screen with cinematic user experience
/// Implements secure login with biometric integration and elegant animations
class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _keyboardVisible = false;

  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Mock credentials for testing
  final Map<String, String> _mockCredentials = {
    'admin@taxihouse.com': 'admin123',
    'user@taxihouse.com': 'user123',
    'driver@taxihouse.com': 'driver123',
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupKeyboardListener();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
  }

  void _setupKeyboardListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mediaQuery = MediaQuery.of(context);
      setState(() {
        _keyboardVisible = mediaQuery.viewInsets.bottom > 0;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    // Premium haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Simulate authentication delay
      await Future.delayed(const Duration(milliseconds: 1500));

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Check mock credentials
      if (_mockCredentials.containsKey(email) &&
          _mockCredentials[email] == password) {
        // Success haptic feedback
        HapticFeedback.mediumImpact();

        // Show success toast
        Fluttertoast.showToast(
          msg: "Login successful! Welcome to RungrojCarRental",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          textColor: AppTheme.lightTheme.colorScheme.onPrimary,
        );

        // Navigate to location detection screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/location-detection-screen');
        }
      } else {
        // Error haptic feedback
        HapticFeedback.heavyImpact();

        // Show error message
        _showErrorMessage('Invalid email or password. Please try again.');
      }
    } catch (e) {
      // Error haptic feedback
      HapticFeedback.heavyImpact();

      // Show generic error message
      _showErrorMessage(
          'Login failed. Please check your connection and try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    // Premium haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Simulate biometric authentication
      await Future.delayed(const Duration(milliseconds: 1000));

      // Success haptic feedback
      HapticFeedback.mediumImpact();

      // Show success toast
      Fluttertoast.showToast(
        msg: "Biometric authentication successful!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        textColor: AppTheme.lightTheme.colorScheme.onPrimary,
      );

      // Navigate to location detection screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/location-detection-screen');
      }
    } catch (e) {
      // Error haptic feedback
      HapticFeedback.heavyImpact();

      // Show error message
      _showErrorMessage('Biometric authentication failed. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleForgotPassword() {
    HapticFeedback.selectionClick();

    Fluttertoast.showToast(
      msg: "Password reset link sent to your email",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      textColor: AppTheme.lightTheme.colorScheme.onPrimary,
    );
  }

  void _showErrorMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.error,
      textColor: AppTheme.lightTheme.colorScheme.onError,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _slideAnimation]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: mediaQuery.size.height -
                            mediaQuery.padding.top -
                            mediaQuery.padding.bottom,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Top spacing
                            SizedBox(height: keyboardHeight > 0 ? 4.h : 8.h),

                            // App logo (smaller when keyboard is visible)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: keyboardHeight > 0
                                  ? const SizedBox.shrink()
                                  : const AppLogoWidget(),
                            ),

                            SizedBox(height: keyboardHeight > 0 ? 2.h : 6.h),

                            // Welcome text
                            Column(
                              children: [
                                Text(
                                  'Welcome Back',
                                  style:
                                      theme.textTheme.headlineSmall?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Sign in to continue your premium ride experience',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),

                            SizedBox(height: 4.h),

                            // Login form
                            LoginFormWidget(
                              emailController: _emailController,
                              passwordController: _passwordController,
                              onLogin: _handleLogin,
                              onForgotPassword: _handleForgotPassword,
                              isLoading: _isLoading,
                            ),

                            SizedBox(height: 4.h),

                            // Biometric login (hidden when keyboard is visible)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: keyboardHeight > 0
                                  ? const SizedBox.shrink()
                                  : BiometricLoginWidget(
                                      onBiometricLogin: _handleBiometricLogin,
                                    ),
                            ),

                            // Bottom spacing
                            SizedBox(height: keyboardHeight > 0 ? 2.h : 4.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
