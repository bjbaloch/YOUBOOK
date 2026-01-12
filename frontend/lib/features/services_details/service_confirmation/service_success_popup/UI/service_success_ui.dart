import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';
import 'package:youbook/features/services_details/service_confirmation/service_success_popup/Data/service_success_data.dart';
import 'package:youbook/features/services_details/service_confirmation/service_success_popup/Logic/service_success_logic.dart';

/// UI File — Only contains layout + calls logic
void showServiceSuccessDialog(BuildContext parentContext) {
  final cs = Theme.of(parentContext).colorScheme;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!parentContext.mounted) return;

    showGeneralDialog(
      context: parentContext,
      barrierDismissible: false,
      barrierLabel: "Dismiss",
      barrierColor: Colors.black54,
      transitionDuration: ServiceSuccessData.transitionDuration,
      pageBuilder: (context, anim1, anim2) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: AlertDialog(
            backgroundColor: cs.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ServiceSuccessData.borderRadius,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: ServiceSuccessData.iconSize,
                  color: AppColors.successGreen,
                ),
                const SizedBox(height: ServiceSuccessData.spacing),
                const Text(
                  ServiceSuccessData.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        ServiceSuccessLogic.onOkPressed(context, parentContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
  });
}
