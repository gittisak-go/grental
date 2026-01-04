import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RequestRideButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final String buttonText;

  const RequestRideButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.buttonText = 'Request Ride',
  });

  @override
  State<RequestRideButton> createState() => _RequestRideButtonState();
}

class _RequestRideButtonState extends State<RequestRideButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing calculations
    final horizontalMargin = screenWidth * 0.04;
    final verticalMargin = screenHeight * 0.015;
    final buttonHeight = screenHeight * 0.065;
    final iconSize = screenWidth * 0.06;
    final horizontalPadding = screenWidth * 0.06;
    final verticalPadding = screenHeight * 0.018;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalMargin,
        vertical: verticalMargin,
      ),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              elevation: widget.isEnabled && !_isPressed ? 6 : 2,
              borderRadius: BorderRadius.circular(16),
              shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
              child: InkWell(
                onTap:
                    widget.isEnabled && !widget.isLoading ? _handlePress : null,
                onTapDown: widget.isEnabled && !widget.isLoading
                    ? (_) => _onTapDown()
                    : null,
                onTapUp: widget.isEnabled && !widget.isLoading
                    ? (_) => _onTapUp()
                    : null,
                onTapCancel: widget.isEnabled && !widget.isLoading
                    ? () => _onTapUp()
                    : null,
                borderRadius: BorderRadius.circular(16),
                splashColor: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                highlightColor:
                    theme.colorScheme.onPrimary.withValues(alpha: 0.1),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: widget.isEnabled
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withValues(alpha: 0.85),
                            ],
                          )
                        : null,
                    color: widget.isEnabled
                        ? null
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    height: buttonHeight,
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: widget.isLoading
                        ? _buildLoadingContent(theme, screenWidth)
                        : _buildButtonContent(theme, iconSize, screenWidth),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtonContent(
      ThemeData theme, double iconSize, double screenWidth) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'chat',
            color: widget.isEnabled
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            size: iconSize,
          ),
          SizedBox(width: screenWidth * 0.03),
          Text(
            widget.buttonText,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: widget.isEnabled
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
              fontSize: screenWidth * 0.04,
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          CustomIconWidget(
            iconName: 'arrow_forward',
            color: widget.isEnabled
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            size: iconSize * 0.85,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent(ThemeData theme, double screenWidth) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: screenWidth * 0.05,
            height: screenWidth * 0.05,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.onPrimary,
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Text(
            'กำลังเปิด Messenger...',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onPrimary,
              fontSize: screenWidth * 0.038,
            ),
          ),
        ],
      ),
    );
  }

  void _onTapDown() {
    setState(() => _isPressed = true);
    _animationController.forward();
    HapticFeedback.selectionClick();
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handlePress() {
    HapticFeedback.mediumImpact();
    widget.onPressed?.call();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
