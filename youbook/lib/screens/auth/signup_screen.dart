import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import 'login_screen.dart';

// Simple debouncer for "while typing" checks
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

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _credentialDetailsController = TextEditingController();

  // Focus nodes for better UX
  final _emailFN = FocusNode();
  final _phoneFN = FocusNode();
  final _cnicFN = FocusNode();

  // Debouncers for real-time validation
  final _emailDebouncer = Debouncer(600);
  final _phoneDebouncer = Debouncer(600);
  final _cnicDebouncer = Debouncer(600);

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  String _selectedRole = ''; // Start with no role selected
  bool _showManagerFields = false;
  bool _showManagerInfo = false; // Track if manager info is expanded

  // Live validation states
  bool _isPasswordValid = false;
  bool _isEmailValid = true;
  bool _isPhoneValid = true;
  bool _isCnicValid = true;

  String? _emailServerError;
  String? _phoneServerError;
  String? _cnicServerError;

  final supabase = Supabase.instance.client;

  // Regex patterns
  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp phoneRegex = RegExp(r'^(03|92)\d{9}$');
  final RegExp passwordRegex = RegExp(
    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
  );

  String _canonicalEmail(String s) => s.trim().toLowerCase();

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _hasInternet() async {
    try {
      final res = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 2));
      return res.isNotEmpty && res.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // Real-time uniqueness checks
  Future<void> _checkEmailAvailability({
    bool showNoInternetSnack = true,
  }) async {
    final email = _canonicalEmail(_emailController.text);
    if (email.isEmpty || !emailRegex.hasMatch(email)) return;

    setState(() => _emailServerError = null);

    try {
      final result = await supabase
          .from('profiles')
          .select('id')
          .ilike('email', email)
          .maybeSingle();
      final exists = result != null;

      if (!mounted) return;
      setState(() {
        _emailServerError = exists ? 'Email already registered' : null;
      });
    } on SocketException {
      if (showNoInternetSnack) _showSnack('No internet connection');
    } catch (e) {
      if (showNoInternetSnack) _showSnack('Something went wrong');
    }
  }

  Future<void> _checkPhoneAvailability({
    bool showNoInternetSnack = true,
  }) async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || !phoneRegex.hasMatch(phone)) return;

    setState(() => _phoneServerError = null);

    try {
      final result = await supabase
          .from('profiles')
          .select('id')
          .eq('phone_number', phone)
          .maybeSingle();
      final exists = result != null;

      if (!mounted) return;
      setState(() {
        _phoneServerError = exists ? 'Phone number already registered' : null;
      });
    } on SocketException {
      if (showNoInternetSnack) _showSnack('No internet connection');
    } catch (e) {
      if (showNoInternetSnack) _showSnack('Something went wrong');
    }
  }

  Future<void> _checkCnicAvailability({bool showNoInternetSnack = true}) async {
    final cnic = _cnicController.text.trim();
    if (cnic.isEmpty || cnic.length != 15) return;

    setState(() => _cnicServerError = null);

    try {
      final result = await supabase
          .from('profiles')
          .select('id')
          .eq('cnic', cnic)
          .maybeSingle();
      final exists = result != null;

      if (!mounted) return;
      setState(() {
        _cnicServerError = exists ? 'CNIC already registered' : null;
      });
    } on SocketException {
      if (showNoInternetSnack) _showSnack('No internet connection');
    } catch (e) {
      if (showNoInternetSnack) _showSnack('Something went wrong');
    }
  }

  Future<bool> _checkFieldAvailability() async {
    final email = _canonicalEmail(_emailController.text);

    setState(() {
      _emailServerError = null;
      _phoneServerError = null;
      _cnicServerError = null;
    });

    try {
      // Only check email uniqueness (phone and cnic are not unique in profiles)
      final List<Future<dynamic>> futures = <Future<dynamic>>[
        if (emailRegex.hasMatch(email) && email.isNotEmpty)
          supabase
              .from('profiles')
              .select('id')
              .ilike('email', email)
              .maybeSingle()
        else
          Future<dynamic>.value(null),
      ];

      final results = await Future.wait<dynamic>(futures);
      final emailExists = results[0] != null;

      if (mounted) {
        setState(() {
          _emailServerError = emailExists ? 'Email already registered' : null;
        });
      }
      return !emailExists;
    } on SocketException {
      _showSnack('No internet connection');
      return false;
    } catch (e) {
      if (e.toString().contains('Network') || e.toString().contains('Socket')) {
        _showSnack('No internet connection');
      } else {
        _showSnack('Something went wrong while checking availability');
      }
      return false;
    }
  }

  void _onRoleChanged(String? role) {
    setState(() {
      _selectedRole = role ?? AppConstants.rolePassenger;
      _showManagerFields = _selectedRole == AppConstants.roleManager;
    });
  }

  void _formatCnic(String value) {
    String numbers = value.replaceAll(RegExp(r'\D'), '');
    String formatted = '';
    if (numbers.length > 5) {
      formatted = numbers.substring(0, 5) + '-';
      if (numbers.length > 12) {
        formatted += numbers.substring(5, 12) + '-' + numbers.substring(12);
      } else if (numbers.length > 5) {
        formatted += numbers.substring(5);
      }
    } else {
      formatted = numbers;
    }
    if (formatted != value) {
      _cnicController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _handleSignup() async {
    FocusScope.of(context).unfocus();

    if (_selectedRole.isEmpty) {
      _showSnack('Please select an account type (Passenger or Manager)');
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (!await _hasInternet()) {
      _showSnack('No internet connection');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final ok = await _checkFieldAvailability();
      if (!ok) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final fullName =
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

      final success = await authProvider.signup(
        _emailController.text.trim(),
        _passwordController.text,
        fullName.trim(),
        phoneNumber: _phoneController.text.trim(),
        cnic: _cnicController.text.trim().isNotEmpty
            ? _cnicController.text.trim()
            : null,
      );

      if (success && mounted) {
        // If signing up as manager, also apply for manager role
        if (_selectedRole == AppConstants.roleManager) {
          await authProvider.applyForManager(
            _companyNameController.text.trim(),
            _credentialDetailsController.text.trim(),
          );
        }

        // Navigate to login or show success message
        if (mounted) {
          _showSnack('Account created successfully! Please login.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      }
    } catch (e) {
      _showSnack('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();

    // Setup autocorrect for password when field loses focus
    _passwordController.addListener(() {
      final password = _passwordController.text;
      if (mounted && password.isNotEmpty && password.length >= 6) {
        // Auto-check password strength but don't spam with messages
        final hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
        final hasLowerCase = RegExp(r'[a-z]').hasMatch(password);
        final hasDigit = RegExp(r'[0-9]').hasMatch(password);
        final hasSpecialChar = RegExp(r'[!@#\$&*~]').hasMatch(password);
        final isLengthValid = password.length >= 8;

        // Store current validation state silently
        _isPasswordValid =
            hasUpperCase &&
            hasLowerCase &&
            hasDigit &&
            hasSpecialChar &&
            isLengthValid;
      }
    });

    // Setup debounced real-time validation
    _emailController.addListener(() {
      final valid = emailRegex.hasMatch(_emailController.text);
      if (mounted) {
        setState(() {
          _isEmailValid = valid;
          if (_emailServerError != null) _emailServerError = null;
        });
      }
      if (valid) {
        _emailDebouncer.run(
          () => _checkEmailAvailability(showNoInternetSnack: false),
        );
      }
    });

    _phoneController.addListener(() {
      final valid = phoneRegex.hasMatch(_phoneController.text);
      if (mounted) {
        setState(() {
          _isPhoneValid = valid;
          if (_phoneServerError != null) _phoneServerError = null;
        });
      }
      if (valid) {
        _phoneDebouncer.run(
          () => _checkPhoneAvailability(showNoInternetSnack: false),
        );
      }
    });

    _cnicController.addListener(() {
      _formatCnic(_cnicController.text);
      if (_cnicServerError != null && mounted) {
        setState(() {
          _cnicServerError = null;
        });
      }
      if (_cnicController.text.trim().length == 15) {
        _cnicDebouncer.run(
          () => _checkCnicAvailability(showNoInternetSnack: false),
        );
      }
    });

    _emailFN.addListener(() {
      if (!_emailFN.hasFocus) _checkEmailAvailability();
    });
    _phoneFN.addListener(() {
      if (!_phoneFN.hasFocus) _checkPhoneAvailability();
    });
    _cnicFN.addListener(() {
      if (!_cnicFN.hasFocus) _checkCnicAvailability();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyNameController.dispose();
    _credentialDetailsController.dispose();

    _emailFN.dispose();
    _phoneFN.dispose();
    _cnicFN.dispose();

    _emailDebouncer.dispose();
    _phoneDebouncer.dispose();
    _cnicDebouncer.dispose();

    super.dispose();
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              // Green Header Section with YOUBOOK text
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightSeaGreen,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // YOUBOOK text with special styling
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 28),
                        children: [
                          TextSpan(
                            text: "Y",
                            style: TextStyle(color: AppColors.background),
                          ),
                          const TextSpan(
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
                          const TextSpan(
                            text: "O",
                            style: TextStyle(color: AppColors.logoYellow),
                          ),
                          const TextSpan(
                            text: "O",
                            style: TextStyle(color: AppColors.logoYellow),
                          ),
                          TextSpan(
                            text: "K",
                            style: TextStyle(color: AppColors.background),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColors.background,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Create your account to get started",
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.background,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form Fields in Header
                    _buildTextField(
                      icon: Icons.person,
                      hint: "Full Name",
                      controller: _firstNameController,
                      validator: (val) => (val == null || val.isEmpty)
                          ? "Enter your full name"
                          : null,
                      borderColor: AppColors.accentOrange,
                    ),
                    const SizedBox(height: 10),

                    _buildTextField(
                      icon: Icons.email,
                      hint: "Email",
                      controller: _emailController,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Enter email";
                        if (!emailRegex.hasMatch(val))
                          return "Enter valid email";
                        return null;
                      },
                      borderColor: (_emailServerError != null || !_isEmailValid)
                          ? AppColors.error
                          : AppColors.accentOrange,
                      serverError: _emailServerError,
                      focusNode: _emailFN,
                    ),
                    const SizedBox(height: 10),

                    _buildTextField(
                      icon: Icons.phone,
                      hint: "Phone Number",
                      controller: _phoneController,
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return "Enter phone number";
                        if (!phoneRegex.hasMatch(val))
                          return "Must be 11 digits starting with 03";
                        return null;
                      },
                      borderColor: (_phoneServerError != null || !_isPhoneValid)
                          ? AppColors.error
                          : AppColors.accentOrange,
                      serverError: _phoneServerError,
                      focusNode: _phoneFN,
                    ),
                    const SizedBox(height: 10),

                    _buildTextField(
                      icon: Icons.badge,
                      hint: "CNIC",
                      controller: _cnicController,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Enter CNIC";
                        if (val.length != 15)
                          return "Must be 13 digits (XXXXX-XXXXXXX-X)";
                        return null;
                      },
                      borderColor: (_cnicServerError != null)
                          ? AppColors.error
                          : AppColors.accentOrange,
                      serverError: _cnicServerError,
                      focusNode: _cnicFN,
                    ),
                    const SizedBox(height: 10),

                    _buildPasswordField("Password", true, _passwordController, (
                      val,
                    ) {
                      if (val == null || val.isEmpty) return "Enter password";
                      if (!passwordRegex.hasMatch(val)) {
                        return "8+ chars, 1 upper, 1 lower, 1 number, 1 special";
                      }
                      return null;
                    }),
                    const SizedBox(height: 10),

                    _buildPasswordField(
                      "Confirm Password",
                      false,
                      _confirmPasswordController,
                      (val) {
                        if (val != _passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Role Selection Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: AppColors.lightSeaGreen,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Choose Account Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.background,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  _onRoleChanged(AppConstants.rolePassenger),
                              child: Container(
                                height: 45,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _selectedRole ==
                                          AppConstants.rolePassenger
                                      ? AppColors.accentOrange.withOpacity(0.9)
                                      : AppColors.background.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color:
                                        _selectedRole ==
                                            AppConstants.rolePassenger
                                        ? AppColors.accentOrange
                                        : AppColors.accentOrange,
                                    width:
                                        _selectedRole ==
                                            AppConstants.rolePassenger
                                        ? 2
                                        : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color:
                                          _selectedRole ==
                                              AppConstants.rolePassenger
                                          ? AppColors.textWhite
                                          : AppColors.background,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Passenger',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            _selectedRole ==
                                                AppConstants.rolePassenger
                                            ? AppColors.textWhite
                                            : AppColors.background,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  _onRoleChanged(AppConstants.roleManager),
                              child: Container(
                                height: 45,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _selectedRole == AppConstants.roleManager
                                      ? AppColors.accentOrange.withOpacity(0.9)
                                      : AppColors.background.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color:
                                        _selectedRole ==
                                            AppConstants.roleManager
                                        ? AppColors.accentOrange
                                        : AppColors.accentOrange,
                                    width:
                                        _selectedRole ==
                                            AppConstants.roleManager
                                        ? 2
                                        : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.business,
                                      color:
                                          _selectedRole ==
                                              AppConstants.roleManager
                                          ? AppColors.textWhite
                                          : AppColors.background,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Manager',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            _selectedRole ==
                                                AppConstants.roleManager
                                            ? AppColors.textWhite
                                            : AppColors.background,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedRole == AppConstants.roleManager) ...[
                        const SizedBox(height: 15),
                        _buildTextField(
                          icon: Icons.business,
                          hint: "Business Name",
                          controller: _companyNameController,
                          validator: (val) =>
                              _selectedRole == AppConstants.roleManager &&
                                  (val == null || val.isEmpty)
                              ? "Enter business name"
                              : null,
                          borderColor: AppColors.accentOrange,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _credentialDetailsController,
                          maxLines: null,
                          minLines: 3,
                          style: TextStyle(color: AppColors.background),
                          decoration: InputDecoration(
                            labelText: "Business Details & Credentials",
                            prefixIcon: Icon(
                              Icons.description,
                              color: AppColors.background.withOpacity(0.85),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: AppColors.accentOrange,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: AppColors.accentOrange,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: AppColors.accentOrange,
                                width: 2,
                              ),
                            ),
                            errorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                              borderSide: BorderSide(color: AppColors.error),
                            ),
                            focusedErrorBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.error,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.transparent,
                            alignLabelWithHint: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            isDense: true,
                            labelStyle: TextStyle(color: AppColors.background),
                            floatingLabelStyle: TextStyle(
                              color: AppColors.background,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          validator: (val) =>
                              _selectedRole == AppConstants.roleManager &&
                                  (val == null || val.isEmpty)
                              ? "Enter business details"
                              : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Terms & Conditions Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "By signing up you agree to our Terms & Conditions & Privacy Policy",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onBackground.withOpacity(0.6),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Sign Up Button
              SizedBox(
                width: 200,
                height: 40,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: AppColors.lightSeaGreen,
                        )
                      : Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 16, color: cs.onPrimary),
                        ),
                ),
              ),

              const SizedBox(height: 10),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an Account? ",
                    style: TextStyle(color: cs.onBackground),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: AppColors.lightSeaGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    Color borderColor = AppColors.accentOrange,
    String? serverError,
    FocusNode? focusNode,
  }) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      validator: validator,
      cursorColor: cs.secondary,
      cursorWidth: 2,
      cursorRadius: const Radius.circular(2),
      style: TextStyle(color: AppColors.background),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.background.withOpacity(0.85)),
        labelText: hint,
        labelStyle: TextStyle(color: AppColors.background),
        floatingLabelStyle: TextStyle(
          color: AppColors.background,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: AppColors.transparent,
        errorText: serverError,
        errorMaxLines: 2,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: cs.secondary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      keyboardType: (hint == "Phone Number" || hint == "CNIC")
          ? TextInputType.number
          : TextInputType.text,
      inputFormatters: (hint == "Phone Number" || hint == "CNIC")
          ? [FilteringTextInputFormatter.digitsOnly]
          : [],
    );
  }

  Widget _buildPasswordField(
    String hint,
    bool isPassword,
    TextEditingController controller,
    String? Function(String?)? validator,
  ) {
    final cs = Theme.of(context).colorScheme;

    return StatefulBuilder(
      builder: (context, setState) => TextFormField(
        controller: controller,
        obscureText: isPassword
            ? !_isPasswordVisible
            : !_isConfirmPasswordVisible,
        validator: validator,
        cursorColor: cs.secondary,
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
              isPassword
                  ? (_isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off)
                  : (_isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
              color: AppColors.background.withOpacity(0.75),
            ),
            onPressed: () {
              setState(() {
                if (isPassword) {
                  _isPasswordVisible = !_isPasswordVisible;
                } else {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                }
              });
            },
          ),
          labelText: hint,
          labelStyle: TextStyle(color: AppColors.background),
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
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: AppColors.accentOrange),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: cs.secondary, width: 2),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: AppColors.error, width: 2),
          ),
        ),
      ),
    );
  }
}
