import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Elegant app logo widget with boutique design aesthetics
class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Logo container with soft yellow accent
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'local_taxi',
              color: theme.colorScheme.primary,
              size: 10.w,
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // App name with premium typography
        Text(
          'TaxiHouse',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),

        SizedBox(height: 0.5.h),

        // Tagline
        Text(
          'Your premium ride awaits',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
