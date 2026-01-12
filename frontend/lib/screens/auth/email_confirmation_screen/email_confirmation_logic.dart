part of email_confirmation_screen;

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  bool _isLoading = false;
  bool _isResending = false;
  String? _message;
  Timer? _resendTimer;
  int _resendCountdown = 0;
  bool _confirmationShown = false; // Prevent repeated confirmation snackbars

  final supabase = Supabase.instance.client;

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
      print('DEBUG: User authenticated and has profile');
      // User is authenticated and has profile, check if email is confirmed
      final user = Supabase.instance.client.auth.currentUser;
      print(
        'DEBUG: Supabase currentUser: ${user?.email}, emailConfirmedAt: ${user?.emailConfirmedAt}',
      );
      if (user != null && user.emailConfirmedAt != null) {
        print('DEBUG: Email confirmed, calling _showSuccessAndNavigate');
        _showSuccessAndNavigate();
      } else {
        print('DEBUG: Email not confirmed yet');
      }
    } else {
      print('DEBUG: User not authenticated or no profile yet');
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _listenForAuthChanges() {
    print('DEBUG: EmailConfirmationScreen _listenForAuthChanges setup');
    supabase.auth.onAuthStateChange.listen((event) {
      print('DEBUG: Auth state change: ${event.event}');
      if (event.event == AuthChangeEvent.signedIn && mounted) {
        print(
          'DEBUG: Signed in event received, calling _showSuccessAndNavigate',
        );
        // Email confirmed successfully
        _showSuccessAndNavigate();
      }
    });
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

      // Navigate to appropriate screen based on role
      Widget nextScreen;
      switch (widget.role) {
        case AppConstants.roleManager:
          print('DEBUG: Navigating to ManagerHomeShell');
          nextScreen = const ManagerHomeUI(data: ManagerHomeData());
          break;
        case AppConstants.rolePassenger:
        default:
          print('DEBUG: Navigating to HomeShell');
          nextScreen = const PassengerHomeUI(data: PassengerHomeData());
          break;
      }

      print('DEBUG: Performing navigation to ${nextScreen.runtimeType}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );
      print('DEBUG: Navigation completed');
    });
  }

  Future<void> _resendConfirmationEmail() async {
    if (_isResending || _resendCountdown > 0) return;

    setState(() {
      _isResending = true;
      _message = null;
    });

    try {
      print(
        'DEBUG: Attempting to resend confirmation email to ${widget.email}',
      );
      await supabase.auth.resend(type: OtpType.signup, email: widget.email);

      print('DEBUG: Resend email successful');
      setState(() {
        _message = confirmationEmailSentMessage;
        _resendCountdown = resendCountdownDuration; // cooldown
      });

      // Start countdown timer
      _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _resendCountdown--;
            if (_resendCountdown <= 0) {
              timer.cancel();
            }
          });
        } else {
          timer.cancel();
        }
      });
    } catch (e) {
      print('DEBUG: Resend email failed: $e');
      String errorMessage = failedToResendMessage;

      // Provide more specific error messages
      if (e.toString().contains('User not found')) {
        errorMessage = userNotFoundMessage;
      } else if (e.toString().contains('rate limit')) {
        errorMessage = rateLimitMessage;
      } else if (e.toString().contains('SMTP') ||
          e.toString().contains('email')) {
        errorMessage = emailServiceUnavailableMessage;
      }

      setState(() {
        _message = errorMessage;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      // First, try to refresh the session if we have one
      final currentSession = supabase.auth.currentSession;
      if (currentSession != null) {
        try {
          await supabase.auth.refreshSession();
        } catch (e) {
          print('DEBUG: Refresh session failed: $e');
        }
      }

      // Check current user
      final user = supabase.auth.currentUser;

      print('DEBUG: Checking verification status');
      print('DEBUG: Current user: ${user?.email}');
      print('DEBUG: Session exists: ${currentSession != null}');
      print('DEBUG: Email confirmed: ${user?.emailConfirmedAt != null}');

      if (user != null && user.emailConfirmedAt != null) {
        print('DEBUG: Email confirmed, navigating...');
        _showSuccessAndNavigate();
        return;
      }

      // If no user or not confirmed, try to get user from server
      try {
        final userResponse = await supabase.auth.getUser();
        final serverUser = userResponse.user;
        if (serverUser != null && serverUser.emailConfirmedAt != null) {
          print('DEBUG: Email confirmed from server, navigating...');
          _showSuccessAndNavigate();
          return;
        }
      } catch (e) {
        print('DEBUG: getUser failed: $e');
      }

      // Not confirmed yet
      setState(() {
        _message = emailNotConfirmedMessage;
      });
    } catch (e) {
      print('DEBUG: Error checking verification status: $e');
      setState(() {
        _message = unableToCheckStatusMessage;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => _buildEmailConfirmationUI(this, widget);
}
