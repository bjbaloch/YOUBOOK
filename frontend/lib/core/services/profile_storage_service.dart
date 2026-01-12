import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../../features/profile/account/account_page/Data/account_page_data.dart';

class ProfileStorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _signupDataKey = 'signup_data';
  static const String _accountDataKey = 'account_data';

  // Save basic user profile data locally
  static Future<void> saveUserProfile(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = user.toJson();
      await prefs.setString(_userProfileKey, jsonEncode(userJson));
    } catch (e) {
      print('Error saving user profile: $e');
    }
  }

  // Get basic user profile data from local storage
  static Future<UserModel?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = prefs.getString(_userProfileKey);

      if (userJsonString != null) {
        final userJson = jsonDecode(userJsonString);
        return UserModel.fromJson(userJson);
      }
    } catch (e) {
      print('Error getting user profile: $e');
    }
    return null;
  }

  // Save detailed account data locally
  static Future<void> saveAccountData(AccountData accountData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountJson = {
        'fullName': accountData.fullName,
        'email': accountData.email,
        'phone': accountData.phone,
        'cnic': accountData.cnic,
        'avatarUrl': accountData.avatarUrl,
        'address': accountData.address,
        'city': accountData.city,
        'stateProvince': accountData.stateProvince,
        'country': accountData.country,
      };
      await prefs.setString(_accountDataKey, jsonEncode(accountJson));
    } catch (e) {
      print('Error saving account data: $e');
    }
  }

  // Get detailed account data from local storage
  static Future<AccountData?> getAccountData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountJsonString = prefs.getString(_accountDataKey);

      if (accountJsonString != null) {
        final accountJson = jsonDecode(accountJsonString);
        return AccountData(
          fullName: accountJson['fullName'],
          email: accountJson['email'],
          phone: accountJson['phone'],
          cnic: accountJson['cnic'],
          avatarUrl: accountJson['avatarUrl'],
          address: accountJson['address'],
          city: accountJson['city'],
          stateProvince: accountJson['stateProvince'],
          country: accountJson['country'],
        );
      }
    } catch (e) {
      print('Error getting account data: $e');
    }
    return null;
  }

  // Save signup data during registration
  static Future<void> saveSignupData({
    required String email,
    required String fullName,
    String? phoneNumber,
    String? cnic,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final signupData = {
        'email': email,
        'full_name': fullName,
        'phone_number': phoneNumber,
        'cnic': cnic,
        'signup_timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_signupDataKey, jsonEncode(signupData));
    } catch (e) {
      print('Error saving signup data: $e');
    }
  }

  // Get signup data
  static Future<Map<String, dynamic>?> getSignupData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final signupDataString = prefs.getString(_signupDataKey);

      if (signupDataString != null) {
        return jsonDecode(signupDataString);
      }
    } catch (e) {
      print('Error getting signup data: $e');
    }
    return null;
  }

  // Update account data
  static Future<void> updateAccountData(AccountData updatedData) async {
    await saveAccountData(updatedData);
  }

  // Clear all stored profile data (for logout)
  static Future<void> clearProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userProfileKey);
      await prefs.remove(_signupDataKey);
      await prefs.remove(_accountDataKey);
    } catch (e) {
      print('Error clearing profile data: $e');
    }
  }

  // Check if user has completed profile
  static Future<bool> isProfileComplete() async {
    try {
      final accountData = await getAccountData();
      if (accountData == null) return false;

      return accountData.fullName != null &&
             accountData.phone != null &&
             accountData.address != null &&
             accountData.city != null &&
             accountData.stateProvince != null &&
             accountData.country != null;
    } catch (e) {
      return false;
    }
  }

  // Get combined profile data (signup + account data)
  static Future<AccountData> getCombinedProfileData() async {
    final signupData = await getSignupData();
    final accountData = await getAccountData();

    if (accountData != null) {
      return accountData;
    }

    // Fallback to signup data if no account data exists
    if (signupData != null) {
      return AccountData(
        fullName: signupData['full_name'],
        email: signupData['email'],
        phone: signupData['phone_number'],
        cnic: signupData['cnic'],
      );
    }

    // Return default empty data
    return AccountData();
  }
}
