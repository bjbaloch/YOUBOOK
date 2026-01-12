import 'package:flutter/material.dart';
import '../../../../../core/services/profile_storage_service.dart';
import '../Data/account_page_data.dart';

class AccountLogic {
  // Load user profile data from storage
  Future<AccountData> loadUser() async {
    try {
      // Simulate network delay for better UX
      await Future.delayed(const Duration(milliseconds: 300));

      // Get combined profile data from storage
      final profileData = await ProfileStorageService.getCombinedProfileData();
      return profileData;
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      // Return default data on error
      return AccountData();
    }
  }

  // Save user profile data to storage
  Future<bool> saveUserProfile(AccountData accountData) async {
    try {
      await ProfileStorageService.saveAccountData(accountData);
      return true;
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      return false;
    }
  }

  // Update user profile (mock implementation)
  Future<bool> updateProfile(AccountData updatedData) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, this would make an API call
      // For now, just return success
      return true;
    } catch (e) {
      debugPrint('Profile update error: $e');
      return false;
    }
  }

  // Change phone number (mock implementation)
  Future<bool> changePhoneNumber(String newPhoneNumber) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      // Mock validation
      if (newPhoneNumber.length < 10) {
        throw Exception('Invalid phone number');
      }
      return true;
    } catch (e) {
      debugPrint('Phone number change error: $e');
      return false;
    }
  }

  // Change email (mock implementation)
  Future<bool> changeEmail(String newEmail) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      // Mock validation
      if (!newEmail.contains('@')) {
        throw Exception('Invalid email format');
      }
      return true;
    } catch (e) {
      debugPrint('Email change error: $e');
      return false;
    }
  }

  // Change password (mock implementation)
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      // Mock validation
      if (newPassword.length < 6) {
        throw Exception('Password too short');
      }
      return true;
    } catch (e) {
      debugPrint('Password change error: $e');
      return false;
    }
  }

  // Logout (mock implementation)
  Future<void> logout() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // In a real app, this would clear auth tokens and navigate to login
      debugPrint('User logged out');
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  // Validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Validate phone number format
  bool isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^\+92\s\d{3}\s\d{7}$');
    return phoneRegex.hasMatch(phone);
  }

  // Validate CNIC format
  bool isValidCNIC(String cnic) {
    final cnicRegex = RegExp(r'^\d{5}-\d{7}-\d{1}$');
    return cnicRegex.hasMatch(cnic);
  }
}
