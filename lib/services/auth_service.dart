import './supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.instance.client;

  // Sign up with email and password
  Future<AuthResponse> signUp(
      String email, String password, Map<String, dynamic> userData) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );
      return response;
    } catch (error) {
      throw Exception('การสมัครสมาชิกล้มเหลว: $error');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('การเข้าสู่ระบบล้มเหลว: $error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('การออกจากระบบล้มเหลว: $error');
    }
  }

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Get current user ID
  String? get currentUserId => currentUser?.id;

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Get user profile from database
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (error) {
      throw Exception('ไม่สามารถดึงข้อมูลโปรไฟล์ได้: $error');
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> updates) async {
    try {
      await _client.from('user_profiles').update(updates).eq('id', userId);
    } catch (error) {
      throw Exception('ไม่สามารถอัปเดตโปรไฟล์ได้: $error');
    }
  }
}