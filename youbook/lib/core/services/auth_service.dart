import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
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
  Future<UserModel?> signup({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? cnic,
    String role = 'passenger',
    String? companyName,
    String? credentialDetails,
  }) async {
    try {
      // 1. Prepare the User Metadata
      // This data is passed to Supabase and read by the Postgres Trigger 'handle_new_user'
      final String actualCnic = cnic ?? "PENDING-CNIC-${email.split('@').first}";

      final Map<String, dynamic> metadata = {
        "full_name": fullName,
        "phone_number": phoneNumber,
        "avatar_url": avatarUrl,
        "cnic": actualCnic,
        "role": role,
        // Only include manager details if they are provided
        if (companyName != null) "company_name": companyName,
        if (credentialDetails != null) "credential_details": credentialDetails,
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

      final userId = authResponse.user!.id;

      // 3. Return UserModel immediately
      // We do NOT manually insert into 'profiles' or 'wallets' here.
      // The Database Trigger handles that automatically to avoid race conditions.
      return UserModel(
        id: userId,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        role: role,
      );

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
      };

      final response = await http.put(
        Uri.parse('${AppConstants.apiBaseUrl}/profile'),
        headers: _getAuthHeaders(),
        body: json.encode(updateData),
      );

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  // Apply for manager role
  Future<bool> applyForManager(String companyName, String credentialDetails) async {
    try {
      final applicationData = {
        'company_name': companyName,
        'credential_details': credentialDetails,
      };

      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/profile/apply-manager'),
        headers: _getAuthHeaders(),
        body: json.encode(applicationData),
      );

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  // Get manager application status
  Future<Map<String, dynamic>?> getManagerApplication() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/profile/manager-application'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to get auth headers
  Map<String, String> _getAuthHeaders() {
    final token = supabase.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Refresh token
  Future<String?> refreshToken() async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/refresh-token'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newToken = data['access_token'];
        await supabase.auth.setSession(newToken);
        return newToken;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
