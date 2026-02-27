import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

class MagicLinkAuthService {
  final SupabaseClient _client = SupabaseService.instance.client;

  // Super_Admin emails
  static const List<String> superAdminEmails = [
    'gittisakwannakeeree@gmail.com',
    'info@gtsalphamcp.com',
    'director@gtsalphamcp.com',
    'phongwut.w@gmail.com',
  ];

  /// Check if an email belongs to Super_Admin role
  static bool isSuperAdmin(String email) {
    return superAdminEmails.contains(email.toLowerCase().trim());
  }

  /// Get user role based on email
  static String getUserRole(String email) {
    if (isSuperAdmin(email.toLowerCase().trim())) {
      return 'Super_Admin';
    }
    return 'User';
  }

  /// Send Magic Link to email
  Future<void> sendMagicLink(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'https://taxihouse1176.builtwithrocket.new',
    );
  }

  /// Get current authenticated user
  User? get currentUser => _client.auth.currentUser;

  /// Check if current user is Super_Admin
  bool get isCurrentUserSuperAdmin {
    final email = currentUser?.email;
    if (email == null) return false;
    return isSuperAdmin(email);
  }

  /// Get current user role
  String get currentUserRole {
    final email = currentUser?.email;
    if (email == null) return 'Visitor';
    return getUserRole(email);
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
