import 'package:youbook/features/support/feedback/feedback_popup/Data/feedback_popup_data.dart';
import 'package:youbook/features/support/feedback/feedback_popup/Logic/feedback_popup_logic.dart';
import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';
import 'package:youbook/features/support/feedback/feedback_popup/UI/feedback_success_popup.dart';

void showFeedbackPopup(BuildContext context) {
  final data = FeedbackData();
  final logic = FeedbackLogic();
  final cs = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  final TextEditingController controller = TextEditingController();
  String? errorText;
  bool isLoading = false;

  void setErrorText(String? value) {
    errorText = value;
  }

  void setLoading(bool value) {
    isLoading = value;
  }

  void showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const FeedbackSuccessPopup(),
    );
  }

  showGeneralDialog(
    context: context,
    barrierLabel: "Feedback",
    barrierDismissible: true,
    barrierColor: AppColors.textBlack54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeOutBack,
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: cs.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: const [
                  Icon(Icons.feedback, color: AppColors.accentOrange),
                  SizedBox(width: 8),
                  Text(
                    "Feedback",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      data.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    maxLines: 5,
                    maxLength: data.maxLength,
                    onChanged: (_) {
                      setState(() => errorText = null);
                    },
                    decoration: InputDecoration(
                      hintText: data.hintText,
                      hintStyle: const TextStyle(fontSize: 13),
                      counterText: "",
                      errorText: errorText,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppColors.accentOrange,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.grey),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${controller.text.length}/${data.maxLength}",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textBlack,
                      ),
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textBlack,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    logic.handleSubmit(
                                      context: context,
                                      controller: controller,
                                      setState: setState,
                                      showSuccessPopup: showSuccessPopup,
                                      setErrorText: setErrorText,
                                      setLoading: setLoading,
                                    );
                                  });
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.hintWhite,
                                  ),
                                )
                              : const Text("Submit"),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(opacity: anim1, child: child);
    },
  );
}
