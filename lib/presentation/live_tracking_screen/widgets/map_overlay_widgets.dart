import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MapTopOverlay extends StatelessWidget {
  final String rideId;
  final String eta;
  final VoidCallback? onEmergencyPressed;
  final VoidCallback? onBackPressed;

  const MapTopOverlay({
    super.key,
    required this.rideId,
    required this.eta,
    this.onEmergencyPressed,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 2.h,
      left: 4.w,
      right: 4.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              icon: CustomIconWidget(
                iconName: 'arrow_back_ios',
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
              padding: EdgeInsets.zero,
            ),
          ),

          // Ride Info Card
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rideId,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryLight,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'access_time',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 14,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      eta,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Emergency Button
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: AppTheme.errorLight.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.errorLight.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: onEmergencyPressed,
              icon: CustomIconWidget(
                iconName: 'emergency',
                color: theme.colorScheme.onError,
                size: 20,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class MapFloatingActionButton extends StatefulWidget {
  final VoidCallback? onMyLocationPressed;
  final VoidCallback? onNavigationPressed;

  const MapFloatingActionButton({
    super.key,
    this.onMyLocationPressed,
    this.onNavigationPressed,
  });

  @override
  State<MapFloatingActionButton> createState() =>
      _MapFloatingActionButtonState();
}

class _MapFloatingActionButtonState extends State<MapFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      right: 4.w,
      bottom: 45.h,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Navigation Button
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: widget.onNavigationPressed,
                    icon: CustomIconWidget(
                      iconName: 'navigation',
                      color: AppTheme.primaryLight,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              );
            },
          ),

          // My Location Button
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: widget.onMyLocationPressed,
                    icon: CustomIconWidget(
                      iconName: 'my_location',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              );
            },
          ),

          // Main FAB
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryLight.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _toggleExpansion,
              icon: AnimatedRotation(
                turns: _isExpanded ? 0.125 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: CustomIconWidget(
                  iconName: _isExpanded ? 'close' : 'more_vert',
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingSearchAnimation extends StatefulWidget {
  final String message;

  const LoadingSearchAnimation({
    super.key,
    this.message = "Finding your driver...",
  });

  @override
  State<LoadingSearchAnimation> createState() => _LoadingSearchAnimationState();
}

class _LoadingSearchAnimationState extends State<LoadingSearchAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation:
                  Listenable.merge([_pulseAnimation, _rotationAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value * 2 * 3.14159,
                    child: Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryLight,
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'local_taxi',
                          color: AppTheme.primaryLight,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 4.h),
            Text(
              widget.message,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              "This may take a few moments",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
