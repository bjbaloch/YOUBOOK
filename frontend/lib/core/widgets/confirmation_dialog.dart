import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ConfirmationDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    required VoidCallback onConfirm,
    String? subtitle,
    IconData? icon,
    Color? iconColor,
    Color? confirmButtonColor,
    bool barrierDismissible = true,
    bool showConfirmLoading = false,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: barrierDismissible,
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
                  // Icon Header (optional)
                  if (icon != null)
                    Container(
                      padding: EdgeInsets.all(padding),
                      decoration: BoxDecoration(
                        color: (iconColor ?? AppColors.lightSeaGreen).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: iconSize,
                        color: iconColor ?? AppColors.lightSeaGreen,
                      ),
                    ),
                  if (icon != null) SizedBox(height: padding),

                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.lightSeaGreen,
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: padding * 0.5),

                  // Subtitle (optional)
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.lightSeaGreen.withOpacity(0.8),
                        fontSize: subtitleSize,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  if (subtitle != null) SizedBox(height: padding * 0.3),

                  // Message
                  Text(
                    message,
                    style: TextStyle(
                      color: AppColors.lightSeaGreen.withOpacity(0.6),
                      fontSize: bodySize,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: padding * 1.3),

                  // Buttons - responsive layout
                  if (cancelText.isEmpty)
                    // Single button layout
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: showConfirmLoading ? null : () {
                          Navigator.of(context).pop();
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmButtonColor ?? AppColors.accentOrange,
                          foregroundColor: AppColors.textWhite,
                          padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                          elevation: 2,
                          shadowColor: (confirmButtonColor ?? AppColors.accentOrange).withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: showConfirmLoading
                            ? SizedBox(
                                height: buttonSize + 4,
                                width: buttonSize + 4,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                                ),
                              )
                            : Text(
                                confirmText,
                                style: TextStyle(
                                  fontSize: buttonSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    )
                  else if (stackButtons)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Confirm Button (primary action first on mobile)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: showConfirmLoading ? null : () {
                              Navigator.of(context).pop();
                              onConfirm();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: confirmButtonColor ?? AppColors.accentOrange,
                              foregroundColor: AppColors.textWhite,
                              padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                              elevation: 2,
                              shadowColor: (confirmButtonColor ?? AppColors.accentOrange).withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: showConfirmLoading
                                ? SizedBox(
                                    height: buttonSize + 4,
                                    width: buttonSize + 4,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                                    ),
                                  )
                                : Text(
                                    confirmText,
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
                              cancelText,
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
                              cancelText,
                              style: TextStyle(
                                fontSize: buttonSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Confirm Button
                        Expanded(
                          child: ElevatedButton(
                            onPressed: showConfirmLoading ? null : () {
                              Navigator.of(context).pop();
                              onConfirm();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: confirmButtonColor ?? AppColors.accentOrange,
                              foregroundColor: AppColors.textWhite,
                              padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                              elevation: 2,
                              shadowColor: (confirmButtonColor ?? AppColors.accentOrange).withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: showConfirmLoading
                                ? SizedBox(
                                    height: buttonSize + 4,
                                    width: buttonSize + 4,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                                    ),
                                  )
                                : Text(
                                    confirmText,
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