class AppNotificationModel {
  final String id;
  final String userId;
  final String notificationType;
  final String title;
  final String body;
  final String? referenceId;
  final String? referenceTable;
  final bool isRead;
  final DateTime createdAt;

  AppNotificationModel({
    required this.id,
    required this.userId,
    required this.notificationType,
    required this.title,
    required this.body,
    this.referenceId,
    this.referenceTable,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      notificationType: json['notification_type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      referenceId: json['reference_id'] as String?,
      referenceTable: json['reference_table'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'notification_type': notificationType,
      'title': title,
      'body': body,
      'reference_id': referenceId,
      'reference_table': referenceTable,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AppNotificationModel copyWith({bool? isRead}) {
    return AppNotificationModel(
      id: id,
      userId: userId,
      notificationType: notificationType,
      title: title,
      body: body,
      referenceId: referenceId,
      referenceTable: referenceTable,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  static AppNotificationType getType(String type) {
    switch (type) {
      case 'vehicle_available':
        return AppNotificationType.vehicleAvailable;
      case 'booking_confirmed':
        return AppNotificationType.bookingConfirmed;
      case 'booking_cancelled':
        return AppNotificationType.bookingCancelled;
      case 'booking_modified':
        return AppNotificationType.bookingModified;
      case 'rental_active':
        return AppNotificationType.rentalActive;
      case 'rental_completed':
        return AppNotificationType.rentalCompleted;
      case 'payment_success':
        return AppNotificationType.paymentSuccess;
      case 'payment_failed':
        return AppNotificationType.paymentFailed;
      default:
        return AppNotificationType.bookingConfirmed;
    }
  }
}

enum AppNotificationType {
  vehicleAvailable,
  bookingConfirmed,
  bookingCancelled,
  bookingModified,
  rentalActive,
  rentalCompleted,
  paymentSuccess,
  paymentFailed,
}

extension AppNotificationTypeExtension on AppNotificationType {
  String get displayTitle {
    switch (this) {
      case AppNotificationType.vehicleAvailable:
        return 'Vehicle Available';
      case AppNotificationType.bookingConfirmed:
        return 'Booking Confirmed';
      case AppNotificationType.bookingCancelled:
        return 'Booking Cancelled';
      case AppNotificationType.bookingModified:
        return 'Booking Modified';
      case AppNotificationType.rentalActive:
        return 'Rental Active';
      case AppNotificationType.rentalCompleted:
        return 'Rental Completed';
      case AppNotificationType.paymentSuccess:
        return 'Payment Successful';
      case AppNotificationType.paymentFailed:
        return 'Payment Failed';
    }
  }

  bool get isPositive {
    switch (this) {
      case AppNotificationType.vehicleAvailable:
      case AppNotificationType.bookingConfirmed:
      case AppNotificationType.rentalActive:
      case AppNotificationType.rentalCompleted:
      case AppNotificationType.paymentSuccess:
        return true;
      case AppNotificationType.bookingCancelled:
      case AppNotificationType.bookingModified:
      case AppNotificationType.paymentFailed:
        return false;
    }
  }
}
