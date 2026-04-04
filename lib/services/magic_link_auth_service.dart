import 'package:supabase_flutter/supabase_flutter.dart';
import './supabase_service.dart';

class MagicLinkAuthService {
  final SupabaseClient _client = SupabaseService.instance.client;

  // Super_Admin emails - single source of truth
  static const List<String> superAdminEmails = [
    'phongwut.w@gmail.com',
    'gittisakwannakeeree@gmail.com',
  ];

  // Admin emails
  static const List<String> adminEmails = ['nongsandyza@gmail.com'];

  // User emails (known users)
  static const List<String> knownUserEmails = ['mtdzfc@gmail.com'];

  /// Check if an email belongs to Super_Admin role
  static bool isSuperAdmin(String email) {
    return superAdminEmails.contains(email.toLowerCase().trim());
  }

  /// Check if an email belongs to Admin role
  static bool isAdmin(String email) {
    return adminEmails.contains(email.toLowerCase().trim());
  }

  /// Determine role from email (client-side, for UI preview only)
  static String getUserRole(String email) {
    final normalizedEmail = email.toLowerCase().trim();
    if (isSuperAdmin(normalizedEmail)) {
      return 'Super_Admin';
    }
    if (isAdmin(normalizedEmail)) {
      return 'Admin';
    }
    return 'User';
  }

  /// Send Magic Link to email
  Future<void> sendMagicLink(String email) async {
    await _client.auth.signInWithOtp(
      email: email.toLowerCase().trim(),
      emailRedirectTo: 'https://taxihouse1176.builtwithrocket.new',
    );
  }

  /// Upsert user profile with role after successful Magic Link authentication
  Future<String> upsertUserRole() async {
    final user = _client.auth.currentUser;
    if (user == null) return 'Visitor';

    final email = user.email?.toLowerCase().trim() ?? '';
    final role = getUserRole(email);

    try {
      await _client.from('profiles').upsert({
        'id': user.id,
        'email': email,
        'role': role,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');
    } catch (_) {
      // Profile upsert failed silently — role still determined client-side
    }

    return role;
  }

  /// Fetch user role from Supabase profiles table
  Future<String> fetchUserRole() async {
    final user = _client.auth.currentUser;
    if (user == null) return 'Visitor';

    try {
      final response = await _client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && response['role'] != null) {
        return response['role'] as String;
      }
    } catch (_) {
      // Fallback to client-side role detection
    }

    // Fallback: determine role from email
    final email = user.email?.toLowerCase().trim() ?? '';
    return getUserRole(email);
  }

  /// Get current authenticated user
  User? get currentUser => _client.auth.currentUser;

  /// Check if current user is Super_Admin (client-side check)
  bool get isCurrentUserSuperAdmin {
    final email = currentUser?.email;
    if (email == null) return false;
    return isSuperAdmin(email);
  }

  /// Check if current user is Admin or Super_Admin
  bool get isCurrentUserAdmin {
    final email = currentUser?.email;
    if (email == null) return false;
    return isSuperAdmin(email) || isAdmin(email);
  }

  /// Get current user role (client-side, synchronous)
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
