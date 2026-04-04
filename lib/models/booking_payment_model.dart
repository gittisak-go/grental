class BookingModel {
  final String? id;
  final String carId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final String status; // pending / confirmed / active / completed / cancelled
  final DateTime? checkinAt;
  final DateTime? checkoutAt;
  final String? nfcToken;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined data
  final Map<String, dynamic>? car;
  final List<Map<String, dynamic>>? payments;

  const BookingModel({
    this.id,
    required this.carId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    this.status = 'pending',
    this.checkinAt,
    this.checkoutAt,
    this.nfcToken,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.car,
    this.payments,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String?,
      carId: json['car_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      checkinAt: json['checkin_at'] != null
          ? DateTime.tryParse(json['checkin_at'] as String)
          : null,
      checkoutAt: json['checkout_at'] != null
          ? DateTime.tryParse(json['checkout_at'] as String)
          : null,
      nfcToken: json['nfc_token'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      car: json['cars'] as Map<String, dynamic>?,
      payments: (json['payments'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'car_id': carId,
        'user_id': userId,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        'total_amount': totalAmount,
        'status': status,
        if (notes != null) 'notes': notes,
      };

  int get rentalDays => endDate.difference(startDate).inDays + 1;

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'รอดำเนินการ';
      case 'confirmed':
        return 'ยืนยันแล้ว';
      case 'active':
        return 'กำลังใช้งาน';
      case 'completed':
        return 'เสร็จสิ้น';
      case 'cancelled':
        return 'ยกเลิก';
      default:
        return status;
    }
  }
}

class PaymentModel {
  final String? id;
  final String bookingId;
  final String userId;
  final double amount;
  final String method; // promptpay / bank_transfer / cash / card
  final String status; // pending / paid / failed / refunded
  final String? slipUrl;
  final String? promptpayRef;
  final DateTime? paidAt;
  final DateTime? createdAt;

  const PaymentModel({
    this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.method,
    this.status = 'pending',
    this.slipUrl,
    this.promptpayRef,
    this.paidAt,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String?,
      bookingId: json['booking_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      method: json['method'] as String? ?? 'cash',
      status: json['status'] as String? ?? 'pending',
      slipUrl: json['slip_url'] as String?,
      promptpayRef: json['promptpay_ref'] as String?,
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'booking_id': bookingId,
        'user_id': userId,
        'amount': amount,
        'method': method,
        'status': status,
        if (slipUrl != null) 'slip_url': slipUrl,
        if (promptpayRef != null) 'promptpay_ref': promptpayRef,
      };

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'รอชำระ';
      case 'paid':
        return 'ชำระแล้ว';
      case 'failed':
        return 'ล้มเหลว';
      case 'refunded':
        return 'คืนเงินแล้ว';
      default:
        return status;
    }
  }

  String get methodDisplay {
    switch (method) {
      case 'promptpay':
        return 'PromptPay';
      case 'bank_transfer':
        return 'โอนเงิน';
      case 'cash':
        return 'เงินสด';
      case 'card':
        return 'บัตรเครดิต/เดบิต';
      default:
        return method;
    }
  }
}
