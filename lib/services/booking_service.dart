import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/car_model.dart';
import '../models/booking_payment_model.dart';
import './supabase_service.dart';

/// Service for cars, bookings, and payments using the actual DB schema.
/// Tables: cars, bookings, payments, profiles
class BookingService {
  final SupabaseClient _client = SupabaseService.instance.client;

  // ─── CARS ────────────────────────────────────────────────────────────────

  /// Fetch all available cars
  Future<List<CarModel>> getAvailableCars() async {
    try {
      final response = await _client
          .from('cars')
          .select()
          .eq('status', 'available')
          .order('brand');
      return (response as List).map((e) => CarModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('ไม่สามารถดึงข้อมูลรถได้: $e');
    }
  }

  /// Fetch all cars (for admin)
  Future<List<CarModel>> getAllCars() async {
    try {
      final response = await _client.from('cars').select().order('brand');
      return (response as List).map((e) => CarModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('ไม่สามารถดึงข้อมูลรถได้: $e');
    }
  }

  /// Check if a car is available for the given date range
  Future<bool> checkCarAvailability({
    required String carId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // First check car status
      final carResponse =
          await _client.from('cars').select('status').eq('id', carId).single();

      if (carResponse['status'] != 'available') return false;

      // Check for overlapping bookings
      final start = startDate.toIso8601String().split('T')[0];
      final end = endDate.toIso8601String().split('T')[0];

      final overlapping = await _client
          .from('bookings')
          .select('id')
          .eq('car_id', carId)
          .inFilter('status', ['pending', 'confirmed', 'active'])
          .or('start_date.lte.$end,end_date.gte.$start')
          .limit(1);

      return (overlapping as List).isEmpty;
    } catch (e) {
      throw Exception('ไม่สามารถตรวจสอบความพร้อมของรถได้: $e');
    }
  }

  // ─── BOOKINGS ────────────────────────────────────────────────────────────

  /// Create a booking (status: pending) and immediately create a payment (status: pending)
  Future<Map<String, dynamic>> createBookingWithPayment({
    required String carId,
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    required double totalAmount,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      // 1. Create booking
      final bookingResponse = await _client
          .from('bookings')
          .insert({
            'car_id': carId,
            'user_id': userId,
            'start_date': startDate.toIso8601String().split('T')[0],
            'end_date': endDate.toIso8601String().split('T')[0],
            'total_amount': totalAmount,
            'status': 'pending',
            if (notes != null && notes.isNotEmpty) 'notes': notes,
          })
          .select()
          .single();

      final bookingId = bookingResponse['id'] as String;

      // 2. Create payment immediately (pending)
      final paymentResponse = await _client
          .from('payments')
          .insert({
            'booking_id': bookingId,
            'user_id': userId,
            'amount': totalAmount,
            'method': paymentMethod,
            'status': 'pending',
          })
          .select()
          .single();

      return {
        'booking': bookingResponse,
        'payment': paymentResponse,
      };
    } catch (e) {
      throw Exception('ไม่สามารถสร้างการจองได้: $e');
    }
  }

  /// Get bookings for the current user with car and payment info
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final response = await _client
          .from('bookings')
          .select('*, cars(*), payments(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (response as List).map((e) => BookingModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('ไม่สามารถดึงข้อมูลการจองได้: $e');
    }
  }

  /// Get all bookings (admin)
  Future<List<BookingModel>> getAllBookings() async {
    try {
      final response = await _client
          .from('bookings')
          .select('*, cars(*), payments(*)')
          .order('created_at', ascending: false);
      return (response as List).map((e) => BookingModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('ไม่สามารถดึงข้อมูลการจองได้: $e');
    }
  }

  /// Get a single booking by ID
  Future<BookingModel> getBookingById(String bookingId) async {
    try {
      final response = await _client
          .from('bookings')
          .select('*, cars(*), payments(*)')
          .eq('id', bookingId)
          .single();
      return BookingModel.fromJson(response);
    } catch (e) {
      throw Exception('ไม่สามารถดึงข้อมูลการจองได้: $e');
    }
  }

  /// Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _client
          .from('bookings')
          .update({'status': 'cancelled'}).eq('id', bookingId);
    } catch (e) {
      throw Exception('ไม่สามารถยกเลิกการจองได้: $e');
    }
  }

  // ─── PAYMENTS ────────────────────────────────────────────────────────────

  /// Get payment by booking ID
  Future<PaymentModel?> getPaymentByBookingId(String bookingId) async {
    try {
      final response = await _client
          .from('payments')
          .select()
          .eq('booking_id', bookingId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (response == null) return null;
      return PaymentModel.fromJson(response);
    } catch (e) {
      throw Exception('ไม่สามารถดึงข้อมูลการชำระเงินได้: $e');
    }
  }

  /// Upload slip URL and mark payment as pending (waiting admin confirm)
  Future<void> uploadSlip({
    required String paymentId,
    required String slipUrl,
  }) async {
    try {
      await _client.from('payments').update({
        'slip_url': slipUrl,
        'status': 'pending',
      }).eq('id', paymentId);
    } catch (e) {
      throw Exception('ไม่สามารถอัปโหลดสลิปได้: $e');
    }
  }

  /// Mark payment as paid (admin action)
  Future<void> confirmPayment(String paymentId) async {
    try {
      await _client.from('payments').update({
        'status': 'paid',
        'paid_at': DateTime.now().toIso8601String(),
      }).eq('id', paymentId);
    } catch (e) {
      throw Exception('ไม่สามารถยืนยันการชำระเงินได้: $e');
    }
  }

  // ─── REALTIME ────────────────────────────────────────────────────────────

  /// Subscribe to real-time booking status changes
  RealtimeChannel subscribeToBooking({
    required String bookingId,
    required Function(Map<String, dynamic>) onUpdate,
  }) {
    return _client
        .channel('booking-$bookingId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: bookingId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .subscribe();
  }

  /// Subscribe to real-time payment status changes
  RealtimeChannel subscribeToPayment({
    required String paymentId,
    required Function(Map<String, dynamic>) onUpdate,
  }) {
    return _client
        .channel('payment-$paymentId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'payments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: paymentId,
          ),
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .subscribe();
  }

  // ─── PROFILE / ROLE ──────────────────────────────────────────────────────

  /// Fetch user role from profiles table
  Future<String> getUserRole(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      return response?['role'] as String? ?? 'User';
    } catch (_) {
      return 'User';
    }
  }
}
