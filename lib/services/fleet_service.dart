import '../models/fleet_vehicle_model.dart';
import './supabase_service.dart';

class FleetService {
  final SupabaseService _supabaseService = SupabaseService.instance;

  Future<List<FleetVehicleModel>> getFleetVehicles() async {
    try {
      final response = await _supabaseService.client
          .from('vehicles')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((vehicle) => FleetVehicleModel.fromJson(vehicle))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch fleet vehicles: $e');
    }
  }

  Future<List<FleetVehicleModel>> getVehiclesByStatus(String status) async {
    try {
      final response = await _supabaseService.client
          .from('vehicles')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      return (response as List)
          .map((vehicle) => FleetVehicleModel.fromJson(vehicle))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch vehicles by status: $e');
    }
  }

  Future<List<FleetVehicleModel>> searchVehicles(String query) async {
    try {
      final response = await _supabaseService.client
          .from('vehicles')
          .select()
          .or('brand.ilike.%$query%,model.ilike.%$query%,license_plate.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((vehicle) => FleetVehicleModel.fromJson(vehicle))
          .toList();
    } catch (e) {
      throw Exception('Failed to search vehicles: $e');
    }
  }

  Future<void> updateVehicleStatus(String vehicleId, String newStatus) async {
    try {
      await _supabaseService.client
          .from('vehicles')
          .update({'status': newStatus}).eq('id', vehicleId);
    } catch (e) {
      throw Exception('Failed to update vehicle status: $e');
    }
  }

  Future<void> updateVehicleFuelLevel(
      String vehicleId, double fuelLevel) async {
    try {
      await _supabaseService.client.from('vehicles').update({
        'fuel_level': fuelLevel,
      }).eq('id', vehicleId);
    } catch (e) {
      throw Exception('Failed to update fuel level: $e');
    }
  }

  Future<void> updateVehicleLocation(
      String vehicleId, double latitude, double longitude) async {
    try {
      await _supabaseService.client.from('vehicles').update({
        'gps_latitude': latitude,
        'gps_longitude': longitude,
        'last_gps_update': DateTime.now().toIso8601String(),
      }).eq('id', vehicleId);
    } catch (e) {
      throw Exception('Failed to update vehicle location: $e');
    }
  }

  Future<List<MaintenanceScheduleModel>> getMaintenanceSchedules(
      String vehicleId) async {
    try {
      final response = await _supabaseService.client
          .from('maintenance_schedules')
          .select()
          .eq('vehicle_id', vehicleId)
          .order('scheduled_date', ascending: true);

      return (response as List)
          .map((schedule) => MaintenanceScheduleModel.fromJson(schedule))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch maintenance schedules: $e');
    }
  }

  Future<void> scheduleMainenance(String vehicleId, String serviceType,
      DateTime scheduledDate, String notes) async {
    try {
      await _supabaseService.client.from('maintenance_schedules').insert({
        'vehicle_id': vehicleId,
        'service_type': serviceType,
        'scheduled_date': scheduledDate.toIso8601String(),
        'status': 'pending',
        'notes': notes,
      });
    } catch (e) {
      throw Exception('Failed to schedule maintenance: $e');
    }
  }

  Future<void> updateMaintenanceStatus(
      String scheduleId, String newStatus) async {
    try {
      await _supabaseService.client
          .from('maintenance_schedules')
          .update({'status': newStatus}).eq('id', scheduleId);
    } catch (e) {
      throw Exception('Failed to update maintenance status: $e');
    }
  }

  Future<List<MaintenanceScheduleModel>> getUpcomingMaintenance() async {
    try {
      final now = DateTime.now();
      final response = await _supabaseService.client
          .from('maintenance_schedules')
          .select()
          .gte('scheduled_date', now.toIso8601String())
          .eq('status', 'pending')
          .order('scheduled_date', ascending: true)
          .limit(10);

      return (response as List)
          .map((schedule) => MaintenanceScheduleModel.fromJson(schedule))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming maintenance: $e');
    }
  }
}