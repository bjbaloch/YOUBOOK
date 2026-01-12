import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Token?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        return Token(
          accessToken: response.session!.accessToken,
          tokenType: 'bearer',
        );
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      throw Exception('Login error: ${e.toString()}');
    }
  }

  Future<bool> signup(UserCreate userData) async {
    try {
      final response = await _supabase.auth.signUp(
        email: userData.email,
        password: userData.password,
        emailRedirectTo: 'youbookadmin://auth',
        data: {
          'full_name': userData.fullName,
          'phone_number': userData.phoneNumber,
          'cnic': userData.cnic ?? 'PENDING-CNIC-${userData.email.substring(0, 15)}',
          'role': 'admin',
        },
      );

      if (response.user != null) {
        return true;
      } else {
        throw Exception('Signup failed');
      }
    } catch (e) {
      throw Exception('Signup error: ${e.toString()}');
    }
  }

  Future<bool> resendConfirmation(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: 'youbookadmin://auth',
      );
      return true;
    } catch (e) {
      throw Exception('Failed to resend confirmation: ${e.toString()}');
    }
  }
}
