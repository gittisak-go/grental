import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

/// Elegant loading indicator with pulsing animation
class LoadingIndicatorWidget extends StatefulWidget {
  const LoadingIndicatorWidget({super.key});

  @override
  State<LoadingIndicatorWidget> createState() => _LoadingIndicatorWidgetState();
}

class _LoadingIndicatorWidgetState extends State<LoadingIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializePulseAnimation();
  }

  void _initializePulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: _pulseAnimation.value),
              ),
              child: Center(
                child: Container(
                  width: 4.w,
                  height: 4.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Opacity(
              opacity: _pulseAnimation.value,
              child: Text(
                'Initializing services...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
