import './supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutService {
  final SupabaseClient _client = SupabaseService.instance.client;

  // Create new reservation with payment transaction
  Future<Map<String, dynamic>> createReservation({
    required String vehicleId,
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String customerIdCard,
    required DateTime startDate,
    required DateTime endDate,
    required String pickupLocation,
    String? dropoffLocation,
    required double dailyRate,
    required int totalDays,
    required double totalAmount,
    required double depositAmount,
    String? specialRequests,
    required String paymentMethod,
  }) async {
    try {
      // Create reservation
      final reservationResponse = await _client
          .from('reservations')
          .insert({
            'vehicle_id': vehicleId,
            'customer_name': customerName,
            'customer_email': customerEmail,
            'customer_phone': customerPhone,
            'customer_id_card': customerIdCard,
            'start_date': startDate.toIso8601String().split('T')[0],
            'end_date': endDate.toIso8601String().split('T')[0],
            'pickup_location': pickupLocation,
            'dropoff_location': dropoffLocation,
            'daily_rate': dailyRate,
            'total_days': totalDays,
            'total_amount': totalAmount,
            'deposit_amount': depositAmount,
            'special_requests': specialRequests,
            'status': 'pending',
          })
          .select()
          .single();

      // Create payment transaction
      final paymentResponse = await _client
          .from('payment_transactions')
          .insert({
            'reservation_id': reservationResponse['id'],
            'user_id': customerId,
            'amount': depositAmount,
            'payment_method': paymentMethod,
            'payment_status': 'pending',
            'notes': 'มัดจำค่าเช่ารถ',
          })
          .select()
          .single();

      return {
        'reservation': reservationResponse,
        'payment': paymentResponse,
      };
    } catch (error) {
      throw Exception('ไม่สามารถสร้างการจองได้: $error');
    }
  }

  // Get user reservations with vehicle and payment info
  Future<List<Map<String, dynamic>>> getUserReservations(String userId) async {
    try {
      final response = await _client
          .from('reservations')
          .select('''
            *,
            vehicles(*),
            payment_transactions(*)
          ''')
          .eq('customer_email', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('ไม่สามารถดึงข้อมูลการจองได้: $error');
    }
  }

  // Get reservation by ID
  Future<Map<String, dynamic>> getReservationById(String reservationId) async {
    try {
      final response = await _client.from('reservations').select('''
            *,
            vehicles(*),
            payment_transactions(*)
          ''').eq('id', reservationId).single();

      return response;
    } catch (error) {
      throw Exception('ไม่สามารถดึงข้อมูลการจองได้: $error');
    }
  }

  // Update payment status
  Future<void> updatePaymentStatus({
    required String paymentId,
    required String status,
    String? transactionReference,
    DateTime? paymentDate,
  }) async {
    try {
      await _client.from('payment_transactions').update({
        'payment_status': status,
        if (transactionReference != null)
          'transaction_reference': transactionReference,
        if (paymentDate != null) 'payment_date': paymentDate.toIso8601String(),
      }).eq('id', paymentId);
    } catch (error) {
      throw Exception('ไม่สามารถอัปเดตสถานะการชำระเงินได้: $error');
    }
  }

  // Upload payment receipt
  Future<void> uploadPaymentReceipt({
    required String transactionId,
    required String receiptUrl,
  }) async {
    try {
      await _client.rpc('update_payment_receipt', params: {
        'transaction_uuid': transactionId,
        'receipt_image_url': receiptUrl,
      });
    } catch (error) {
      throw Exception('ไม่สามารถอัปโหลดสลิปการชำระเงินได้: $error');
    }
  }

  // Subscribe to payment status changes for real-time updates
  RealtimeChannel subscribeToPaymentStatus({
    required String transactionId,
    required Function(Map<String, dynamic>) onStatusChange,
  }) {
    return _client
        .channel('payment-status-$transactionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'payment_transactions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: transactionId,
          ),
          callback: (payload) {
            onStatusChange(payload.newRecord);
          },
        )
        .subscribe();
  }

  // Get payment transaction by ID with real-time updates
  Future<Map<String, dynamic>> getPaymentTransaction(
      String transactionId) async {
    try {
      final response = await _client
          .from('payment_transactions')
          .select()
          .eq('id', transactionId)
          .single();

      return response;
    } catch (error) {
      throw Exception('ไม่สามารถดึงข้อมูลการชำระเงินได้: $error');
    }
  }

  // Cancel reservation
  Future<void> cancelReservation(String reservationId) async {
    try {
      await _client
          .from('reservations')
          .update({'status': 'cancelled'}).eq('id', reservationId);
    } catch (error) {
      throw Exception('ไม่สามารถยกเลิกการจองได้: $error');
    }
  }

  // Get bank accounts for payment
  Future<List<Map<String, dynamic>>> getBankAccounts() async {
    try {
      final response =
          await _client.from('bank_accounts').select().eq('is_active', true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('ไม่สามารถดึงข้อมูลบัญชีธนาคารได้: $error');
    }
  }
}
