import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';
import 'package:youbook/features/profile/change_phone_number/change_pn_page/Data/change_pn_data.dart';
import 'package:youbook/features/profile/change_phone_number/change_pn_page/Logic/change_pn_logic.dart';

class ChangePhoneDialogUI {
  static void show(BuildContext context) {
    final data = ChangePhoneData();
    final logic = ChangePhoneLogic(data: data);
    final TextEditingController phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (context, setState) {
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
                        const Icon(Icons.phone, color: AppColors.accentOrange),
                        const SizedBox(width: 8),
                        Text(
                          "Change Phone number",
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
                        "Enter new phone number",
                        style: TextStyle(fontSize: 14, color: cs.onSurface),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      onChanged: (val) =>
                          logic.validatePhone(val, () => setState(() {})),
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textBlack,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        labelText: "Phone number",
                        labelStyle: TextStyle(
                          color: isDark
                              ? AppColors.textWhite
                              : AppColors.textBlack,
                        ),
                        errorText: data.phoneError,
                        errorStyle: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
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
                          onPressed: data.isLoading
                              ? null
                              : () =>
                                    logic.onVerify(ctx, () => setState(() {})),
                          child: data.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
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
