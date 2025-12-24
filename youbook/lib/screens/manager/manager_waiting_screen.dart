import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _submitApplication();
  }

  Future<void> _submitApplication() async {
    if (widget.companyName == null || widget.credentialDetails == null) {
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

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Manager application submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit application. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSeaGreen,
      appBar: AppBar(
        title: const Text('Manager Application'),
        backgroundColor: AppColors.lightSeaGreen,
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (shouldLogout ?? false) {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.logout();

                // Navigate to login screen after logout
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              }
            },
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
                'You will receive an email notification once your application is approved. Please check your email regularly.',
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

              // Company info display
              if (widget.companyName != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Company Name:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.background,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.companyName!,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.background.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Help text
              Text(
                'If you have any questions, please contact our support team.',
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
