import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/app_constants.dart';

// Temporary in-memory user model for UI-only mode
class _TempUser {
  final String email;
  final String password;
  final String fullName;
  final String role;
  bool hasCompanyDetails;
  bool isApproved;

  _TempUser({
    required this.email,
    required this.password,
    required this.fullName,
    required this.role,
    this.hasCompanyDetails = false,
    this.isApproved = false,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'fullName': fullName,
        'role': role,
        'hasCompanyDetails': hasCompanyDetails,
        'isApproved': isApproved,
      };

  factory _TempUser.fromJson(Map<String, dynamic> j) => _TempUser(
        email: j['email'],
        password: j['password'],
        fullName: j['fullName'],
        role: j['role'],
        hasCompanyDetails: j['hasCompanyDetails'] ?? false,
        isApproved: j['isApproved'] ?? false,
      );
}

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  _TempUser? _currentUser;

  // Singleton
  AuthProvider._();
  static final AuthProvider _instance = AuthProvider._();
  factory AuthProvider() => _instance;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  String get userRole => _currentUser?.role ?? AppConstants.rolePassenger;
  _TempUser? get user => _currentUser;

  // ── Persistence keys ──────────────────────────────────────────────────────
  static const _kUsers = 'temp_users';
  static const _kSession = 'temp_session_email';

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<List<_TempUser>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kUsers);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => _TempUser.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _saveUsers(List<_TempUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsers, jsonEncode(users.map((u) => u.toJson()).toList()));
  }

  Future<void> _saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSession, email);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSession);
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Restore session on app start
  Future<void> initializeAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_kSession);
    if (email != null) {
      final users = await _loadUsers();
      _currentUser = users.firstWhere(
        (u) => u.email == email,
        orElse: () => _TempUser(email: '', password: '', fullName: '', role: ''),
      );
      if (_currentUser!.email.isEmpty) _currentUser = null;
      notifyListeners();
    }
  }

  /// Register a new user temporarily
  Future<bool> signup(
    String email,
    String password,
    String fullName, {
    String? phoneNumber,
    String? avatarUrl,
    String? cnic,
    String role = 'passenger',
    String? companyName,
    String? credentialDetails,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final users = await _loadUsers();
      // Check duplicate
      if (users.any((u) => u.email == email)) {
        _error = 'An account with this email already exists.';
        return false;
      }
      final newUser = _TempUser(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        // Offline mode: managers go straight to dashboard
        hasCompanyDetails: role == AppConstants.roleManager,
        isApproved: role == AppConstants.roleManager,
      );
      users.add(newUser);
      await _saveUsers(users);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login with email + password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final users = await _loadUsers();
      final match = users.where(
        (u) => u.email == email && u.password == password,
      );
      if (match.isEmpty) {
        _error = 'Invalid email or password.';
        return false;
      }
      _currentUser = match.first;
      await _saveSession(email);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mark that the current user has submitted company details
  Future<void> markCompanyDetailsSubmitted() async {
    if (_currentUser == null) return;
    final users = await _loadUsers();
    final idx = users.indexWhere((u) => u.email == _currentUser!.email);
    if (idx != -1) {
      users[idx].hasCompanyDetails = true;
      _currentUser = users[idx];
      await _saveUsers(users);
      notifyListeners();
    }
  }

  bool get hasCompanyDetails => _currentUser?.hasCompanyDetails ?? false;
  bool get isApproved => _currentUser?.isApproved ?? false;

  Future<void> logout() async {
    _currentUser = null;
    await _clearSession();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
