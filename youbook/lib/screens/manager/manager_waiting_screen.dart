import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/snackbar_utils.dart';
import '../auth/login/login_screen.dart';
import 'manager_dashboard.dart';

class ManagerWaitingScreen extends StatefulWidget {
  final String? companyName;
  final String? credentialDetails;

  const ManagerWaitingScreen({
    super.key,
    this.companyName,
    this.credentialDetails,
  });

  @override
  State<ManagerWaitingScreen> createState() => _ManagerWaitingScreenState();
}

class _ManagerWaitingScreenState extends State<ManagerWaitingScreen> {
  bool _isSubmitting = false;
  bool _hasSubmitted = false; // Track if application has already been submitted
  bool _isLoading = false; // Loading state for verification checks

  @override
  void initState() {
    super.initState();
    // Store screen preference for navigation persistence
    _storeScreenPreference();
    // Only submit application once when screen is first created
    if (!_hasSubmitted) {
      _submitApplication();
    }
  }

  Future<void> _storeScreenPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_manager_screen', 'waiting');
    } catch (e) {
      // Silently handle SharedPreferences errors
      print('Error storing screen preference: $e');
    }
  }

  Future<void> _submitApplication() async {
    if (widget.companyName == null || widget.credentialDetails == null) {
      return;
    }

    // Prevent multiple submissions
    if (_hasSubmitted) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.applyForManager(
        widget.companyName!,
        widget.credentialDetails!,
      );

      // Mark as submitted regardless of success/failure to prevent retries
      _hasSubmitted = true;

      if (!mounted) return;

      if (success) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            SnackBarUtils.showSnackBar(
              context,
              'Manager application submitted successfully!',
              type: SnackBarType.success,
            );
          }
        });
      }
      // Remove failure snackbar as requested
    } catch (e) {
      // Mark as submitted even on error to prevent infinite retries
      _hasSubmitted = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          SnackBarUtils.showSnackBar(
            context,
            'Error: ${e.toString()}',
            type: SnackBarType.error,
          );
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if manager application is approved
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isApproved = await authProvider.isManagerApplicationApproved();

      if (!mounted) return;

      if (isApproved) {
        // Application approved, navigate to dashboard
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ManagerDashboard()),
            );
          }
        });
      } else {
        // Still pending, show message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            SnackBarUtils.showSnackBar(
              context,
              'Application is still under review. Please check back later.',
              type: SnackBarType.other,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            SnackBarUtils.showSnackBar(
              context,
              'Error checking status: ${e.toString()}',
              type: SnackBarType.error,
            );
          }
        });
      }
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
      appBar: AppBar(
        backgroundColor: AppColors.lightSeaGreen,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back arrow
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: SizedBox(
              child: OutlinedButton(
                onPressed: () => SystemNavigator.pop(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.accentOrange, width: 1.5),
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets
                      .zero, // Remove padding to fit exactly in 40 height
                  minimumSize: const Size(
                    100,
                    40,
                  ), // Ensure minimum size is 40 height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Quit App',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hourglass icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.hourglass_empty,
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
                      text: "Application\n",
                      style: TextStyle(color: AppColors.background),
                    ),
                    TextSpan(
                      text: "Under Review",
                      style: TextStyle(color: AppColors.logoYellow),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Subtitle
              Text(
                'Your manager application has been submitted and is being reviewed by our team.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.background.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Instruction text
              Text(
                'You will receive an email notification within 48 hours once your application is approved. Please check your email regularly.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.background.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Status indicator
              if (_isSubmitting)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accentOrange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Submitting application...',
                        style: TextStyle(
                          color: AppColors.background,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.circleGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.circleGreen),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppColors.circleGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Application submitted successfully!',
                        style: TextStyle(
                          color: AppColors.circleGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 40),

              const Spacer(), // Push content up, support info to bottom
              // Additional support text
              Text(
                'Have any question or for more information contact to our support team.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.background.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Support contact information
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Support:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.background,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Email contact - clickable
                    GestureDetector(
                      onTap: () async {
                        // Add haptic feedback
                        if (!kIsWeb) {
                          HapticFeedback.lightImpact();
                        }

                        try {
                          // Simple direct launch - more reliable than canLaunchUrl check
                          final Uri emailUri = Uri.parse(
                            'mailto:youbook210@gmail.com?subject=YOUBOOK Manager Application Support&body=Hello YOUBOOK Support Team,%0A%0AI need assistance with my manager application.%0A%0ABest regards,',
                          );

                          await launchUrl(
                            emailUri,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (e) {
                          if (mounted) {
                            SnackBarUtils.showSnackBar(
                              context,
                              'Could not open email app',
                              type: SnackBarType.other,
                            );
                          }
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.email,
                            size: 20,
                            color: AppColors.accentOrange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'youbook210@gmail.com',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.background.withOpacity(0.9),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.accentOrange,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    Divider(
                      color: AppColors.background.withOpacity(0.3),
                      thickness: 1,
                      indent: 0,
                      endIndent: 0,
                    ),
                    const SizedBox(height: 12),

                    // WhatsApp contact - clickable
                    GestureDetector(
                      onTap: () async {
                        // Add haptic feedback
                        if (!kIsWeb) {
                          HapticFeedback.lightImpact();
                        }

                        try {
                          // Simple direct launch - more reliable than canLaunchUrl check
                          final Uri whatsappUri = Uri.parse(
                            'https://wa.me/923171292355',
                          );

                          await launchUrl(
                            whatsappUri,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (e) {
                          if (mounted) {
                            SnackBarUtils.showSnackBar(
                              context,
                              'Could not open WhatsApp',
                              type: SnackBarType.other,
                            );
                          }
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 20,
                            color: AppColors.accentOrange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '03171292355',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.background.withOpacity(0.9),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.accentOrange,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quit app button
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
                          'Check Status',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textWhite,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
