part of signup_screen;

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
  bool _acceptTerms = true;
  bool _isLoading = false;

  // Role selection
  String _selectedRole = AppConstants.roleManager;

  // Live validation states
  bool _isPasswordValid = false;
  bool _isEmailValid = true;
  bool _isPhoneValid = true;
  bool _isCnicValid = true;

  String? _emailServerError;
  String? _phoneServerError;
  String? _cnicServerError;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      final currentText = _emailController.text;
      final canonicalText = _canonicalEmail(currentText);

      if (currentText != canonicalText) {
        _emailController.value = _emailController.value.copyWith(
          text: canonicalText,
          selection: TextSelection.collapsed(offset: canonicalText.length),
        );
      }

      final valid = emailRegex.hasMatch(canonicalText);
      if (mounted) {
        setState(() {
          _isEmailValid = valid;
        });
      }
    });

    _emailFN.addListener(() {
      if (!_emailFN.hasFocus) {
        final canonicalText = _canonicalEmail(_emailController.text);
        setState(() {
          _isEmailValid = emailRegex.hasMatch(canonicalText);
        });
        if (_isEmailValid && canonicalText.isNotEmpty) {
          _checkEmailAvailability(showNoInternetSnack: false);
        }
      }
    });

    // Setup phone validation
    _phoneController.addListener(() {
      setState(() {
        _isPhoneValid = phoneRegex.hasMatch(_phoneController.text);
      });
    });

    _phoneFN.addListener(() {
      if (!_phoneFN.hasFocus && _phoneController.text.isNotEmpty) {
        if (_isPhoneValid) {
          _checkPhoneAvailability(showNoInternetSnack: false);
        }
      }
    });

    // Setup CNIC validation
    _cnicController.addListener(() {
      String value = _cnicController.text;
      _formatCnic(value);
      setState(() {
        _isCnicValid = value.replaceAll('-', '').length == 13;
      });
    });

    _cnicFN.addListener(() {
      if (!_cnicFN.hasFocus && _cnicController.text.isNotEmpty) {
        if (_isCnicValid) {
          _checkCnicAvailability(showNoInternetSnack: false);
        }
      }
    });

    // Setup password validation
    _passwordController.addListener(() {
      setState(() {
        _isPasswordValid = passwordRegex.hasMatch(_passwordController.text);
      });
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

  Future<void> _checkEmailAvailability({
    bool showNoInternetSnack = true,
  }) async {
    // TODO: Restore when connecting Supabase
    setState(() => _emailServerError = null);
  }

  Future<void> _checkPhoneAvailability({
    bool showNoInternetSnack = true,
  }) async {
    // TODO: Restore when connecting Supabase
    setState(() => _phoneServerError = null);
  }

  Future<void> _checkCnicAvailability({bool showNoInternetSnack = true}) async {
    // TODO: Restore when connecting Supabase
    setState(() => _cnicServerError = null);
  }

  Future<bool> _checkFieldAvailability() async {
    // TODO: Restore when connecting Supabase — skip server checks in UI-only mode
    setState(() {
      _emailServerError = null;
      _phoneServerError = null;
      _cnicServerError = null;
    });
    return true;
  }

  void _onRoleChanged(String? role) {
    setState(() {
      _selectedRole = role ?? AppConstants.roleManager;
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final fullName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signup(
      email,
      password,
      fullName,
      phoneNumber: _phoneController.text.trim(),
      cnic: _cnicController.text.trim(),
      role: _selectedRole,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      SnackBarUtils.showSnackBar(
        context,
        authProvider.error ?? 'Signup failed. Please try again.',
        type: SnackBarType.error,
      );
      return;
    }

    if (_selectedRole == AppConstants.roleManager) {
      AppRouter.replace(context, const ManagerCompanyDetailsScreen());
    } else {
      SnackBarUtils.showSnackBar(
        context,
        'Driver account created! Please sign in.',
        type: SnackBarType.success,
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => _buildSignupUI(this);
}
