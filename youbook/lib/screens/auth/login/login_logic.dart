part of login_screen;

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
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Clear any previous errors
    authProvider.clearError();

    try {
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        print(
          "DEBUG: Login successful, navigating based on role: ${authProvider.userRole}",
        );

        // Show success message as snackbar
        SnackBarUtils.showSnackBar(
          context,
          'Login successful!',
          type: SnackBarType.success,
        );

        // Add a small delay to allow the message to be seen
        await Future.delayed(Duration(seconds: 2));

        if (mounted) {
          _navigateBasedOnRole(authProvider);
        }
      } else if (mounted) {
        print("DEBUG: Login failed with error: ${authProvider.error}");
        // Show user-friendly error message as snackbar
        String errorMessage = _getUserFriendlyErrorMessage(authProvider.error);
        SnackBarUtils.showSnackBar(
          context,
          errorMessage,
          type: SnackBarType.error,
        );
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
      SnackBarUtils.showSnackBar(
        context,
        errorMessage,
        type: SnackBarType.error,
      );
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
  Widget build(BuildContext context) => _buildLoginUI(this);
}
