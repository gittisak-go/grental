import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

/// Custom animated location pin widget with pulsing animation
class LocationPinWidget extends StatefulWidget {
  const LocationPinWidget({
    super.key,
    this.isActive = false,
    this.onTap,
    this.size = 48.0,
  });

  final bool isActive;
  final VoidCallback? onTap;
  final double size;

  @override
  State<LocationPinWidget> createState() => _LocationPinWidgetState();
}

class _LocationPinWidgetState extends State<LocationPinWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for active state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.8,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Bounce animation for tap feedback
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LocationPinWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _bounceAnimation]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing ring for active state
              if (widget.isActive)
                Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: widget.size * 1.2,
                    height: widget.size * 1.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryLight.withValues(alpha: 0.2),
                      border: Border.all(
                        color: AppTheme.primaryLight.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                  ),
                ),

              // Main pin container
              Transform.scale(
                scale: _bounceAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: widget.size * 0.6,
                      height: widget.size * 0.6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isActive
                            ? AppTheme.primaryLight
                            : theme.colorScheme.primary,
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'location_on',
                          color: theme.colorScheme.onPrimary,
                          size: widget.size * 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
