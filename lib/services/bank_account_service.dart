import '../models/bank_account_model.dart';
import './supabase_service.dart';

class BankAccountService {
  final SupabaseService _supabaseService = SupabaseService.instance;

  Future<List<BankAccountModel>> getActiveBankAccounts() async {
    try {
      final response = await _supabaseService.client
          .from('bank_accounts')
          .select()
          .eq('is_active', true)
          .order('created_at');

      return (response as List)
          .map((json) => BankAccountModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการโหลดข้อมูลบัญชีธนาคาร: $e');
    }
  }

  Future<List<RentalTermModel>> getRentalTerms() async {
    try {
      final response = await _supabaseService.client
          .from('rental_terms')
          .select()
          .eq('is_active', true)
          .order('display_order');

      return (response as List)
          .map((json) => RentalTermModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการโหลดเงื่อนไขการเช่า: $e');
    }
  }

  Future<List<RentalTermModel>> getRentalTermsByCategory(
      String category) async {
    try {
      final response = await _supabaseService.client
          .from('rental_terms')
          .select()
          .eq('is_active', true)
          .eq('category', category)
          .order('display_order');

      return (response as List)
          .map((json) => RentalTermModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาดในการโหลดเงื่อนไขการเช่า: $e');
    }
  }
}