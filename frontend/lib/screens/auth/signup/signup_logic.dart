part of signup_screen;

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cnicController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
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

  // Live validation states
  bool _isPasswordValid = false;
  bool _isEmailValid = true;
  bool _isPhoneValid = true;
  bool _isCnicValid = true;

  String? _emailServerError;
  String? _phoneServerError;
  String? _cnicServerError;

  final supabase = Supabase.instance.client;



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
      if (showNoInternetSnack) {
        SnackBarUtils.showSnackBar(
          context,
          'No internet connection',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      print("DEBUG: Signup failed with error: $e");
      print("DEBUG: Error type: ${e.runtimeType}");
      SnackBarUtils.showSnackBar(
        context,
        'Something went wrong: $e',
        type: SnackBarType.error,
      );
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
      if (showNoInternetSnack) {
        SnackBarUtils.showSnackBar(
          context,
          'No internet connection',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (showNoInternetSnack) {
        SnackBarUtils.showSnackBar(
          context,
          'Something went wrong',
          type: SnackBarType.error,
        );
      }
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
      if (showNoInternetSnack) {
        SnackBarUtils.showSnackBar(
          context,
          'No internet connection',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (showNoInternetSnack) {
        SnackBarUtils.showSnackBar(
          context,
          'Something went wrong',
          type: SnackBarType.error,
        );
      }
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
      SnackBarUtils.showSnackBar(
        context,
        'No internet connection',
        type: SnackBarType.error,
      );
      return false;
    } catch (e) {
      if (e.toString().contains('Network') || e.toString().contains('Socket')) {
        SnackBarUtils.showSnackBar(
          context,
          'No internet connection',
          type: SnackBarType.error,
        );
      } else {
        SnackBarUtils.showSnackBar(
          context,
          'Something went wrong while checking availability',
          type: SnackBarType.error,
        );
      }
      return false;
    }
  }

  void _onRoleChanged(String? role) {
    setState(() {
      _selectedRole = role ?? AppConstants.rolePassenger;
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
    print("=== SIGNUP DEBUG START ===");
    print("DEBUG: Signup attempt for role: $_selectedRole");

    if (!_formKey.currentState!.validate()) {
      print("DEBUG: Form validation failed");
      return;
    }
    print("DEBUG: Form validation passed");

    if (_selectedRole.isEmpty) {
      print("DEBUG: Role not selected, showing snackbar");
      SnackBarUtils.showSnackBar(
        context,
        'Please select an account type (Passenger or Manager)',
        type: SnackBarType.other,
      );
      return;
    }
    print("DEBUG: Role validation passed");

    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      print("DEBUG: No internet connection");
      SnackBarUtils.showSnackBar(
        context,
        'No internet connection',
        type: SnackBarType.error,
      );
      return;
    }
    print("DEBUG: Internet connection available");

    setState(() => _isLoading = true);
    print("DEBUG: Set loading state to true");

    try {
      print("DEBUG: Checking field availability...");
      final ok = await _checkFieldAvailability();
      if (!ok) {
        print("DEBUG: Field availability check failed");
        return;
      }
      print("DEBUG: Field availability check passed");

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final fullName =
          '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

      print("DEBUG: Calling authProvider.signup with:");
      print("  - Email: ${_emailController.text.trim()}");
      print("  - Full Name: $fullName");
      print("  - Role: $_selectedRole");

      final success = await authProvider.signup(
        _emailController.text.trim(),
        _passwordController.text,
        fullName.trim(),
        phoneNumber: _phoneController.text.trim(),
        cnic: _cnicController.text.trim().isNotEmpty
            ? _cnicController.text.trim()
            : null,
        role: _selectedRole,
      );

      print("DEBUG: Signup call returned success: $success");

      if (success && mounted) {
        print(
          "DEBUG: Signup successful, confirmation email sent. Navigating to email confirmation screen",
        );
        print("DEBUG: Email: ${_emailController.text.trim()}");
        print("DEBUG: Role: $_selectedRole");
        print("DEBUG: User is NOT authenticated yet - waiting for email confirmation");

        SnackBarUtils.showSnackBar(
          context,
          'Account created successfully! Please check your email for confirmation.',
          type: SnackBarType.success,
        );

        // Store signup data for email confirmation screen
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('pending_email', _emailController.text.trim());
        await prefs.setString('pending_role', _selectedRole);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailConfirmationScreen(
              email: _emailController.text.trim(),
              role: _selectedRole,
            ),
          ),
        );
      } else if (!success && mounted) {
        print("DEBUG: Signup returned false");
        print("DEBUG: Auth provider error: ${authProvider.error}");
        SnackBarUtils.showSnackBar(
          context,
          authProvider.error ?? 'Failed to create account. Please try again.',
          type: SnackBarType.error,
        );
      } else {
        print("DEBUG: Component not mounted or unexpected state");
      }
    } catch (e) {
      print("DEBUG: Signup failed with error: $e");
      print("DEBUG: Error type: ${e.runtimeType}");
      SnackBarUtils.showSnackBar(
        context,
        'Something went wrong: $e',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        print("DEBUG: Set loading state to false");
      }
      print("=== SIGNUP DEBUG END ===");
    }
  }

  @override
  void initState() {
    super.initState();

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
  Widget build(BuildContext context) => _buildSignupUI(this);
}
