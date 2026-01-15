import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';
import 'package:youbook/features/services_details/service_confirmation/service_confirm_page/Data/service_confirm_data.dart';
import 'package:youbook/features/services_details/service_confirmation/service_success_popup/UI/service_success_ui.dart';
import 'package:youbook/core/services/api_service.dart';

class ServiceConfirmationLogic {
  /// Handles confirm button logic (loading + closing + showing success)
  static Future<void> onConfirmPressed({
    required VoidCallback setLoading,
    required BuildContext parentContext,
    Map<String, dynamic>? formData,
  }) async {
    setLoading();

    try {
      // If we have form data, save it to database
      if (formData != null) {
        final apiService = ApiService();
        await apiService.createService(formData);
      }

      await Future.delayed(ServiceConfirmationData.loadingDelay);

      // Close confirmation dialog
      Navigator.of(parentContext, rootNavigator: true).pop();

      // Show success popup
      Future.delayed(
        ServiceConfirmationData.successPopupDelay,
        () => showServiceSuccessDialog(parentContext),
      );
    } catch (e) {
      // Close confirmation dialog
      Navigator.of(parentContext, rootNavigator: true).pop();

      // Show error message
      Future.delayed(
        ServiceConfirmationData.successPopupDelay,
        () {
          ScaffoldMessenger.of(parentContext).showSnackBar(
            SnackBar(
              content: Text('Failed to save service: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    }
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
            : const Text(
                "Confirm",
                style: TextStyle(color: Colors.white),
              ),
      ),
    ];
  }
}
