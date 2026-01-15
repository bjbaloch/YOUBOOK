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
  Future<bool> updateProfile(UserModel user, {String? companyName, String? credentialDetails}) async {
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
        if (companyName != null) 'company_name': companyName,
        if (credentialDetails != null) 'credential_details': credentialDetails,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await supabase
          .from('profiles')
          .update(updateData)
          .eq('id', user.id);

      return true;
    } catch (e) {
      rethrow;
    }
  }

  // Apply for manager role
  Future<bool> applyForManager(String companyName, String credentialDetails) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if user already has a pending application
      final existingApp = await supabase
          .from('manager_applications')
          .select('*')
          .eq('user_id', user.id)
          .eq('status', 'pending');

      if (existingApp.isNotEmpty) {
        throw Exception('You already have a pending application');
      }

      // Insert new application
      final appData = {
        'user_id': user.id,
        'company_name': companyName,
        'credential_details': credentialDetails,
      };

      final response = await supabase
          .from('manager_applications')
          .insert(appData)
          .select();

      // Return true if insertion was successful (response contains inserted records)
      return response != null && response.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  // Get manager application status
  Future<Map<String, dynamic>?> getManagerApplication() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final response = await supabase
          .from('manager_applications')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        return response.first;
      }
      return null; // No application found
    } catch (e) {
      rethrow;
    }
  }

  // Check if manager application is approved
  Future<bool> isManagerApplicationApproved() async {
    try {
      final application = await getManagerApplication();
      return application != null && application['status'] == 'approved';
    } catch (e) {
      return false;
    }
  }


}
