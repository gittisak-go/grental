import '../models/notification_preference_model.dart';
import './supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationPreferenceService {
  final _supabase = SupabaseService.instance.client;

  /// Get current user ID
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Subscribe to real-time changes for notification preferences
  RealtimeChannel subscribeToPreferenceChanges({
    required String userId,
    required Function(PostgresChangePayload) onUpdate,
  }) {
    final channel = _supabase
        .channel('notification_preferences_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notification_preferences',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            onUpdate(payload);
          },
        )
        .subscribe();

    return channel;
  }

  /// Fetch all notification preferences for the current user
  Future<List<NotificationPreferenceModel>> getUserPreferences() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('notification_preferences')
          .select()
          .eq('user_id', userId)
          .order('category');

      return (response as List)
          .map((json) => NotificationPreferenceModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notification preferences: $e');
    }
  }

  /// Update a specific notification preference
  Future<NotificationPreferenceModel> updatePreference({
    required String preferenceId,
    bool? isEnabled,
    List<String>? deliveryMethods,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};

      if (isEnabled != null) updateData['is_enabled'] = isEnabled;
      if (deliveryMethods != null)
        updateData['delivery_methods'] = deliveryMethods;
      if (quietHoursStart != null)
        updateData['quiet_hours_start'] = quietHoursStart;
      if (quietHoursEnd != null) updateData['quiet_hours_end'] = quietHoursEnd;

      final response = await _supabase
          .from('notification_preferences')
          .update(updateData)
          .eq('id', preferenceId)
          .select()
          .single();

      return NotificationPreferenceModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update notification preference: $e');
    }
  }

  /// Toggle notification preference on/off
  Future<NotificationPreferenceModel> togglePreference(
    String preferenceId,
    bool newValue,
  ) async {
    return updatePreference(preferenceId: preferenceId, isEnabled: newValue);
  }

  /// Update delivery methods for a preference
  Future<NotificationPreferenceModel> updateDeliveryMethods(
    String preferenceId,
    List<String> methods,
  ) async {
    return updatePreference(
      preferenceId: preferenceId,
      deliveryMethods: methods,
    );
  }

  /// Update quiet hours for all preferences
  Future<void> updateQuietHours(String? startTime, String? endTime) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('notification_preferences')
          .update({'quiet_hours_start': startTime, 'quiet_hours_end': endTime})
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to update quiet hours: $e');
    }
  }

  /// Disable all notifications
  Future<void> disableAllNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('notification_preferences')
          .update({'is_enabled': false})
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to disable all notifications: $e');
    }
  }

  /// Enable all notifications
  Future<void> enableAllNotifications() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('notification_preferences')
          .update({'is_enabled': true})
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to enable all notifications: $e');
    }
  }

  /// Get preferences grouped by category
  Map<String, List<NotificationPreferenceModel>> groupPreferencesByCategory(
    List<NotificationPreferenceModel> preferences,
  ) {
    final Map<String, List<NotificationPreferenceModel>> grouped = {
      'Booking Notifications': [],
      'Payment Notifications': [],
      'Driver Communication': [],
      'Marketing & Updates': [],
    };

    for (var pref in preferences) {
      if (pref.category.startsWith('booking_')) {
        grouped['Booking Notifications']!.add(pref);
      } else if (pref.category.startsWith('payment_')) {
        grouped['Payment Notifications']!.add(pref);
      } else if (pref.category.startsWith('driver_')) {
        grouped['Driver Communication']!.add(pref);
      } else if (pref.category.startsWith('marketing_') ||
          pref.category == 'feature_announcements') {
        grouped['Marketing & Updates']!.add(pref);
      }
    }

    return grouped;
  }
}