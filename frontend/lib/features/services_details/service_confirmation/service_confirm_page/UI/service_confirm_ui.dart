import 'package:flutter/material.dart';
import 'package:youbook/features/services_details/service_confirmation/service_confirm_page/Data/service_confirm_data.dart';
import 'package:youbook/features/services_details/service_confirmation/service_confirm_page/Logic/service_confirm_logic.dart';

/// UI File — Only UI + calling logic
void showServiceConfirmationDialog(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  final parentContext = context;

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: ServiceConfirmationData.transitionDuration,
    pageBuilder: (context, anim1, anim2) {
      bool isLoading = false;

      return StatefulBuilder(
        builder: (dialogContext, setState) {
          return ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: AlertDialog(
              backgroundColor: cs.surface,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(ServiceConfirmationData.borderRadius),
              ),
              title: const Text(
                ServiceConfirmationData.title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text(
                ServiceConfirmationData.message,
                style: TextStyle(fontSize: 14),
              ),
              actions: ServiceConfirmationLogic.buildActions(
                dialogContext: dialogContext,
                parentContext: parentContext,
                cs: cs,
                isLoading: isLoading,
                setState: (value) => setState(() => isLoading = value),
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
