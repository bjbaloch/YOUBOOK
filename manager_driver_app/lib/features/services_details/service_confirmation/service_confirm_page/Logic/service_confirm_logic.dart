import 'package:flutter/material.dart';
import 'package:manager_driver_app/core/theme/app_colors.dart';
import 'package:manager_driver_app/features/services_details/service_confirmation/service_confirm_page/Data/service_confirm_data.dart';
import 'package:manager_driver_app/features/services_details/service_confirmation/service_success_popup/UI/service_success_ui.dart';

class ServiceConfirmationLogic {
  /// Handles confirm button logic (loading + closing + showing success)
  static Future<void> onConfirmPressed({
    required VoidCallback setLoading,
    required BuildContext parentContext,
    Map<String, dynamic>? formData,
  }) async {
    setLoading();

    // TODO: Restore API calls (createService, createRoute) when connecting backend
    await Future.delayed(ServiceConfirmationData.loadingDelay);

    Navigator.of(parentContext, rootNavigator: true).pop();

    Future.delayed(
      ServiceConfirmationData.successPopupDelay,
      () => showServiceSuccessDialog(parentContext),
    );
  }

  /// Builds dialog actions (Cancel, Confirm)
  static List<Widget> buildActions({
    required BuildContext dialogContext,
    required BuildContext parentContext,
    required ColorScheme cs,
    required bool isLoading,
    required Function(bool) setState,
    Map<String, dynamic>? formData,
  }) {
    return [
      // Cancel
      OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.onSurface,
          side: const BorderSide(color: AppColors.accentOrange),
          shape: const StadiumBorder(),
        ),
        onPressed: () => Navigator.pop(dialogContext),
        child: const Text("Cancel"),
      ),

      // Confirm with loader
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentOrange,
          shape: const StadiumBorder(),
        ),
        onPressed: isLoading
            ? null
            : () {
                ServiceConfirmationLogic.onConfirmPressed(
                  parentContext: parentContext,
                  setLoading: () => setState(true),
                  formData: formData,
                );
              },
        child: isLoading
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text("Confirm", style: TextStyle(color: Colors.white)),
      ),
    ];
  }
}
