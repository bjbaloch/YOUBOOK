import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';
import 'package:youbook/features/profile/change_email/change_email_page/Logic/change_email_logic.dart';
import 'package:youbook/features/profile/change_email/email_otp/UI/email_otp_ui.dart';

class ChangeEmailDialogUI {
  static void show(BuildContext context) {
    final _logic = ChangeEmailLogic();
    final TextEditingController _ctrl = TextEditingController();
    bool _isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setState) {
            void _onEmailChanged(String value) {
              _logic.validateEmail(value);
              setState(() {});
            }

            return Dialog(
              backgroundColor: cs.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          color: AppColors.accentOrange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Change email address",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.textBlack,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Enter new email address",
                        style: TextStyle(fontSize: 14, color: cs.onSurface),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _ctrl,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: _onEmailChanged,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textBlack,
                      ),
                      decoration: InputDecoration(
                        labelText: "Email",
                        errorText: _logic.data.error,
                        errorStyle: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                        labelStyle: TextStyle(
                          color: isDark
                              ? AppColors.textWhite
                              : AppColors.textBlack,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.accentOrange,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(100, 40),
                            side: const BorderSide(
                              color: AppColors.accentOrange,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.textBlack,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                            foregroundColor: AppColors.textWhite,
                            minimumSize: const Size(100, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: (_isLoading || !_logic.isValid)
                              ? null
                              : () {
                                  _logic.validateEmail(_ctrl.text);
                                  if (!_logic.isValid) return;

                                  setState(() => _isLoading = true);

                                  Future.delayed(
                                    const Duration(seconds: 2),
                                    () {
                                      if (!context.mounted) return;
                                      Navigator.pop(ctx);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const EmailOtpPageUI(),
                                        ),
                                      );
                                    },
                                  );
                                },
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.hintWhite,
                                  ),
                                )
                              : const Text("Verify"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
