import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/animated_logo_widget.dart';
import './widgets/background_gradient_widget.dart';
import './widgets/loading_indicator_widget.dart';
import './widgets/permission_explanation_modal_widget.dart';
import './widgets/retry_modal_widget.dart';

/// Splash Screen creates a cinematic app launch experience while initializing core services
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _showRetryModal = false;
  bool _showPermissionModal = false;
  bool _isInitializing = true;
  String _initializationStatus = 'Initializing services...';

  @override
  void initState() {
    super.initState();
    _setSystemUIOverlay();
    _startInitialization();
  }

  void _setSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.lightTheme.colorScheme.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _startInitialization() async {
    try {
      await _performInitializationTasks();
    } catch (e) {
      _handleInitializationError();
    }
  }

  Future<void> _performInitializationTasks() async {
    // Simulate initialization delay for cinematic effect
    await Future.delayed(const Duration(milliseconds: 1000));

    // Check GPS permission
    setState(() {
      _initializationStatus = 'Checking location permissions...';
    });

    final locationPermission = await _checkLocationPermission();
    if (!locationPermission) {
      setState(() {
        _showPermissionModal = true;
        _isInitializing = false;
      });
      return;
    }

    // Check user authentication status
    setState(() {
      _initializationStatus = 'Verifying authentication...';
    });
    await Future.delayed(const Duration(milliseconds: 800));

    final isAuthenticated = await _checkAuthenticationStatus();

    // Load cached location data
    setState(() {
      _initializationStatus = 'Loading cached data...';
    });
    await Future.delayed(const Duration(milliseconds: 600));

    await _loadCachedLocationData();

    // Validate payment methods
    setState(() {
      _initializationStatus = 'Validating payment methods...';
    });
    await Future.delayed(const Duration(milliseconds: 500));

    await _validatePaymentMethods();

    // Complete initialization
    setState(() {
      _initializationStatus = 'Ready to go!';
    });
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigate based on authentication status
    _navigateToNextScreen(isAuthenticated);
  }

  Future<bool> _checkLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  Future<bool> _checkAuthenticationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final hasCompletedOnboarding =
          prefs.getBool('has_completed_onboarding') ?? false;

      return isLoggedIn && hasCompletedOnboarding;
    } catch (e) {
      return false;
    }
  }

  Future<void> _loadCachedLocationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedLat = prefs.getDouble('cached_latitude');
      final cachedLng = prefs.getDouble('cached_longitude');

      // Simulate loading cached data
      if (cachedLat != null && cachedLng != null) {
        // Data loaded successfully
      }
    } catch (e) {
      // Handle cache loading error silently
    }
  }

  Future<void> _validatePaymentMethods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasPaymentMethod = prefs.getBool('has_payment_method') ?? false;

      // Simulate payment validation
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      // Handle payment validation error silently
    }
  }

  void _handleInitializationError() {
    setState(() {
      _isInitializing = false;
      _showRetryModal = true;
    });
  }

  void _navigateToNextScreen(bool isAuthenticated) {
    // Provide haptic feedback for premium feel
    HapticFeedback.lightImpact();

    if (isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/location-detection-screen');
    } else {
      Navigator.pushReplacementNamed(context, '/authentication-screen');
    }
  }

  void _handleRetry() {
    setState(() {
      _showRetryModal = false;
      _isInitializing = true;
      _initializationStatus = 'Retrying initialization...';
    });
    _startInitialization();
  }

  void _handleRetryCancel() {
    SystemNavigator.pop();
  }

  void _handlePermissionAllow() async {
    setState(() {
      _showPermissionModal = false;
      _isInitializing = true;
      _initializationStatus = 'Requesting location permission...';
    });

    final permission = await Permission.location.request();
    if (permission.isGranted) {
      _startInitialization();
    } else {
      setState(() {
        _showPermissionModal = true;
        _isInitializing = false;
      });
    }
  }

  void _handlePermissionDeny() {
    // Navigate to authentication without location permission
    Navigator.pushReplacementNamed(context, '/authentication-screen');
  }

  void _onLogoAnimationComplete() {
    // Logo animation completed, continue with initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          const BackgroundGradientWidget(),

          // Main content
          SafeArea(
            child: SizedBox(
              width: 100.w,
              height: 100.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spacer to push content to center
                  const Spacer(flex: 2),

                  // Animated logo
                  AnimatedLogoWidget(
                    onAnimationComplete: _onLogoAnimationComplete,
                  ),

                  SizedBox(height: 8.h),

                  // Loading indicator (only show when initializing)
                  _isInitializing
                      ? const LoadingIndicatorWidget()
                      : const SizedBox.shrink(),

                  // Spacer to balance layout
                  const Spacer(flex: 3),

                  // App version and copyright
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Column(
                      children: [
                        Text(
                          'Version 1.0.0',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                            fontSize: 10.sp,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          '© 2024 RungrojCarRental. All rights reserved.',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                            fontSize: 9.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Retry modal overlay
          if (_showRetryModal)
            RetryModalWidget(
              onRetry: _handleRetry,
              onCancel: _handleRetryCancel,
            ),

          // Permission explanation modal overlay
          if (_showPermissionModal)
            PermissionExplanationModalWidget(
              onAllow: _handlePermissionAllow,
              onDeny: _handlePermissionDeny,
            ),
        ],
      ),
    );
  }
}
