import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/services.dart';
import '../models/models.dart';

class AdminAuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  // Private constructor for singleton
  AdminAuthProvider._() {
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      notifyListeners();
    });
  }

  // Singleton instance
  static final AdminAuthProvider _instance = AdminAuthProvider._();

  // Factory constructor to return the singleton instance
  factory AdminAuthProvider() => _instance;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => Supabase.instance.client.auth.currentSession != null;

  // Services
  final AuthService _authService = AuthService();

  // Initialize auth state - Supabase handles session automatically
  Future<void> initializeAuth() async {
    // No need for manual token checking - Supabase manages session
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.login(email, password);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Signup
  Future<bool> signup(UserCreate userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.signup(userData);
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Resend confirmation
  Future<bool> resendConfirmation(String email) async {
    try {
      return await _authService.resendConfirmation(email);
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Get API service
  ApiService getApiService() {
    return ApiService();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
