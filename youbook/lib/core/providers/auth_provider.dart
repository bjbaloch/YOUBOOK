import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // Private constructor for singleton
  AuthProvider._();

  // Singleton instance
  static final AuthProvider _instance = AuthProvider._();

  // Factory constructor to return the singleton instance
  factory AuthProvider() => _instance;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  String get userRole => _user?.role ?? AppConstants.rolePassenger;

  // Services
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Initialize auth state
  Future<void> initializeAuth() async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      // Check for stored session
      final sessionJson = await _storage.read(key: 'user_session');
      if (sessionJson != null) {
        // Validate and restore session
        final user = await _authService.getCurrentUserProfile();
        if (user != null) {
          _user = user;
        } else {
          await logout();
        }
      }
    } catch (e) {
      _error = e.toString();
      await logout();
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }

    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedOut) {
        _user = null;
        Future.microtask(() => notifyListeners());
      }
    });
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _user = user;
        await _saveSession(user);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Signup
  Future<bool> signup(String email, String password, String fullName,
      {String? phoneNumber, String? avatarUrl, String? cnic, String role = 'passenger', String? companyName, String? credentialDetails}) async {
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      final user = await _authService.signup(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        cnic: cnic,
        role: role,
        companyName: companyName,
        credentialDetails: credentialDetails,
      );

      if (user != null) {
        _user = user;
        await _saveSession(user);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _storage.delete(key: 'user_session');
      await _authService.logout();
      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      Future.microtask(() => notifyListeners());
    }
  }

  // Apply for manager role
  Future<bool> applyForManager(String companyName, String credentialDetails) async {
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      final success = await _authService.applyForManager(companyName, credentialDetails);
      if (success) {
        // Refresh user profile to get updated status
        await refreshProfile();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Update profile
  Future<bool> updateProfile(UserModel updatedUser) async {
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      final success = await _authService.updateProfile(updatedUser);
      if (success) {
        _user = updatedUser;
        await _saveSession(updatedUser);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  // Refresh user profile
  Future<void> refreshProfile() async {
    try {
      final refreshedUser = await _authService.getCurrentUserProfile();
      if (refreshedUser != null) {
        _user = refreshedUser;
        await _saveSession(refreshedUser);
        Future.microtask(() => notifyListeners());
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  // Private methods
  Future<void> _saveSession(UserModel user) async {
    try {
      // Save session data securely
      await _storage.write(
        key: 'user_session',
        value: jsonEncode(user.toJson()),
      );
    } catch (e) {
      debugPrint('Failed to save session: $e');
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    Future.microtask(() => notifyListeners());
  }
}
