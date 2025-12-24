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
    print('DEBUG: AuthProvider initializeAuth started');
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      // Check for stored session
      final sessionJson = await _storage.read(key: 'user_session');
      print('DEBUG: AuthProvider stored session exists: ${sessionJson != null}');
      if (sessionJson != null) {
        // Validate and restore session
        print('DEBUG: AuthProvider validating stored session');
        final user = await _authService.getCurrentUserProfile();
        if (user != null) {
          _user = user;
          print('DEBUG: AuthProvider restored user from stored session: ${user.email}');
        } else {
          print('DEBUG: AuthProvider stored session invalid, logging out');
          await logout();
        }
      } else {
        // No stored session, but check if user is authenticated via Supabase
        // (e.g., from deep link or fresh login)
        final currentUser = Supabase.instance.client.auth.currentUser;
        print('DEBUG: AuthProvider no stored session, current Supabase user: ${currentUser?.email}');
        if (currentUser != null) {
          // User is authenticated, try to get profile
          // Don't sign out if profile doesn't exist yet (database trigger delay)
          print('DEBUG: AuthProvider fetching profile for authenticated user');
          final user = await _authService.getCurrentUserProfile();
          if (user != null) {
            _user = user;
            await _saveSession(user);
            print('DEBUG: AuthProvider set user from Supabase auth: ${user.email}');
          } else {
            print('DEBUG: AuthProvider profile not found yet, leaving user as null');
          }
          // If profile doesn't exist, leave _user as null but don't sign out
          // The UI will handle this case appropriately
        } else {
          print('DEBUG: AuthProvider no stored session and no Supabase auth');
        }
      }
    } catch (e) {
      _error = e.toString();
      print('DEBUG: AuthProvider initializeAuth error: $e');
      // Don't automatically logout on error - let UI handle it
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
      print('DEBUG: AuthProvider initializeAuth completed, isAuthenticated: $isAuthenticated');
    }

    // Listen to auth state changes
    print('DEBUG: AuthProvider setting up auth state change listener');
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      print('DEBUG: AuthProvider auth state change: ${event.event}');
      if (event.event == AuthChangeEvent.signedOut) {
        print('DEBUG: AuthProvider user signed out, clearing user');
        _user = null;
        Future.microtask(() => notifyListeners());
      } else if (event.event == AuthChangeEvent.signedIn) {
        print('DEBUG: AuthProvider user signed in, refreshing profile');
        // User signed in, refresh profile
        refreshProfile();
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
