import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/app_notification_model.dart';
import '../../../services/realtime_notification_service.dart';

class NotificationInboxWidget extends StatefulWidget {
  const NotificationInboxWidget({Key? key}) : super(key: key);

  @override
  State<NotificationInboxWidget> createState() =>
      _NotificationInboxWidgetState();
}

class _NotificationInboxWidgetState extends State<NotificationInboxWidget> {
  final _service = RealtimeNotificationService.instance;
  List<AppNotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _service.addUnreadCountListener(_onUnreadCountChanged);
  }

  @override
  void dispose() {
    _service.removeUnreadCountListener(_onUnreadCountChanged);
    super.dispose();
  }

  void _onUnreadCountChanged(int count) {
    if (mounted) setState(() {});
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final all = await _service.fetchAllNotifications();
    if (mounted) {
      setState(() {
        _notifications = all;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllRead() async {
    await _service.markAllAsRead();
    await _loadNotifications();
  }

  Color _getTypeColor(AppNotificationType type) {
    if (type.isPositive) return Colors.green.shade600;
    switch (type) {
      case AppNotificationType.paymentFailed:
        return Colors.red.shade600;
      case AppNotificationType.bookingCancelled:
        return Colors.orange.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  IconData _getTypeIcon(AppNotificationType type) {
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

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _service.unreadCount;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            child: Row(
              children: [
                Icon(Icons.notifications,
                    size: 20.sp, color: Colors.blue.shade700),
                SizedBox(width: 2.w),
                Text(
                  'Recent Notifications',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (unreadCount > 0) ...[
                  SizedBox(width: 2.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (unreadCount > 0)
                  TextButton(
                    onPressed: _markAllRead,
                    child: Text(
                      'Mark all read',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: _loadNotifications,
                  icon: Icon(Icons.refresh,
                      size: 18.sp, color: Colors.grey.shade600),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _isLoading
              ? Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                    ),
                  ),
                )
              : _notifications.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 28.sp,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'No notifications yet',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _notifications.length > 10
                          ? 10
                          : _notifications.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final notif = _notifications[index];
                        final type = AppNotificationModel.getType(
                            notif.notificationType);
                        final color = _getTypeColor(type);
                        return InkWell(
                          onTap: () async {
                            if (!notif.isRead) {
                              await _service.markAsRead(notif.id);
                              await _loadNotifications();
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.2.h,
                            ),
                            color: notif.isRead
                                ? Colors.transparent
                                : Colors.blue.shade50.withAlpha(128),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(1.5.w),
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(26),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Icon(
                                    _getTypeIcon(type),
                                    color: color,
                                    size: 16.sp,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notif.title,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: notif.isRead
                                                    ? FontWeight.w500
                                                    : FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (!notif.isRead)
                                            Container(
                                              width: 2.w,
                                              height: 2.w,
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade700,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 0.3.h),
                                      Text(
                                        notif.body,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 0.3.h),
                                      Text(
                                        _formatTime(notif.createdAt),
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}
