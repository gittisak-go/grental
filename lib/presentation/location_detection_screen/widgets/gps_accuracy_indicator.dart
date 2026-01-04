import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// GPS accuracy indicator widget with color-coded feedback
class GpsAccuracyIndicator extends StatefulWidget {
  const GpsAccuracyIndicator({
    super.key,
    required this.accuracy,
    this.isVisible = true,
  });

  final double accuracy; // Accuracy in meters
  final bool isVisible;

  @override
  State<GpsAccuracyIndicator> createState() => _GpsAccuracyIndicatorState();
}

class _GpsAccuracyIndicatorState extends State<GpsAccuracyIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(GpsAccuracyIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getAccuracyColor() {
    if (widget.accuracy <= 5) {
      return AppTheme.successLight; // Excellent accuracy
    } else if (widget.accuracy <= 15) {
      return AppTheme.primaryLight; // Good accuracy
    } else if (widget.accuracy <= 50) {
      return AppTheme.warningLight; // Fair accuracy
    } else {
      return AppTheme.errorLight; // Poor accuracy
    }
  }

  String _getAccuracyText() {
    if (widget.accuracy <= 5) {
      return 'Excellent GPS Signal';
    } else if (widget.accuracy <= 15) {
      return 'Good GPS Signal';
    } else if (widget.accuracy <= 50) {
      return 'Fair GPS Signal';
    } else {
      return 'Poor GPS Signal';
    }
  }

  IconData _getAccuracyIcon() {
    if (widget.accuracy <= 5) {
      return Icons.gps_fixed;
    } else if (widget.accuracy <= 15) {
      return Icons.gps_fixed;
    } else if (widget.accuracy <= 50) {
      return Icons.gps_not_fixed;
    } else {
      return Icons.gps_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accuracyColor = _getAccuracyColor();

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _fadeAnimation.value) * 20),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accuracyColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: _getAccuracyIcon().codePoint.toString(),
                      color: accuracyColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getAccuracyText(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: accuracyColor,
                        ),
                      ),
                      Text(
                        '±${widget.accuracy.toStringAsFixed(0)}m accuracy',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
