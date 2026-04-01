import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Login with email and password using direct Supabase
  Future<UserModel?> login(String email, String password) async {
    try {
      final authResponse = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Login failed: No user returned');
      }

      // Fetch user profile from profiles table
      final profileResponse = await supabase
          .from('profiles')
          .select('*')
          .eq('id', authResponse.user!.id)
          .single();

      return UserModel.fromJson(profileResponse);
    } catch (e) {
      rethrow;
    }
  }

  // Signup new user
  // UPDATED: Uses metadata and relies on SQL Triggers
  // NOTE: With email confirmation enabled, this does NOT sign the user in.
  // Authentication happens only after email confirmation via deep link.
  Future<bool> signup({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? cnic,
  }) async {
    try {
      // 1. Prepare the User Metadata
      // This data is passed to Supabase and read by the Postgres Trigger 'handle_new_user'
      final Map<String, dynamic> metadata = {
        "full_name": fullName,
        "phone_number": phoneNumber,
        "avatar_url": avatarUrl,
        "role": 'passenger',
        // Only add cnic if it's actually provided
        if (cnic != null && cnic.isNotEmpty) "cnic": cnic,
      };

      // 2. Perform Signup
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: metadata, // <--- IMPORTANT: This sends data to the SQL Trigger
      );

      if (authResponse.user == null) {
        throw Exception('Signup failed: No user returned from server.');
      }

      // 3. Return success
      // We do NOT sign the user in here. With email confirmation enabled,
      // the user must confirm their email before they can be authenticated.
      // The deep link handler will handle authentication after confirmation.
      return true;
    } on AuthException catch (e) {
      // Capture specific Supabase errors (e.g. "User already registered")
      throw Exception(e.message);
    } catch (e) {
      // Capture unexpected errors
      throw Exception('Signup Error: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Sign out from Supabase
      await supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final profileResponse = await supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(profileResponse);
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<bool> updateProfile(UserModel user) async {
    try {
      final updateData = {
        'full_name': user.fullName,
        'phone_number': user.phoneNumber,
        'avatar_url': user.avatarUrl,
        'cnic': user.cnic,
        'address': user.address,
        'city': user.city,
        'state_province': user.stateProvince,
        'country': user.country,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('profiles').update(updateData).eq('id', user.id);

      return true;
    } catch (e) {
      rethrow;
    }
  }
}
