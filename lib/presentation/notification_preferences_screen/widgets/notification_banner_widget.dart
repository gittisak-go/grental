import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/app_notification_model.dart';

class NotificationBannerWidget extends StatefulWidget {
  final AppNotificationModel notification;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  const NotificationBannerWidget({
    Key? key,
    required this.notification,
    required this.onDismiss,
    this.onTap,
  }) : super(key: key);

  @override
  State<NotificationBannerWidget> createState() =>
      _NotificationBannerWidgetState();
}

class _NotificationBannerWidgetState extends State<NotificationBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _dismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  Color get _bannerColor {
    final type =
        AppNotificationModel.getType(widget.notification.notificationType);
    if (type.isPositive) return Colors.green.shade700;
    switch (type) {
      case AppNotificationType.paymentFailed:
        return Colors.red.shade700;
      case AppNotificationType.bookingCancelled:
        return Colors.orange.shade700;
      default:
        return Colors.blue.shade700;
    }
  }

  IconData get _bannerIcon {
    final type =
        AppNotificationModel.getType(widget.notification.notificationType);
    switch (type) {
      case AppNotificationType.vehicleAvailable:
        return Icons.directions_car;
      case AppNotificationType.bookingConfirmed:
        return Icons.check_circle;
      case AppNotificationType.bookingCancelled:
        return Icons.cancel;
      case AppNotificationType.bookingModified:
        return Icons.edit_note;
      case AppNotificationType.rentalActive:
        return Icons.play_circle;
      case AppNotificationType.rentalCompleted:
        return Icons.flag;
      case AppNotificationType.paymentSuccess:
        return Icons.payment;
      case AppNotificationType.paymentFailed:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: () {
            widget.onTap?.call();
            _dismiss();
          },
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! < -100) {
              _dismiss();
            }
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: _bannerColor,
              borderRadius: BorderRadius.circular(14.0),
              boxShadow: [
                BoxShadow(
                  color: _bannerColor.withAlpha(102),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Icon(_bannerIcon, color: Colors.white, size: 18.sp),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.notification.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.3.h),
                      Text(
                        widget.notification.body,
                        style: TextStyle(
                          color: Colors.white.withAlpha(230),
                          fontSize: 11.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                GestureDetector(
                  onTap: _dismiss,
                  child: Icon(
                    Icons.close,
                    color: Colors.white.withAlpha(204),
                    size: 16.sp,
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
