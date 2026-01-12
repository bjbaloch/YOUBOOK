import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../../screens/auth/login/login_screen.dart';

class LogoutDialog {
  static void show(BuildContext context, {String? currentScreen}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        // Responsive calculations
        final screenSize = MediaQuery.of(context).size;
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;

        // Adaptive dialog width: 90% of screen width, max 400px
        final dialogWidth = screenWidth < 400 ? screenWidth * 0.9 : 400.0;

        // Adaptive padding: scales from 16px (small) to 24px (large)
        final padding = screenWidth < 400 ? 16.0 : (screenWidth < 600 ? 20.0 : 24.0);

        // Adaptive icon size: scales with screen size
        final iconSize = screenWidth < 400 ? 40.0 : 48.0;

        // Adaptive text sizes
        final titleSize = screenWidth < 400 ? 20.0 : 24.0;
        final subtitleSize = screenWidth < 400 ? 14.0 : 16.0;
        final bodySize = screenWidth < 400 ? 12.0 : 14.0;
        final buttonSize = screenWidth < 400 ? 14.0 : 16.0;

        // Check if buttons should be stacked (small screens)
        final stackButtons = screenWidth < 400;

        return Dialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          child: Container(
            width: dialogWidth,
            padding: EdgeInsets.all(padding),
            constraints: BoxConstraints(
              maxWidth: dialogWidth,
              maxHeight: screenHeight * 0.8, // Prevent overflow on very small screens
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon Header
                  Container(
                    padding: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                      color: AppColors.lightSeaGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      size: iconSize,
                      color: AppColors.lightSeaGreen,
                    ),
                  ),
                  SizedBox(height: padding),

                  // Title
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppColors.lightSeaGreen,
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: padding * 0.5),

                  // Subtitle
                  Text(
                    'Are you sure you want to sign out?',
                    style: TextStyle(
                      color: AppColors.lightSeaGreen.withOpacity(0.8),
                      fontSize: subtitleSize,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: padding * 0.3),

                  // Additional info
                  Text(
                    'You will need to sign in again to access your account.',
                    style: TextStyle(
                      color: AppColors.lightSeaGreen.withOpacity(0.6),
                      fontSize: bodySize,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: padding * 1.3),

                  // Buttons - responsive layout
                  if (stackButtons)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logout Button (primary action first on mobile)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              // Store current screen state for return navigation first
                              final prefs = await SharedPreferences.getInstance();
                              if (currentScreen != null && currentScreen.isNotEmpty && currentScreen != 'company_details') {
                                await prefs.setString('last_manager_screen', currentScreen);
                              }

                              // Perform logout while context is still valid
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              await authProvider.logout();

                              // Close dialog after logout is complete
                              Navigator.of(context).pop();

                              // Navigate to appropriate screen
                              if (currentScreen == 'company_details' || currentScreen == 'manager' || currentScreen == 'passenger') {
                                // Navigate directly to login screen
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (Route<dynamic> route) => false,
                                );
                              } else {
                                // Navigate to splash screen (normal behavior)
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/',
                                  (Route<dynamic> route) => false,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: AppColors.textWhite,
                              padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                              elevation: 2,
                              shadowColor: AppColors.error.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: buttonSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Cancel Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.lightSeaGreen,
                              side: BorderSide(
                                color: AppColors.accentOrange,
                                width: 2,
                              ),
                              padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: buttonSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.lightSeaGreen,
                              side: BorderSide(
                                color: AppColors.accentOrange,
                                width: 2,
                              ),
                              padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: buttonSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Logout Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              // Store current screen state for return navigation first
                              final prefs = await SharedPreferences.getInstance();
                              if (currentScreen != null && currentScreen.isNotEmpty && currentScreen != 'company_details') {
                                await prefs.setString('last_manager_screen', currentScreen);
                              }

                              // Perform logout while context is still valid
                              final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              );
                              await authProvider.logout();

                              // Close dialog after logout is complete
                              Navigator.of(context).pop();

                              // Navigate to appropriate screen
                              if (currentScreen == 'company_details' || currentScreen == 'manager' || currentScreen == 'passenger') {
                                // Navigate directly to login screen
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (Route<dynamic> route) => false,
                                );
                              } else {
                                // Navigate to splash screen (normal behavior)
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/',
                                  (Route<dynamic> route) => false,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: AppColors.textWhite,
                              padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                              elevation: 2,
                              shadowColor: AppColors.error.withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: buttonSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
