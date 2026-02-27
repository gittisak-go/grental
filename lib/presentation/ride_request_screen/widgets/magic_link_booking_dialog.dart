import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/magic_link_auth_service.dart';

class MagicLinkBookingDialog extends StatefulWidget {
  final VoidCallback onAuthSuccess;

  const MagicLinkBookingDialog({super.key, required this.onAuthSuccess});

  @override
  State<MagicLinkBookingDialog> createState() => _MagicLinkBookingDialogState();
}

class _MagicLinkBookingDialogState extends State<MagicLinkBookingDialog> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = MagicLinkAuthService();

  bool _isLoading = false;
  bool _linkSent = false;
  String? _errorMessage;
  String? _detectedRole;

  @override
  void initState() {
    super.initState();
    // If already authenticated, proceed
    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        widget.onAuthSuccess();
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    final email = value.trim().toLowerCase();
    setState(() {
      _detectedRole =
          email.isNotEmpty ? MagicLinkAuthService.getUserRole(email) : null;
      _errorMessage = null;
    });
  }

  Future<void> _sendMagicLink() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim().toLowerCase();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.sendMagicLink(email);
      if (mounted) {
        setState(() {
          _linkSent = true;
          _isLoading = false;
        });
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.lock_open_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'เข้าสู่ระบบเพื่อจอง',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Magic Link ผ่านอีเมล',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (!_linkSent) ...[
                Text(
                  'กรอกอีเมลของคุณ เราจะส่ง Magic Link ให้คุณเข้าสู่ระบบโดยไม่ต้องใช้รหัสผ่าน',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    onChanged: _onEmailChanged,
                    decoration: InputDecoration(
                      labelText: 'อีเมล',
                      hintText: 'example@email.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: _detectedRole != null
                          ? Tooltip(
                              message: 'สถานะ: $_detectedRole',
                              child: Icon(
                                _detectedRole == 'Super_Admin'
                                    ? Icons.admin_panel_settings
                                    : Icons.person,
                                color: _detectedRole == 'Super_Admin'
                                    ? Colors.amber.shade700
                                    : theme.colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'กรุณากรอกอีเมล';
                      }
                      final emailRegex =
                          RegExp(r'^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'รูปแบบอีเมลไม่ถูกต้อง';
                      }
                      return null;
                    },
                  ),
                ),

                // Role badge
                if (_detectedRole != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _detectedRole == 'Super_Admin'
                          ? Colors.amber.withValues(alpha: 0.15)
                          : theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _detectedRole == 'Super_Admin'
                            ? Colors.amber.shade700
                            : theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _detectedRole == 'Super_Admin'
                              ? Icons.admin_panel_settings
                              : Icons.person,
                          size: 16,
                          color: _detectedRole == 'Super_Admin'
                              ? Colors.amber.shade700
                              : theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'สถานะ: $_detectedRole',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _detectedRole == 'Super_Admin'
                                ? Colors.amber.shade800
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: theme.colorScheme.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendMagicLink,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'ส่ง Magic Link',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                  ),
                ),
              ] else ...[
                // Link sent state
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_read_outlined,
                          size: 48,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'ส่ง Magic Link แล้ว!',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'กรุณาตรวจสอบอีเมล\n${_emailController.text.trim()}\nแล้วคลิกลิงก์เพื่อเข้าสู่ระบบ',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _linkSent = false;
                            _emailController.clear();
                            _detectedRole = null;
                          });
                        },
                        child: const Text('ส่งอีกครั้ง'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
