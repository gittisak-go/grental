import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


/// Elegant app logo widget with boutique design aesthetics
class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Logo container with soft accent
        Container(
          width: 35.w,
          height: 35.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/Rungroj_Car_Rental-logo-1767574577173.png',
              fit: BoxFit.contain,
              semanticLabel: 'Rungroj Car Rental logo',
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // App name with premium typography
        Text(
          'RungrojCarRental',
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
