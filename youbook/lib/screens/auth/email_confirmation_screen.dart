import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../passenger/home_shell.dart';
import '../manager/manager_dashboard.dart';
import 'login_screen.dart';

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

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _listenForAuthChanges();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _listenForAuthChanges() {
    supabase.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedIn && mounted) {
        // Email confirmed successfully
        _showSuccessAndNavigate();
      }
    });
  }

  void _showSuccessAndNavigate() {
    if (!mounted) return;

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
        nextScreen = const ManagerDashboard();
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
      // Get current session
      final session = supabase.auth.currentSession;
      final user = supabase.auth.currentUser;

      print('DEBUG: Checking verification status');
      print('DEBUG: Current user: ${user?.email}');
      print('DEBUG: Session exists: ${session != null}');
      print('DEBUG: Email confirmed: ${user?.emailConfirmedAt != null}');

      if (user != null && user.emailConfirmedAt != null) {
        print('DEBUG: Email confirmed, navigating...');
        _showSuccessAndNavigate();
      } else if (user != null && user.email == widget.email) {
        // User exists but email not confirmed
        setState(() {
          _message =
              'Email not yet confirmed. Please check your email and click the confirmation link.';
        });
      } else {
        // No user session, try to check if user was created
        try {
          // Try to sign in to refresh session (this might work if email was confirmed)
          await supabase.auth.signInWithPassword(
            email: widget.email,
            password:
                'dummy_password', // This will fail but might refresh session
          );
        } catch (signInError) {
          print('DEBUG: Sign in failed (expected): $signInError');
        }

        // Check again after attempted sign in
        final updatedUser = supabase.auth.currentUser;
        if (updatedUser != null && updatedUser.emailConfirmedAt != null) {
          print('DEBUG: Email confirmed after refresh, navigating...');
          _showSuccessAndNavigate();
        } else {
          setState(() {
            _message =
                'Email not yet confirmed. Please check your email and click the confirmation link, then try again.';
          });
        }
      }
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
                      ? CircularProgressIndicator(
                          color: AppColors.lightSeaGreen,
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
