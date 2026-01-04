import '../models/vehicle_model.dart';
import './supabase_service.dart';

class VehicleService {
  static final VehicleService _instance = VehicleService._internal();
  factory VehicleService() => _instance;
  VehicleService._internal();

  final _supabase = SupabaseService.instance.client;

  // Get all vehicles
  Future<List<VehicleModel>> getAllVehicles() async {
    try {
      final response = await _supabase
          .from('vehicles')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => VehicleModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch vehicles: $e');
    }
  }

  // Get available vehicles only
  Future<List<VehicleModel>> getAvailableVehicles() async {
    try {
      final response = await _supabase
          .from('vehicles')
          .select()
          .eq('is_available', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => VehicleModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch available vehicles: $e');
    }
  }

  // Get vehicle by ID
  Future<VehicleModel?> getVehicleById(String id) async {
    try {
      final response =
          await _supabase.from('vehicles').select().eq('id', id).single();

      return VehicleModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch vehicle: $e');
    }
  }

  // Add new vehicle
  Future<VehicleModel> addVehicle(VehicleModel vehicle) async {
    try {
      final response = await _supabase
          .from('vehicles')
          .insert(vehicle.toJson())
          .select()
          .single();

      return VehicleModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add vehicle: $e');
    }
  }

  // Update vehicle
  Future<VehicleModel> updateVehicle(String id, VehicleModel vehicle) async {
    try {
      final updateData = vehicle.toJson();
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .from('vehicles')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return VehicleModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update vehicle: $e');
    }
  }

  // Delete vehicle
  Future<void> deleteVehicle(String id) async {
    try {
      await _supabase.from('vehicles').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete vehicle: $e');
    }
  }

  // Search vehicles
  Future<List<VehicleModel>> searchVehicles(String query) async {
    try {
      final response = await _supabase
          .from('vehicles')
          .select()
          .or('brand.ilike.%$query%,model.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => VehicleModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search vehicles: $e');
    }
  }

  // Filter vehicles by brand
  Future<List<VehicleModel>> filterByBrand(String brand) async {
    try {
      final response = await _supabase
          .from('vehicles')
          .select()
          .eq('brand', brand)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => VehicleModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter vehicles: $e');
    }
  }
}
