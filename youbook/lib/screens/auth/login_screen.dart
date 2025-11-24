import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../passenger/home_shell.dart';
import '../manager/manager_dashboard.dart';
import '../driver/driver_home_screen.dart';
import 'signup_screen.dart';

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
final RegExp passwordRegex = RegExp(
  r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
);

// Email auto-correction method
String _canonicalEmail(String s) => s.trim().toLowerCase();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // Focus nodes for better UX
  final _emailFN = FocusNode();

  // Debouncers for real-time validation
  final _emailDebouncer = Debouncer(600);

  bool _isEmailValid = true;

  @override
  void initState() {
    super.initState();

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
    _emailController.dispose();
    _passwordController.dispose();
    _emailFN.dispose();
    _emailDebouncer.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      _navigateBasedOnRole(authProvider);
    }
  }

  void _navigateBasedOnRole(AuthProvider authProvider) {
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.lightSeaGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 200),
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
                  cursorColor: Theme.of(context).colorScheme.secondary,
                  cursorWidth: 2,
                  cursorRadius: const Radius.circular(2),
                  style: TextStyle(color: AppColors.background),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.email,
                      color: AppColors.background.withOpacity(0.85),
                    ),
                    labelText: "Email",
                    labelStyle: TextStyle(color: AppColors.background),
                    floatingLabelStyle: TextStyle(
                      color: AppColors.background,
                      fontWeight: FontWeight.w600,
                    ),
                    filled: true,
                    fillColor: AppColors.transparent,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color:
                            (!_isEmailValid && _emailController.text.isNotEmpty)
                            ? AppColors.red
                            : AppColors.accentOrange,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                      borderSide: BorderSide(
                        color:
                            (!_isEmailValid && _emailController.text.isNotEmpty)
                            ? AppColors.red
                            : Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      borderSide: BorderSide(color: AppColors.red),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      borderSide: BorderSide(color: AppColors.red, width: 2),
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
                    cursorColor: Theme.of(context).colorScheme.secondary,
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
                          color: AppColors.background.withOpacity(0.75),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      labelText: "Password",
                      labelStyle: TextStyle(color: AppColors.background),
                      floatingLabelStyle: TextStyle(
                        color: AppColors.background,
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: AppColors.transparent,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(30),
                        ),
                        borderSide: BorderSide(color: AppColors.accentOrange),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(30),
                        ),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 2,
                        ),
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        borderSide: BorderSide(color: AppColors.red),
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        borderSide: BorderSide(color: AppColors.red, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter password';
                      }
                      if (!passwordRegex.hasMatch(value)) {
                        return '8+ chars, 1 upper, 1 lower, 1 number, 1 special';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Error message
                if (authProvider.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      authProvider.error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
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
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? CircularProgressIndicator(
                                color: AppColors.lightSeaGreen,
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
        ),
      ),
    );
  }
}
