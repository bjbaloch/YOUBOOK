import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../passenger/home_shell.dart';
import '../manager/manager_dashboard.dart';
import '../driver/driver_home_screen.dart';
import 'signup_screen.dart';
import 'forget_password_popup.dart';

// Simple debouncer for real-time validation
class Debouncer {
  Debouncer(this.ms);
  final int ms;
  Timer? _timer;
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: ms), action);
  }

  void dispose() => _timer?.cancel();
}

// Regex patterns - matching signup validation
final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

// Email auto-correction method
String _canonicalEmail(String s) => s.trim().toLowerCase();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // Focus nodes for better UX
  final _emailFN = FocusNode();

  // Debouncers for real-time validation
  final _emailDebouncer = Debouncer(600);

  bool _isEmailValid = true;
  String? _errorMessage;
  bool _showMessageCard = false;
  Timer? _messageTimer;
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Setup debounced real-time validation with auto-correction
    _emailController.addListener(() {
      // Auto-correct email (convert to lowercase, trim whitespace)
      final currentText = _emailController.text;
      final canonicalText = _canonicalEmail(currentText);

      // Update text only if different to avoid cursor jumps
      if (currentText != canonicalText) {
        _emailController.value = _emailController.value.copyWith(
          text: canonicalText,
          selection: TextSelection.collapsed(offset: canonicalText.length),
        );
      }

      // Validate email format
      final valid = emailRegex.hasMatch(canonicalText);
      if (mounted) {
        setState(() {
          _isEmailValid = valid;
        });
      }
    });

    _emailFN.addListener(() {
      if (!_emailFN.hasFocus) {
        // Final validation on focus loss
        final canonicalText = _canonicalEmail(_emailController.text);
        setState(() {
          _isEmailValid = emailRegex.hasMatch(canonicalText);
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFN.dispose();
    _emailDebouncer.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0;

    if (_keyboardVisible != newValue) {
      setState(() {
        _keyboardVisible = newValue;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Clear any previous errors
    authProvider.clearError();
    setState(() {
      _errorMessage = null;
      _showMessageCard = false;
    });

    try {
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        print(
          "DEBUG: Login successful, navigating based on role: ${authProvider.userRole}",
        );

        // Show success message in card
        setState(() {
          _errorMessage = 'Login successful!';
          _showMessageCard = true;
        });

        // Auto-hide message after 5 seconds
        _messageTimer?.cancel();
        _messageTimer = Timer(Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showMessageCard = false;
              _errorMessage = null;
            });
          }
        });

        // Add a small delay to allow the message to be seen
        await Future.delayed(Duration(seconds: 2));

        if (mounted) {
          _navigateBasedOnRole(authProvider);
        }
      } else if (mounted) {
        print("DEBUG: Login failed with error: ${authProvider.error}");
        // Show user-friendly error message in card
        String errorMessage = _getUserFriendlyErrorMessage(authProvider.error);
        setState(() {
          _errorMessage = errorMessage;
          _showMessageCard = true;
        });

        // Auto-hide error message after 5 seconds
        _messageTimer?.cancel();
        _messageTimer = Timer(Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _showMessageCard = false;
              _errorMessage = null;
            });
          }
        });
      }
    } catch (e) {
      print("DEBUG: Unexpected error during login: $e");

      // Check if it's a network error
      String errorMessage;
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Network') ||
          e.toString().contains('internet') ||
          e.toString().contains('connection')) {
        errorMessage =
            'Network error. Please check your internet connection and try again.';
      } else {
        errorMessage = 'An unexpected error occurred. Please try again.';
      }

      // Handle any unexpected errors
      setState(() {
        _errorMessage = errorMessage;
        _showMessageCard = true;
      });

      // Auto-hide error message after 5 seconds
      _messageTimer?.cancel();
      _messageTimer = Timer(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showMessageCard = false;
            _errorMessage = null;
          });
        }
      });
    }
  }

  void _navigateBasedOnRole(AuthProvider authProvider) {
    if (!mounted) return;

    Widget nextScreen;

    switch (authProvider.userRole) {
      case AppConstants.roleManager:
        nextScreen = const ManagerDashboard();
        break;
      case AppConstants.roleDriver:
        nextScreen = const DriverHomeScreen();
        break;
      case AppConstants.rolePassenger:
      default:
        nextScreen = const HomeShell();
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  // Convert technical error messages to user-friendly ones
  String _getUserFriendlyErrorMessage(String? error) {
    if (error == null) return 'Login failed. Please try again.';

    // Handle common Supabase authentication errors
    if (error.contains('Invalid login credentials')) {
      return 'Invalid email or password. Please check your credentials and try again.';
    }

    if (error.contains('Email not confirmed')) {
      return 'Please confirm your email address before logging in.';
    }

    if (error.contains('User not found')) {
      return 'No account found with this email address.';
    }

    if (error.contains('Password is too weak')) {
      return 'Password is too weak. Please use a stronger password.';
    }

    // Network error detection
    if (error.contains('Network') ||
        error.contains('network') ||
        error.contains('internet') ||
        error.contains('connection') ||
        error.contains('SocketException')) {
      return 'Network error. Please check your internet connection and try again.';
    }

    // Generic fallback message
    return 'Login failed. Please check your credentials and try again.';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.lightSeaGreen,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 50),
                    // Card for the overall content
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(
                          0.1,
                        ), // Card background from app color (assuming AppColors.background is white) with transparency
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors
                              .accentOrange, // Border color accentOrange
                          width: 2.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Welcome text with YOUBOOK styling - White text like signup
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              children: const [
                                TextSpan(
                                  text: "Welcome Back to\nY",
                                  style: TextStyle(color: AppColors.background),
                                ),
                                TextSpan(
                                  text: "O",
                                  style: TextStyle(color: AppColors.logoYellow),
                                ),
                                TextSpan(
                                  text: "U",
                                  style: TextStyle(color: AppColors.background),
                                ),
                                TextSpan(
                                  text: "B",
                                  style: TextStyle(color: AppColors.background),
                                ),
                                TextSpan(
                                  text: "O",
                                  style: TextStyle(color: AppColors.logoYellow),
                                ),
                                TextSpan(
                                  text: "O",
                                  style: TextStyle(color: AppColors.logoYellow),
                                ),
                                TextSpan(
                                  text: "K",
                                  style: TextStyle(color: AppColors.background),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Sign in to continue',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.background.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 30),

                          // Email field - styled like signup fields with live validation
                          TextFormField(
                            controller: _emailController,
                            focusNode: _emailFN,
                            cursorColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
                            cursorWidth: 2,
                            cursorRadius: const Radius.circular(2),
                            style: TextStyle(color: AppColors.background),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.email,
                                color: AppColors.background.withOpacity(0.85),
                              ),
                              labelText: "Email",
                              labelStyle: TextStyle(
                                color: AppColors.background,
                              ),
                              floatingLabelStyle: TextStyle(
                                color: AppColors.background,
                                fontWeight: FontWeight.w600,
                              ),
                              filled: true,
                              fillColor: AppColors.transparent,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(
                                  color:
                                      (!_isEmailValid &&
                                          _emailController.text.isNotEmpty)
                                      ? AppColors.red
                                      : AppColors.accentOrange,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                borderSide: BorderSide(
                                  color:
                                      (!_isEmailValid &&
                                          _emailController.text.isNotEmpty)
                                      ? AppColors.red
                                      : Theme.of(context).colorScheme.secondary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                borderSide: BorderSide(color: AppColors.red),
                              ),
                              focusedErrorBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                borderSide: BorderSide(
                                  color: AppColors.red,
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter email';
                              }
                              if (!emailRegex.hasMatch(value)) {
                                return 'Enter valid email';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 15),

                          // Password field - styled like signup fields
                          StatefulBuilder(
                            builder: (context, setState) => TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              cursorColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              cursorWidth: 2,
                              cursorRadius: const Radius.circular(2),
                              style: TextStyle(color: AppColors.background),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: AppColors.background.withOpacity(0.85),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: AppColors.background.withOpacity(
                                      0.75,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                                labelText: "Password",
                                labelStyle: TextStyle(
                                  color: AppColors.background,
                                ),
                                floatingLabelStyle: TextStyle(
                                  color: AppColors.background,
                                  fontWeight: FontWeight.w600,
                                ),
                                filled: true,
                                fillColor: AppColors.transparent,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColors.accentOrange,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                  borderSide: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                  borderSide: BorderSide(color: AppColors.red),
                                ),
                                focusedErrorBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(30),
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColors.red,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter password';
                                }
                                // Removed regex validation, just check if password is not empty
                                // Invalid password message will come from server-side validation
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 10),
                          // Forgot password link - right aligned
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  ForgetPasswordPopup.show(
                                    context,
                                    initialEmail:
                                        _emailController.text.trim().isNotEmpty
                                        ? _emailController.text.trim()
                                        : null,
                                  );
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: AppColors.accentOrange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // Center the login button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: authProvider.isLoading
                                      ? SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.background,
                                          ),
                                        )
                                      : Text(
                                          "Sign In",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Sign up link - matching signup page style
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(color: AppColors.background),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignupScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: AppColors.accentOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Message card positioned based on keyboard visibility
            if (_showMessageCard)
              Positioned(
                bottom: _keyboardVisible
                    ? MediaQuery.of(context).viewInsets.bottom + 20
                    : 20,
                left: 20,
                right: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: _errorMessage == 'Login successful!'
                        ? AppColors.circleGreen
                        : AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _errorMessage == 'Login successful!'
                            ? Icons.check_circle
                            : Icons.error,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
