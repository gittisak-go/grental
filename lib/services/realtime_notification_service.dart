import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_notification_model.dart';
import './supabase_service.dart';

class RealtimeNotificationService {
  static RealtimeNotificationService? _instance;
  static RealtimeNotificationService get instance =>
      _instance ??= RealtimeNotificationService._();

  RealtimeNotificationService._();

  final _supabase = SupabaseService.instance.client;

  RealtimeChannel? _notificationsChannel;
  RealtimeChannel? _reservationsChannel;
  RealtimeChannel? _vehiclesChannel;

  final List<AppNotificationModel> _notifications = [];
  final List<Function(AppNotificationModel)> _listeners = [];
  final List<Function(int)> _unreadCountListeners = [];

  List<AppNotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Start all real-time subscriptions
  Future<void> startListening() async {
    final userId = _currentUserId;
    if (userId == null) return;

    await _loadExistingNotifications(userId);
    _subscribeToAppNotifications(userId);
    _subscribeToReservations(userId);
    _subscribeToVehicles();
  }

  /// Stop all real-time subscriptions
  Future<void> stopListening() async {
    await _notificationsChannel?.unsubscribe();
    await _reservationsChannel?.unsubscribe();
    await _vehiclesChannel?.unsubscribe();
    _notificationsChannel = null;
    _reservationsChannel = null;
    _vehiclesChannel = null;
    _notifications.clear();
    _listeners.clear();
    _unreadCountListeners.clear();
  }

  /// Load existing unread notifications from database
  Future<void> _loadExistingNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('app_notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false)
          .order('created_at', ascending: false)
          .limit(50);

      _notifications.clear();
      for (final json in response as List) {
        _notifications.add(AppNotificationModel.fromJson(json));
      }
      _notifyUnreadCountListeners();
    } catch (e) {
      debugPrint('Failed to load notifications: $e');
    }
  }

  /// Subscribe to app_notifications table for new notifications
  void _subscribeToAppNotifications(String userId) {
    _notificationsChannel = _supabase
        .channel('app_notifications_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'app_notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            try {
              final newRecord = payload.newRecord;
              if (newRecord.isNotEmpty) {
                final notification = AppNotificationModel.fromJson(newRecord);
                _notifications.insert(0, notification);
                _notifyListeners(notification);
                _notifyUnreadCountListeners();
              }
            } catch (e) {
              debugPrint('Error processing new notification: $e');
            }
          },
        )
        .subscribe();
  }

  /// Subscribe to reservations table for booking/rental status changes
  void _subscribeToReservations(String userId) {
    _reservationsChannel = _supabase
        .channel('reservations_notify_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'reservations',
          callback: (payload) {
            try {
              final newRecord = payload.newRecord;
              final oldRecord = payload.oldRecord;
              if (newRecord.isNotEmpty) {
                _handleReservationChange(newRecord, oldRecord);
              }
            } catch (e) {
              debugPrint('Error processing reservation change: $e');
            }
          },
        )
        .subscribe();
  }

  /// Subscribe to vehicles table for availability changes
  void _subscribeToVehicles() {
    _vehiclesChannel = _supabase
        .channel('vehicles_availability')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'vehicles',
          callback: (payload) {
            try {
              final newRecord = payload.newRecord;
              final oldRecord = payload.oldRecord;
              if (newRecord.isNotEmpty) {
                _handleVehicleChange(newRecord, oldRecord);
              }
            } catch (e) {
              debugPrint('Error processing vehicle change: $e');
            }
          },
        )
        .subscribe();
  }

  void _handleReservationChange(
    Map<String, dynamic> newRecord,
    Map<String, dynamic> oldRecord,
  ) {
    final newStatus = newRecord['status'] as String?;
    final oldStatus = oldRecord['status'] as String?;

    if (newStatus == oldStatus) return;

    AppNotificationType? type;
    String? title;
    String? body;

    switch (newStatus) {
      case 'confirmed':
        type = AppNotificationType.bookingConfirmed;
        title = 'Booking Confirmed';
        body = 'Your rental booking has been confirmed and is ready.';
        break;
      case 'active':
        type = AppNotificationType.rentalActive;
        title = 'Rental Started';
        body = 'Your rental is now active. Enjoy your ride!';
        break;
      case 'completed':
        type = AppNotificationType.rentalCompleted;
        title = 'Rental Completed';
        body = 'Your rental has been completed. Thank you!';
        break;
      case 'cancelled':
        type = AppNotificationType.bookingCancelled;
        title = 'Booking Cancelled';
        body = 'Your booking has been cancelled.';
        break;
      default:
        return;
    }

    final localNotification = AppNotificationModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUserId ?? '',
      notificationType: newStatus!,
      title: title,
      body: body,
      referenceId: newRecord['id'] as String?,
      referenceTable: 'reservations',
      isRead: false,
      createdAt: DateTime.now(),
    );
    _notifyListeners(localNotification);
    }

  void _handleVehicleChange(
    Map<String, dynamic> newRecord,
    Map<String, dynamic> oldRecord,
  ) {
    final newAvailable = newRecord['is_available'] as bool?;
    final oldAvailable = oldRecord['is_available'] as bool?;

    if (newAvailable == true && oldAvailable == false) {
      final vehicleName = newRecord['name'] as String? ?? 'A vehicle';
      final localNotification = AppNotificationModel(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentUserId ?? '',
        notificationType: 'vehicle_available',
        title: 'Vehicle Now Available',
        body: '$vehicleName is now available for rental.',
        referenceId: newRecord['id'] as String?,
        referenceTable: 'vehicles',
        isRead: false,
        createdAt: DateTime.now(),
      );
      _notifyListeners(localNotification);
    }
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      if (!notificationId.startsWith('local_')) {
        await _supabase
            .from('app_notifications')
            .update({'is_read': true}).eq('id', notificationId);
      }
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _notifyUnreadCountListeners();
      }
    } catch (e) {
      debugPrint('Failed to mark notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final userId = _currentUserId;
      if (userId != null) {
        await _supabase
            .from('app_notifications')
            .update({'is_read': true})
            .eq('user_id', userId)
            .eq('is_read', false);
      }
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
      _notifyUnreadCountListeners();
    } catch (e) {
      debugPrint('Failed to mark all notifications as read: $e');
    }
  }

  /// Fetch all notifications (including read) for display
  Future<List<AppNotificationModel>> fetchAllNotifications() async {
    try {
      final userId = _currentUserId;
      if (userId == null) return [];

      final response = await _supabase
          .from('app_notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(100);

      return (response as List)
          .map((json) => AppNotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Failed to fetch all notifications: $e');
      return [];
    }
  }

  /// Add a listener for new notifications (for in-app banners)
  void addNotificationListener(Function(AppNotificationModel) listener) {
    _listeners.add(listener);
  }

  /// Remove a notification listener
  void removeNotificationListener(Function(AppNotificationModel) listener) {
    _listeners.remove(listener);
  }

  /// Add a listener for unread count changes
  void addUnreadCountListener(Function(int) listener) {
    _unreadCountListeners.add(listener);
  }

  /// Remove unread count listener
  void removeUnreadCountListener(Function(int) listener) {
    _unreadCountListeners.remove(listener);
  }

  void _notifyListeners(AppNotificationModel notification) {
    for (final listener in List.from(_listeners)) {
      listener(notification);
    }
  }

  void _notifyUnreadCountListeners() {
    for (final listener in List.from(_unreadCountListeners)) {
      listener(unreadCount);
    }
  }
}
