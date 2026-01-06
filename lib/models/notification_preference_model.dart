class NotificationPreferenceModel {
  final String id;
  final String userId;
  final String category;
  final bool isEnabled;
  final List<String> deliveryMethods;
  final String? quietHoursStart;
  final String? quietHoursEnd;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationPreferenceModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.isEnabled,
    required this.deliveryMethods,
    this.quietHoursStart,
    this.quietHoursEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      category: json['category'] as String,
      isEnabled: json['is_enabled'] as bool,
      deliveryMethods:
          (json['delivery_methods'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      quietHoursStart: json['quiet_hours_start'] as String?,
      quietHoursEnd: json['quiet_hours_end'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category': category,
      'is_enabled': isEnabled,
      'delivery_methods': deliveryMethods,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  NotificationPreferenceModel copyWith({
    String? id,
    String? userId,
    String? category,
    bool? isEnabled,
    List<String>? deliveryMethods,
    String? quietHoursStart,
    String? quietHoursEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationPreferenceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      isEnabled: isEnabled ?? this.isEnabled,
      deliveryMethods: deliveryMethods ?? this.deliveryMethods,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NotificationCategory {
  static const String bookingConfirmations = 'booking_confirmations';
  static const String bookingModifications = 'booking_modifications';
  static const String bookingCancellations = 'booking_cancellations';
  static const String paymentSuccess = 'payment_success';
  static const String paymentFailed = 'payment_failed';
  static const String paymentRefunds = 'payment_refunds';
  static const String driverArrival = 'driver_arrival';
  static const String driverPickup = 'driver_pickup';
  static const String driverRouteUpdates = 'driver_route_updates';
  static const String marketingOffers = 'marketing_offers';
  static const String marketingPromotions = 'marketing_promotions';
  static const String featureAnnouncements = 'feature_announcements';

  static String getDisplayName(String category) {
    switch (category) {
      case bookingConfirmations:
        return 'Booking Confirmations';
      case bookingModifications:
        return 'Booking Modifications';
      case bookingCancellations:
        return 'Cancellation Alerts';
      case paymentSuccess:
        return 'Successful Payments';
      case paymentFailed:
        return 'Failed Payments';
      case paymentRefunds:
        return 'Refund Notifications';
      case driverArrival:
        return 'Driver Arrival';
      case driverPickup:
        return 'Pickup Confirmations';
      case driverRouteUpdates:
        return 'Route Updates';
      case marketingOffers:
        return 'Special Offers';
      case marketingPromotions:
        return 'Promotions';
      case featureAnnouncements:
        return 'New Features';
      default:
        return category;
    }
  }

  static String getDescription(String category) {
    switch (category) {
      case bookingConfirmations:
        return 'Receive notifications when your booking is confirmed';
      case bookingModifications:
        return 'Get alerts when your booking details are modified';
      case bookingCancellations:
        return 'Be notified about booking cancellations';
      case paymentSuccess:
        return 'Confirmation when payment is successfully processed';
      case paymentFailed:
        return 'Alert when payment fails or is declined';
      case paymentRefunds:
        return 'Notifications about refund processing and completion';
      case driverArrival:
        return 'Know when your driver is arriving at pickup location';
      case driverPickup:
        return 'Confirmation when driver has picked up the vehicle';
      case driverRouteUpdates:
        return 'Updates about route changes or delays';
      case marketingOffers:
        return 'Exclusive deals and special discounts';
      case marketingPromotions:
        return 'Seasonal promotions and limited-time offers';
      case featureAnnouncements:
        return 'Learn about new app features and improvements';
      default:
        return '';
    }
  }
}
