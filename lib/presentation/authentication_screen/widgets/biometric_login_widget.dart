import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Biometric authentication widget for premium login experience
class BiometricLoginWidget extends StatelessWidget {
  const BiometricLoginWidget({
    super.key,
    required this.onBiometricLogin,
  });

  final VoidCallback onBiometricLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Elegant divider with text
        Row(
          children: [
            Expanded(
              child: Container(
                height: 0.5,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Or continue with',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 0.5,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Biometric login button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onBiometricLogin();
          },
          child: Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'fingerprint',
                color: theme.colorScheme.primary,
                size: 6.w,
              ),
            ),
          ),
        ),

        SizedBox(height: 1.h),

        Text(
          'Touch ID / Face ID',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
