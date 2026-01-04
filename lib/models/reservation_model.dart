class ReservationModel {
  final String? id;
  final String vehicleId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String? customerIdCard;
  final DateTime startDate;
  final DateTime endDate;
  final String pickupLocation;
  final String? dropoffLocation;
  final int totalDays;
  final double dailyRate;
  final double totalAmount;
  final double depositAmount;
  final ReservationStatus status;
  final String? specialRequests;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReservationModel({
    this.id,
    required this.vehicleId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.customerIdCard,
    required this.startDate,
    required this.endDate,
    required this.pickupLocation,
    this.dropoffLocation,
    required this.totalDays,
    required this.dailyRate,
    required this.totalAmount,
    this.depositAmount = 0,
    this.status = ReservationStatus.pending,
    this.specialRequests,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id']?.toString(),
      vehicleId: json['vehicle_id']?.toString() ?? '',
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      customerIdCard: json['customer_id_card'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      pickupLocation: json['pickup_location'] ?? '',
      dropoffLocation: json['dropoff_location'],
      totalDays: json['total_days'] ?? 1,
      dailyRate: (json['daily_rate'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      depositAmount: (json['deposit_amount'] ?? 0).toDouble(),
      status: _statusFromString(json['status'] ?? 'pending'),
      specialRequests: json['special_requests'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'vehicle_id': vehicleId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'customer_id_card': customerIdCard,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'pickup_location': pickupLocation,
      'dropoff_location': dropoffLocation,
      'total_days': totalDays,
      'daily_rate': dailyRate,
      'total_amount': totalAmount,
      'deposit_amount': depositAmount,
      'status': status.toString().split('.').last,
      'special_requests': specialRequests,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static ReservationStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return ReservationStatus.confirmed;
      case 'active':
        return ReservationStatus.active;
      case 'completed':
        return ReservationStatus.completed;
      case 'cancelled':
        return ReservationStatus.cancelled;
      default:
        return ReservationStatus.pending;
    }
  }

  ReservationModel copyWith({
    String? id,
    String? vehicleId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerIdCard,
    DateTime? startDate,
    DateTime? endDate,
    String? pickupLocation,
    String? dropoffLocation,
    int? totalDays,
    double? dailyRate,
    double? totalAmount,
    double? depositAmount,
    ReservationStatus? status,
    String? specialRequests,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReservationModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerIdCard: customerIdCard ?? this.customerIdCard,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      totalDays: totalDays ?? this.totalDays,
      dailyRate: dailyRate ?? this.dailyRate,
      totalAmount: totalAmount ?? this.totalAmount,
      depositAmount: depositAmount ?? this.depositAmount,
      status: status ?? this.status,
      specialRequests: specialRequests ?? this.specialRequests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum ReservationStatus {
  pending,
  confirmed,
  active,
  completed,
  cancelled,
}

extension ReservationStatusExtension on ReservationStatus {
  String get displayName {
    switch (this) {
      case ReservationStatus.pending:
        return 'รอดำเนินการ';
      case ReservationStatus.confirmed:
        return 'ยืนยันแล้ว';
      case ReservationStatus.active:
        return 'กำลังใช้งาน';
      case ReservationStatus.completed:
        return 'เสร็จสิ้น';
      case ReservationStatus.cancelled:
        return 'ยกเลิก';
    }
  }

  String get displayColor {
    switch (this) {
      case ReservationStatus.pending:
        return 'orange';
      case ReservationStatus.confirmed:
        return 'blue';
      case ReservationStatus.active:
        return 'green';
      case ReservationStatus.completed:
        return 'grey';
      case ReservationStatus.cancelled:
        return 'red';
    }
  }
}
