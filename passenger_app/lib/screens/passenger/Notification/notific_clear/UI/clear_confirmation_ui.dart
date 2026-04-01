import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../Logic/clear_confirmation_logic.dart';
import '../Data/clear_confirmation_data.dart';

void showClearConfirmationDialog(BuildContext context) {
  final data = ClearConfirmationData();

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      // Responsive calculations (matching ConfirmationDialog)
      final screenSize = MediaQuery.of(context).size;
      final screenWidth = screenSize.width;
      final dialogWidth = screenWidth < 400 ? screenWidth * 0.9 : 400.0;
      final padding = screenWidth < 400 ? 16.0 : (screenWidth < 600 ? 20.0 : 24.0);
      final iconSize = screenWidth < 400 ? 40.0 : 48.0;
      final titleSize = screenWidth < 400 ? 20.0 : 24.0;
      final bodySize = screenWidth < 400 ? 12.0 : 14.0;
      final buttonSize = screenWidth < 400 ? 14.0 : 16.0;

      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: Dialog(
              backgroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Matching ConfirmationDialog
              ),
              elevation: 8,
              child: Container(
                width: dialogWidth,
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon Header (matching ConfirmationDialog style)
                    Container(
                      padding: EdgeInsets.all(padding),
                      decoration: BoxDecoration(
                        color: AppColors.lightSeaGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: iconSize,
                        color: AppColors.lightSeaGreen,
                      ),
                    ),
                    SizedBox(height: padding),

                    // Title
                    Text(
                      'Clear All Notifications',
                      style: TextStyle(
                        color: AppColors.lightSeaGreen,
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: padding * 0.5),

                    // Message
                    Text(
                      'Are you sure you want to clear all notifications?',
                      style: TextStyle(
                        color: AppColors.lightSeaGreen.withOpacity(0.6),
                        fontSize: bodySize,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: padding * 1.3),

                    // Buttons (matching ConfirmationDialog layout)
                    Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(dialogContext),
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

                        // Confirm Button with loading
                        Expanded(
                          child: ElevatedButton(
                            onPressed: data.isLoading ? null : () async {
                              setState(() => data.isLoading = true);
                              await ClearConfirmationLogic.confirmClear(context, data);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: data.isLoading ? Colors.grey : Colors.red,
                              foregroundColor: AppColors.textWhite,
                              padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                              elevation: 2,
                              shadowColor: (data.isLoading ? Colors.grey : Colors.red).withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: data.isLoading
                                ? SizedBox(
                                    height: buttonSize + 4,
                                    width: buttonSize + 4,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                                    ),
                                  )
                                : Text(
                                    'Clear All',
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
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: child,
        ),
      );
    },
  );
}
