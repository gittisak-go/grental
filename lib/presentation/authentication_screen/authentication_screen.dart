import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../services/magic_link_auth_service.dart';
import '../../services/supabase_service.dart';
import './widgets/app_logo_widget.dart';
import './widgets/social_auth_buttons_widget.dart';

/// Authentication screen — Social login only (Google, Facebook, LINE, Magic Link)
/// No registration / no password login
class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final MagicLinkAuthService _magicLinkService = MagicLinkAuthService();

  bool _isLoading = false;
  bool _magicLinkSent = false;

  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _listenAuthState();
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
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _slideAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
  }

  void _listenAuthState() {
    _magicLinkService.authStateChanges.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn && mounted) {
        _magicLinkService.upsertUserRole().then((role) {
          if (mounted) {
            // Role-based redirect after login
            if (role == 'Super_Admin' || role == 'Admin') {
              Navigator.pushReplacementNamed(
                  context, AppRoutes.adminDashboardScreen);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.rideRequest);
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleMagicLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showErrorMessage('กรุณากรอกอีเมลของคุณ');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showErrorMessage('กรุณากรอกอีเมลที่ถูกต้อง');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      await _magicLinkService.sendMagicLink(email);
      setState(() {
        _isLoading = false;
        _magicLinkSent = true;
      });
      HapticFeedback.mediumImpact();
      Fluttertoast.showToast(
        msg: "ส่งลิงก์เข้าสู่ระบบไปยัง $email แล้ว กรุณาตรวจสอบอีเมล",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        textColor: AppTheme.lightTheme.colorScheme.onPrimary,
      );
    } catch (e) {
      HapticFeedback.heavyImpact();
      setState(() => _isLoading = false);
      _showErrorMessage('ไม่สามารถส่งลิงก์ได้ กรุณาลองอีกครั้ง');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    try {
      // Google OAuth via Supabase
      await SupabaseService.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://taxihouse1176.builtwithrocket.new',
      );
    } catch (e) {
      HapticFeedback.heavyImpact();
      _showErrorMessage('ไม่สามารถเข้าสู่ระบบด้วย Google ได้ กรุณาลองอีกครั้ง');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFacebookSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    try {
      await SupabaseService.instance.client.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'https://taxihouse1176.builtwithrocket.new',
      );
    } catch (e) {
      HapticFeedback.heavyImpact();
      _showErrorMessage(
        'ไม่สามารถเข้าสู่ระบบด้วย Facebook ได้ กรุณาลองอีกครั้ง',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLineSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    try {
      // LINE uses kakao provider slot or custom — show magic link fallback
      _showErrorMessage('กรุณาใช้ Magic Link Email สำหรับ LINE Login ในขณะนี้');
    } catch (e) {
      _showErrorMessage('ไม่สามารถเข้าสู่ระบบด้วย LINE ได้ กรุณาลองอีกครั้ง');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 8.h),

                          // App Logo
                          const AppLogoWidget(),

                          SizedBox(height: 4.h),

                          // Welcome text
                          Text(
                            'ยินดีต้อนรับ',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'รุ่งโรจน์คาร์เร้นท์ — รถเช่าอุดรธานี',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 5.h),

                          // Social login buttons
                          SocialAuthButtonsWidget(
                            onGooglePressed: _handleGoogleSignIn,
                            onFacebookPressed: _handleFacebookSignIn,
                            onLinePressed: _handleLineSignIn,
                            isLoading: _isLoading,
                          ),

                          SizedBox(height: 4.h),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withAlpha(77),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3.w),
                                child: Text(
                                  'หรือเข้าสู่ระบบด้วย Email',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withAlpha(77),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 3.h),

                          // Magic Link Email field
                          if (!_magicLinkSent) ...[
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                labelText: 'อีเมล (Magic Link)',
                                hintText: 'กรอกอีเมลเพื่อรับลิงก์เข้าสู่ระบบ',
                                prefixIcon: Icon(
                                  Icons.email_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            SizedBox(
                              width: double.infinity,
                              height: 6.h,
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : _handleMagicLink,
                                icon: _isLoading
                                    ? SizedBox(
                                        width: 4.w,
                                        height: 4.w,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            theme.colorScheme.onPrimary,
                                          ),
                                        ),
                                      )
                                    : const Icon(Icons.send),
                                label: Text(
                                  'ส่ง Magic Link',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            // Magic link sent confirmation
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: Colors.green.withAlpha(26),
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: Colors.green.withAlpha(77),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.mark_email_read,
                                    color: Colors.green,
                                    size: 40,
                                  ),
                                  SizedBox(height: 1.h),
                                  Text(
                                    'ส่งลิงก์เข้าสู่ระบบแล้ว!',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    'กรุณาตรวจสอบอีเมล ${_emailController.text.trim()} และคลิกลิงก์เพื่อเข้าสู่ระบบ',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.green.shade700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 1.5.h),
                                  TextButton(
                                    onPressed: () =>
                                        setState(() => _magicLinkSent = false),
                                    child: const Text('ส่งอีกครั้ง'),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          SizedBox(height: 4.h),

                          // Note: no registration
                          Text(
                            'ระบบนี้ไม่มีการสมัครสมาชิก\nเข้าสู่ระบบด้วย Social หรือ Magic Link เท่านั้น',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withAlpha(153),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 4.h),
                        ],
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
