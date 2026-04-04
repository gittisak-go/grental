import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Social authentication buttons widget — Google, Facebook, LINE
class SocialAuthButtonsWidget extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onFacebookPressed;
  final VoidCallback onLinePressed;
  final bool isLoading;

  const SocialAuthButtonsWidget({
    super.key,
    required this.onGooglePressed,
    required this.onFacebookPressed,
    required this.onLinePressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          'เข้าสู่ระบบด้วย Social',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        // Google button
        _SocialLoginButton(
          onPressed: isLoading ? null : onGooglePressed,
          label: 'เข้าสู่ระบบด้วย Google',
          iconUrl:
              'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/google/google-original.svg',
          backgroundColor: Colors.white,
          textColor: Colors.black87,
          borderColor: theme.colorScheme.outline.withAlpha(128),
        ),
        SizedBox(height: 1.5.h),
        // Facebook button
        _SocialLoginButton(
          onPressed: isLoading ? null : onFacebookPressed,
          label: 'เข้าสู่ระบบด้วย Facebook',
          iconUrl:
              'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/facebook/facebook-original.svg',
          backgroundColor: const Color(0xFF1877F2),
          textColor: Colors.white,
          borderColor: const Color(0xFF1877F2),
          isWhiteIcon: true,
        ),
        SizedBox(height: 1.5.h),
        // LINE button
        _SocialLoginButton(
          onPressed: isLoading ? null : onLinePressed,
          label: 'เข้าสู่ระบบด้วย LINE',
          iconWidget: Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Center(
              child: Text(
                'L',
                style: TextStyle(
                  color: const Color(0xFF00B900),
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
          backgroundColor: const Color(0xFF00B900),
          textColor: Colors.white,
          borderColor: const Color(0xFF00B900),
        ),
      ],
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final String? iconUrl;
  final Widget? iconWidget;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final bool isWhiteIcon;

  const _SocialLoginButton({
    required this.onPressed,
    required this.label,
    this.iconUrl,
    this.iconWidget,
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
    this.isWhiteIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 1.5),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (iconWidget != null)
                  iconWidget!
                else if (iconUrl != null)
                  Image.network(
                    iconUrl!,
                    width: 6.w,
                    height: 6.w,
                    color: isWhiteIcon ? Colors.white : null,
                    semanticLabel: '$label icon',
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.login,
                        size: 6.w,
                        color: isWhiteIcon
                            ? Colors.white
                            : theme.colorScheme.primary,
                      );
                    },
                  ),
                SizedBox(width: 3.w),
                Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
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
