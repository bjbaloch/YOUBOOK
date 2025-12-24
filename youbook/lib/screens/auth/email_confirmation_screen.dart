import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/auth_provider.dart';
import '../passenger/home_shell.dart';
import '../manager/manager_dashboard.dart';
import '../manager/manager_waiting_screen.dart';
import 'login_screen.dart';

class EmailConfirmationScreen extends StatefulWidget {
  final String email;
  final String role;
  final String? companyName;
  final String? credentialDetails;

  const EmailConfirmationScreen({
    super.key,
    required this.email,
    required this.role,
    this.companyName,
    this.credentialDetails,
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
    print('DEBUG: AuthProvider isAuthenticated: ${authProvider.isAuthenticated}, user: ${authProvider.user}');
    if (authProvider.isAuthenticated && authProvider.user != null) {
      print('DEBUG: User authenticated and has profile');
      // User is authenticated and has profile, check if email is confirmed
      final user = Supabase.instance.client.auth.currentUser;
      print('DEBUG: Supabase currentUser: ${user?.email}, emailConfirmedAt: ${user?.emailConfirmedAt}');
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
        print('DEBUG: Signed in event received, calling _showSuccessAndNavigate');
        // Email confirmed successfully
        _showSuccessAndNavigate();
      }
    });
  }

  void _showSuccessAndNavigate() {
    print('DEBUG: _showSuccessAndNavigate called');
    if (!mounted) {
      print('DEBUG: Component not mounted, returning');
      return;
    }

    print('DEBUG: Showing success snackbar');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email confirmed successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to appropriate screen based on role
    Widget nextScreen;
    switch (widget.role) {
      case AppConstants.roleManager:
        print('DEBUG: Navigating to ManagerWaitingScreen');
        nextScreen = ManagerWaitingScreen(
          companyName: widget.companyName,
          credentialDetails: widget.credentialDetails,
        );
        break;
      case AppConstants.rolePassenger:
      default:
        print('DEBUG: Navigating to HomeShell');
        nextScreen = const HomeShell();
        break;
    }

    print('DEBUG: Performing navigation to ${nextScreen.runtimeType}');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
    print('DEBUG: Navigation completed');
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
        _message = 'Confirmation email sent successfully!';
        _resendCountdown = 60; // 60 seconds cooldown
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
      String errorMessage = 'Failed to resend email.';

      // Provide more specific error messages
      if (e.toString().contains('User not found')) {
        errorMessage = 'User account not found. Please sign up again.';
      } else if (e.toString().contains('rate limit')) {
        errorMessage = 'Too many requests. Please wait before trying again.';
      } else if (e.toString().contains('SMTP') ||
          e.toString().contains('email')) {
        errorMessage =
            'Email service temporarily unavailable. Please try again later.';
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
        _message = 'Email not yet confirmed. Please check your email and click the confirmation link.';
      });
    } catch (e) {
      print('DEBUG: Error checking verification status: $e');
      setState(() {
        _message = 'Unable to check verification status. Please try again.';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSeaGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Email icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: 50,
                  color: AppColors.accentOrange,
                ),
              ),

              const SizedBox(height: 30),

              // Title
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "Check Your\n",
                      style: TextStyle(color: AppColors.background),
                    ),
                    TextSpan(
                      text: "Email",
                      style: TextStyle(color: AppColors.logoYellow),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Subtitle
              Text(
                'We sent a confirmation link to',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.background.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Email address
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentOrange),
                ),
                child: Text(
                  widget.email,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.background,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 8),

              // Instruction text
              Text(
                'Click the link in the email to verify your account and start using YOUBOOK.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.background.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Status message
              if (_message != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _message!.contains('successfully')
                        ? AppColors.circleGreen
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _message!.contains('successfully')
                          ? AppColors.circleGreen
                          : AppColors.accentOrange,
                    ),
                  ),
                  child: Text(
                    _message!,
                    style: TextStyle(
                      color: _message!.contains('successfully')
                          ? AppColors.circleGreen
                          : AppColors.accentOrange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              if (_message != null) const SizedBox(height: 20),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkVerificationStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.lightSeaGreen,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textWhite,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 1),

              // Resend email button
              TextButton(
                onPressed: (_isResending || _resendCountdown > 0)
                    ? null
                    : _resendConfirmationEmail,
                child: Text(
                  _resendCountdown > 0
                      ? 'Resend email in ${_resendCountdown}s'
                      : _isResending
                      ? 'Sending...'
                      : 'Didn\'t receive the email? Resend',
                  style: TextStyle(
                    color: (_isResending || _resendCountdown > 0)
                        ? AppColors.background
                        : AppColors.accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              // Back to login
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: Text(
                  'Back to Login',
                  style: TextStyle(color: AppColors.accentOrange, fontSize: 14),
                ),
              ),

              const SizedBox(height: 2),

              // Help text
              Text(
                'or Check your spam folder if you don\'t see the email in your inbox.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.background.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
