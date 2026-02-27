import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as google_sign_in;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

// Import Google Sign In with conditional logic

class AuthService {
  final SupabaseClient _client = SupabaseService.instance.client;

  // Store Google Web Client ID as a constant
  static const String _googleWebClientId =
      String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: '');

  // Sign up with email and password
  Future<AuthResponse> signUp(
    String email,
    String password,
    Map<String, dynamic> userData,
  ) async {
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

  // Sign in with Google (Web Platform)
  Future<bool> signInWithGoogleWeb() async {
    try {
      final success = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
      );
      return success;
    } catch (error) {
      throw Exception('การเข้าสู่ระบบด้วย Google ล้มเหลว: $error');
    }
  }

  // Sign in with Google (Native Platforms)
  Future<AuthResponse> signInWithGoogleNative() async {
    try {
      if (_googleWebClientId.isEmpty) {
        throw Exception('GOOGLE_WEB_CLIENT_ID ไม่ได้ตั้งค่า');
      }

      // Only available on mobile platforms
      if (kIsWeb) {
        throw Exception('ใช้ signInWithGoogleWeb สำหรับ Web');
      }

      final googleSignIn = google_sign_in.GoogleSignIn(
        serverClientId: _googleWebClientId,
      );

      google_sign_in.GoogleSignInAccount? user = await googleSignIn.signInSilently();
      user ??= await googleSignIn.signIn();

      if (user == null) {
        throw Exception('ยกเลิกการเข้าสู่ระบบ');
      }

      final googleAuth = await user.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('ไม่พบ ID Token');
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      return response;
    } catch (error) {
      throw Exception('การเข้าสู่ระบบด้วย Google ล้มเหลว: $error');
    }
  }

  // Combined Google Sign In
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final success = await signInWithGoogleWeb();
        if (success) {
          return AuthResponse(
            session: _client.auth.currentSession,
            user: _client.auth.currentUser,
          );
        }
        return null;
      } else {
        return await signInWithGoogleNative();
      }
    } catch (error) {
      throw Exception('การเข้าสู่ระบบด้วย Google ล้มเหลว: $error');
    }
  }

  // Sign in with Apple
  Future<AuthResponse> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('ไม่พบ Apple ID Token');
      }

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        accessToken: credential.authorizationCode,
      );

      return response;
    } catch (error) {
      throw Exception('การเข้าสู่ระบบด้วย Apple ล้มเหลว: $error');
    }
  }

  // Sign in with Facebook
  Future<AuthResponse> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken;
        if (accessToken == null) {
          throw Exception('ไม่พบ Facebook Access Token');
        }

        final response = await _client.auth.signInWithIdToken(
          provider: OAuthProvider.facebook,
          idToken: accessToken.tokenString,
        );

        return response;
      } else if (result.status == LoginStatus.cancelled) {
        throw Exception('ยกเลิกการเข้าสู่ระบบ Facebook');
      } else {
        throw Exception('การเข้าสู่ระบบ Facebook ล้มเหลว');
      }
    } catch (error) {
      throw Exception('การเข้าสู่ระบบด้วย Facebook ล้มเหลว: $error');
    }
  }

  // Enhanced Sign Out
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        if (_googleWebClientId.isNotEmpty) {
          final googleSignIn = google_sign_in.GoogleSignIn(
            serverClientId: _googleWebClientId,
          );
          if (await googleSignIn.isSignedIn()) {
            await googleSignIn.signOut();
          }
        }

        if (await FacebookAuth.instance.accessToken != null) {
          await FacebookAuth.instance.logOut();
        }
      }

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
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _client.from('user_profiles').update(updates).eq('id', userId);
    } catch (error) {
      throw Exception('ไม่สามารถอัปเดตโปรไฟล์ได้: $error');
    }
  }

  // Reset password for email
  Future<void> resetPasswordForEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('ไม่สามารถส่งอีเมลรีเซ็ตรหัสผ่านได้: $error');
    }
  }
}