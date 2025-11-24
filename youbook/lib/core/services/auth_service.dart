import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../models/user.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // Login with email and password
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];

        // Store the access token
        await supabase.auth.setSession(accessToken);

        // Get user profile
        final user = await getCurrentUserProfile();
        return user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Signup new user
  Future<UserModel?> signup({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? cnic,
  }) async {
    try {
      final signupData = {
        'email': email,
        'password': password,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'avatar_url': avatarUrl,
        'cnic': cnic,
      };

      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(signupData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];

        // Store the access token
        await supabase.auth.setSession(accessToken);

        // Get user profile
        final user = await getCurrentUserProfile();
        return user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Call logout endpoint
      await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/logout'),
        headers: _getAuthHeaders(),
      );

      // Sign out from Supabase
      await supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/profile'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        return UserModel.fromJson(userData);
      }
      return null;
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
