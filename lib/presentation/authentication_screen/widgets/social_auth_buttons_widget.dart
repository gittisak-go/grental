import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/foundation.dart';


/// Social authentication buttons widget with support for Google, Facebook, and Apple sign-in
class SocialAuthButtonsWidget extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onFacebookPressed;
  final VoidCallback onApplePressed;

  const SocialAuthButtonsWidget({
    super.key,
    required this.onGooglePressed,
    required this.onFacebookPressed,
    required this.onApplePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: theme.colorScheme.onSurfaceVariant.withAlpha(77),
                thickness: 1.0,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Text(
                'หรือเข้าสู่ระบบด้วย',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: theme.colorScheme.onSurfaceVariant.withAlpha(77),
                thickness: 1.0,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Social authentication buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Sign In Button
            _SocialAuthButton(
              onPressed: onGooglePressed,
              iconUrl:
                  'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/google/google-original.svg',
              label: 'Google',
              backgroundColor: Colors.white,
              borderColor: theme.colorScheme.outline.withAlpha(128),
            ),

            SizedBox(width: 4.w),

            // Facebook Sign In Button
            _SocialAuthButton(
              onPressed: onFacebookPressed,
              iconUrl:
                  'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/facebook/facebook-original.svg',
              label: 'Facebook',
              backgroundColor: const Color(0xFF1877F2),
              borderColor: const Color(0xFF1877F2),
              isWhiteIcon: true,
            ),

            // Only show Apple Sign In on iOS/macOS
            if (!kIsWeb &&
                (Theme.of(context).platform == TargetPlatform.iOS ||
                    Theme.of(context).platform == TargetPlatform.macOS)) ...[
              SizedBox(width: 4.w),
              _SocialAuthButton(
                onPressed: onApplePressed,
                iconUrl:
                    'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/apple/apple-original.svg',
                label: 'Apple',
                backgroundColor: Colors.black,
                borderColor: Colors.black,
                isWhiteIcon: true,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Individual social authentication button
class _SocialAuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String iconUrl;
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final bool isWhiteIcon;

  const _SocialAuthButton({
    required this.onPressed,
    required this.iconUrl,
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    this.isWhiteIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          width: 25.w,
          height: 6.h,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Center(
            child: Image.network(
              iconUrl,
              width: 6.w,
              height: 6.w,
              color: isWhiteIcon ? Colors.white : null,
              semanticLabel: '$label sign in icon',
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.login,
                  size: 6.w,
                  color: isWhiteIcon ? Colors.white : theme.colorScheme.primary,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
