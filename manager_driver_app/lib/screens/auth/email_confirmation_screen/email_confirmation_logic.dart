part of email_confirmation_screen;

class EmailConfirmationScreen extends StatefulWidget {
  final String email;
  final String role;

  const EmailConfirmationScreen({
    super.key,
    required this.email,
    required this.role,
  });

  @override
  State<EmailConfirmationScreen> createState() =>
      _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  bool _isLoading = false;
  bool _isResending = false;
  String? _message;
  Timer? _resendTimer;
  int _resendCountdown = 0;
  bool _confirmationShown = false; // Prevent repeated confirmation snackbars

  // TODO: Restore when connecting backend

  @override
  void initState() {
    super.initState();
    _listenForAuthChanges();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('DEBUG: EmailConfirmationScreen didChangeDependencies called');
    // Listen for AuthProvider changes
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    print(
      'DEBUG: AuthProvider isAuthenticated: ${authProvider.isAuthenticated}, user: ${authProvider.user}',
    );
    if (authProvider.isAuthenticated && authProvider.user != null) {
      // TODO: Restore Supabase email confirmation check when connecting backend
    } else {
      // not authenticated
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _listenForAuthChanges() {
    // TODO: Restore Supabase auth listener when connecting backend
  }

  void _showSuccessAndNavigate() {
    print('DEBUG: _showSuccessAndNavigate called');
    if (!mounted || _confirmationShown) {
      print(
        'DEBUG: Component not mounted or confirmation already shown, returning',
      );
      return;
    }

    _confirmationShown = true; // Mark as shown to prevent repeats

    // Schedule snackbar and navigation for after build completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return; // Double-check mounted after callback

      print('DEBUG: Showing success snackbar (first time only)');
      SnackBarUtils.showSnackBar(
        context,
        'Email confirmed successfully!',
        type: SnackBarType.success,
      );

      // Navigate based on role
      print('DEBUG: Navigating based on role: ${widget.role}');
      if (mounted) {
        // TODO: Navigate to appropriate home screen based on role
        // For now, navigate to login screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  Future<void> _resendConfirmationEmail() async {
    if (_isResending || _resendCountdown > 0) return;
    setState(() { _isResending = true; _message = null; });
    // TODO: Restore Supabase resend when connecting backend
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() { _message = confirmationEmailSentMessage; _isResending = false; });
  }

  @override
  Widget build(BuildContext context) {
    return _buildEmailConfirmationUI(this, widget);
  }
}
