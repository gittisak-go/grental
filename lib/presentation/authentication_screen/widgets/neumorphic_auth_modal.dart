import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../services/magic_link_auth_service.dart';
import '../../../services/supabase_service.dart';
import '../../../routes/app_routes.dart';

/// Neumorphic Auth Modal — shown as overlay when user taps "จองรถ"
/// No text input fields. 4 tactile buttons: Google, Facebook, LINE, Magic Link
class NeumorphicAuthModal extends StatefulWidget {
  final VoidCallback? onDismiss;
  final VoidCallback? onAuthSuccess;

  const NeumorphicAuthModal({super.key, this.onDismiss, this.onAuthSuccess});

  @override
  State<NeumorphicAuthModal> createState() => _NeumorphicAuthModalState();
}

class _NeumorphicAuthModalState extends State<NeumorphicAuthModal>
    with SingleTickerProviderStateMixin {
  static const Color _bgColor = Color(0xFFE0E5EC);
  static const Color _lightShadow = Color(0xFFFFFFFF);
  static const Color _darkShadow = Color(0xFFA3B1C6);
  static const Color _textColor = Color(0xFF4A5568);
  static const Color _accentBlue = Color(0xFF6B9FD4);

  bool _isLoading = false;
  String? _loadingButton;

  late AnimationController _entryController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  final MagicLinkAuthService _authService = MagicLinkAuthService();

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));
    _entryController.forward();

    // Listen for auth state changes
    _authService.authStateChanges.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn && mounted) {
        _authService.upsertUserRole().then((role) {
          if (mounted) {
            widget.onAuthSuccess?.call();
            Navigator.of(context).pop();
            if (role == 'Super_Admin' || role == 'Admin') {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.adminDashboardScreen,
              );
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogle() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _loadingButton = 'google';
    });
    HapticFeedback.mediumImpact();
    try {
      await SupabaseService.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://taxihouse1176.builtwithrocket.new',
      );
    } catch (e) {
      _showError('ไม่สามารถเข้าสู่ระบบด้วย Google ได้');
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
          _loadingButton = null;
        });
    }
  }

  Future<void> _handleFacebook() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _loadingButton = 'facebook';
    });
    HapticFeedback.mediumImpact();
    try {
      await SupabaseService.instance.client.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'https://taxihouse1176.builtwithrocket.new',
      );
    } catch (e) {
      _showError('ไม่สามารถเข้าสู่ระบบด้วย Facebook ได้');
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
          _loadingButton = null;
        });
    }
  }

  Future<void> _handleLine() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _loadingButton = 'line';
    });
    HapticFeedback.mediumImpact();
    try {
      // LINE OAuth — show magic link fallback for now
      _showInfo('กรุณาใช้ Magic Link สำหรับ LINE Login ในขณะนี้');
    } finally {
      if (mounted)
        setState(() {
          _isLoading = false;
          _loadingButton = null;
        });
    }
  }

  Future<void> _handleMagicLink() async {
    if (_isLoading) return;
    HapticFeedback.mediumImpact();
    // Show email input dialog
    _showMagicLinkDialog();
  }

  void _showMagicLinkDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _bgColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Magic Link',
          style: GoogleFonts.poppins(
            color: _textColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'กรอกอีเมลเพื่อรับลิงก์เข้าสู่ระบบ',
              style: GoogleFonts.poppins(color: _textColor, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildNeumorphicTextField(emailController),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'ยกเลิก',
              style: GoogleFonts.poppins(color: _textColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty ||
                  !RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(email)) {
                _showError('กรุณากรอกอีเมลที่ถูกต้อง');
                return;
              }
              Navigator.pop(ctx);
              setState(() {
                _isLoading = true;
                _loadingButton = 'magic';
              });
              try {
                await _authService.sendMagicLink(email);
                _showInfo('ส่งลิงก์ไปยัง $email แล้ว กรุณาตรวจสอบอีเมล');
              } catch (e) {
                _showError('ไม่สามารถส่งลิงก์ได้ กรุณาลองอีกครั้ง');
              } finally {
                if (mounted)
                  setState(() {
                    _isLoading = false;
                    _loadingButton = null;
                  });
              }
            },
            child: Text(
              'ส่งลิงก์',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeumorphicTextField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: _darkShadow, offset: Offset(3, 3), blurRadius: 8),
          BoxShadow(color: _lightShadow, offset: Offset(-3, -3), blurRadius: 8),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: GoogleFonts.poppins(color: _textColor, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'your@email.com',
          hintStyle: GoogleFonts.poppins(
            color: _textColor.withAlpha(128),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: _accentBlue,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showError(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: const Color(0xFFFF453A),
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showInfo(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: _accentBlue,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entryController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(scale: _scaleAnim, child: child),
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _darkShadow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'เข้าสู่ระบบง่ายๆ',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'เลือกช่องทางที่สะดวกเพื่อยืนยันการเช่า',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _textColor.withAlpha(166),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 36),

                // 2x2 Grid of Neumorphic buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NeumorphicAuthButton(
                      label: 'Google',
                      icon: _GoogleIcon(),
                      isLoading: _loadingButton == 'google',
                      onTap: _handleGoogle,
                    ),
                    _NeumorphicAuthButton(
                      label: 'Facebook',
                      icon: _FacebookIcon(),
                      isLoading: _loadingButton == 'facebook',
                      onTap: _handleFacebook,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NeumorphicAuthButton(
                      label: 'LINE',
                      icon: _LineIcon(),
                      isLoading: _loadingButton == 'line',
                      onTap: _handleLine,
                    ),
                    _NeumorphicAuthButton(
                      label: 'Magic Link',
                      icon: _MagicLinkIcon(),
                      isLoading: _loadingButton == 'magic',
                      onTap: _handleMagicLink,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Back button
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onDismiss?.call();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'กลับไปเลือกดูรถต่อ',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: _accentBlue,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: _accentBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Neumorphic Button Widget ───────────────────────────────────────────────

class _NeumorphicAuthButton extends StatefulWidget {
  final String label;
  final Widget icon;
  final bool isLoading;
  final VoidCallback onTap;

  const _NeumorphicAuthButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_NeumorphicAuthButton> createState() => _NeumorphicAuthButtonState();
}

class _NeumorphicAuthButtonState extends State<_NeumorphicAuthButton> {
  static const Color _bgColor = Color(0xFFE0E5EC);
  static const Color _lightShadow = Color(0xFFFFFFFF);
  static const Color _darkShadow = Color(0xFFA3B1C6);
  static const Color _textColor = Color(0xFF4A5568);

  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: _isPressed
                  ? [
                      // Inner shadow effect (pressed)
                      BoxShadow(
                        color: _darkShadow.withAlpha(153),
                        offset: const Offset(3, 3),
                        blurRadius: 6,
                      ),
                      const BoxShadow(
                        color: _lightShadow,
                        offset: Offset(-2, -2),
                        blurRadius: 4,
                      ),
                    ]
                  : [
                      // Outer shadow (raised)
                      BoxShadow(
                        color: _darkShadow.withAlpha(179),
                        offset: const Offset(6, 6),
                        blurRadius: 15,
                      ),
                      const BoxShadow(
                        color: _lightShadow,
                        offset: Offset(-6, -6),
                        blurRadius: 15,
                      ),
                    ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFF6B9FD4),
                      ),
                    )
                  : widget.icon,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 12,
              color: _textColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Brand Icons ─────────────────────────────────────────────────────────────

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw Google 'G' using colored arcs
    final paintBlue = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final paintRed = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final paintYellow = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final paintGreen = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius - 2);

    // Top arc (red)
    canvas.drawArc(rect, -2.4, 1.6, false, paintRed);
    // Right arc (blue)
    canvas.drawArc(rect, -0.8, 1.6, false, paintBlue);
    // Bottom arc (green)
    canvas.drawArc(rect, 0.8, 1.6, false, paintGreen);
    // Left arc (yellow)
    canvas.drawArc(rect, 2.4, 1.6, false, paintYellow);

    // Horizontal bar for 'G'
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx + radius - 2, center.dy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FacebookIcon extends StatelessWidget {
  const _FacebookIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF1877F2).withAlpha(217),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'f',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

class _LineIcon extends StatelessWidget {
  const _LineIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF00C300).withAlpha(230),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.chat_bubble, color: Colors.white, size: 20),
      ),
    );
  }
}

class _MagicLinkIcon extends StatelessWidget {
  const _MagicLinkIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B9FD4), Color(0xFF9B59B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(Icons.bolt, color: Colors.white, size: 22),
      ),
    );
  }
}
