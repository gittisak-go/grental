import '../models/reservation_model.dart';
import './supabase_service.dart';

class ReservationService {
  final SupabaseService _supabaseService = SupabaseService.instance;

  Future<List<ReservationModel>> getAllReservations() async {
    try {
      final response = await _supabaseService.client
          .from('reservations')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => ReservationModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reservations: $e');
    }
  }

  Future<List<ReservationModel>> getReservationsByStatus(
      ReservationStatus status) async {
    try {
      final statusString = status.toString().split('.').last;
      final response = await _supabaseService.client
          .from('reservations')
          .select('*')
          .eq('status', statusString)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => ReservationModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reservations by status: $e');
    }
  }

  Future<List<ReservationModel>> getActiveReservations() async {
    try {
      final response = await _supabaseService.client
          .from('reservations')
          .select('*')
          .inFilter('status', ['confirmed', 'active']).order('start_date',
              ascending: true);

      return (response as List)
          .map((item) => ReservationModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active reservations: $e');
    }
  }

  Future<ReservationModel> getReservationById(String id) async {
    try {
      final response = await _supabaseService.client
          .from('reservations')
          .select('*')
          .eq('id', id)
          .single();

      return ReservationModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch reservation: $e');
    }
  }

  Future<ReservationModel> addReservation(ReservationModel reservation) async {
    try {
      final response = await _supabaseService.client
          .from('reservations')
          .insert(reservation.toJson())
          .select()
          .single();

      return ReservationModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add reservation: $e');
    }
  }

  Future<void> updateReservation(
      String id, ReservationModel reservation) async {
    try {
      await _supabaseService.client
          .from('reservations')
          .update(reservation.toJson())
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update reservation: $e');
    }
  }

  Future<void> updateReservationStatus(
      String id, ReservationStatus status) async {
    try {
      final statusString = status.toString().split('.').last;
      await _supabaseService.client
          .from('reservations')
          .update({'status': statusString}).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update reservation status: $e');
    }
  }

  Future<void> deleteReservation(String id) async {
    try {
      await _supabaseService.client.from('reservations').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete reservation: $e');
    }
  }

  Future<bool> checkVehicleAvailability(
      String vehicleId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await _supabaseService.client.rpc(
        'check_vehicle_availability',
        params: {
          'p_vehicle_id': vehicleId,
          'p_start_date': startDate.toIso8601String().split('T')[0],
          'p_end_date': endDate.toIso8601String().split('T')[0],
        },
      );

      return response == true;
    } catch (e) {
      throw Exception('Failed to check vehicle availability: $e');
    }
  }

  Future<List<ReservationModel>> searchReservations(String query) async {
    try {
      final response = await _supabaseService.client
          .from('reservations')
          .select('*')
          .or('customer_name.ilike.%$query%,customer_email.ilike.%$query%,customer_phone.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => ReservationModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Failed to search reservations: $e');
    }
  }
}