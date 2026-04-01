import 'package:flutter/material.dart';
import 'package:youbook/core/theme/app_colors.dart';
import 'package:youbook/features/profile/account/account_page/UI/account_page_ui.dart';
import 'package:youbook/features/profile/change_password/change_password_page/Data/change_pass_data.dart';
import 'package:youbook/features/profile/change_password/change_password_page/Logic/change_pass_logic.dart';
import 'package:youbook/features/profile/change_password/success_password/UI/success_pass_ui.dart';

class ChangePasswordPageUI extends StatefulWidget {
  const ChangePasswordPageUI({super.key});

  @override
  State<ChangePasswordPageUI> createState() => _ChangePasswordPageUIState();
}

class _ChangePasswordPageUIState extends State<ChangePasswordPageUI> {
  late final ChangePasswordData _data;
  late final ChangePasswordLogic _logic;

  @override
  void initState() {
    super.initState();
    _data = ChangePasswordData(
      oldPasswordCtrl: TextEditingController(),
      newPasswordCtrl: TextEditingController(),
      confirmPasswordCtrl: TextEditingController(),
    );
    _logic = ChangePasswordLogic(data: _data);
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: cs.primary,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 45,
        title: Text(
          "Change Password",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: cs.onPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: cs.onPrimary,
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AccountPageUI()),
            );
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Please enter your new password and confirm it to update your account.",
              style: TextStyle(fontSize: 14, color: cs.onBackground),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lock,
                    size: 100,
                    color: cs.onPrimary,
                  ),
                  const SizedBox(height: 20),

                  // Old password
                  _buildPasswordField(
                    controller: _data.oldPasswordCtrl,
                    label: "Old Password",
                    obscure: _data.obscureOld,
                    onToggle: () =>
                        setState(() => _data.obscureOld = !_data.obscureOld),
                    errorText: _data.oldPassError,
                    onChanged: (_) =>
                        _logic.validateFields(() => setState(() {})),
                  ),
                  const SizedBox(height: 12),

                  // New password
                  _buildPasswordField(
                    controller: _data.newPasswordCtrl,
                    label: "New Password",
                    obscure: _data.obscureNew,
                    onToggle: () =>
                        setState(() => _data.obscureNew = !_data.obscureNew),
                    errorText: _data.newPassError,
                    onTap: () => setState(() => _data.touchedNew = true),
                    onChanged: (_) =>
                        _logic.validateFields(() => setState(() {})),
                  ),
                  const SizedBox(height: 12),

                  // Confirm password
                  _buildPasswordField(
                    controller: _data.confirmPasswordCtrl,
                    label: "Confirm Password",
                    obscure: _data.obscureConfirm,
                    onToggle: () => setState(
                      () => _data.obscureConfirm = !_data.obscureConfirm,
                    ),
                    errorText: _data.confirmPassError,
                    onTap: () => setState(() => _data.touchedConfirm = true),
                    onChanged: (_) =>
                        _logic.validateFields(() => setState(() {})),
                  ),
                  const SizedBox(height: 24),

                  // Update button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentOrange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _data.isLoading
                          ? null
                          : () => _logic.updatePassword(
                              context,
                              () => setState(() {}),
                              () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => SuccessPopupUI(
                                    onContinue: () {
                                      Navigator.of(context).pop(); // Close dialog
                                      Navigator.of(context).pop(); // Go back to account page
                                    },
                                  ),
                                );
                              },
                            ),
                      child: _data.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.hintWhite,
                              ),
                            )
                          : const Text(
                              "Update",
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Password Field Builder ----
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? errorText,
    void Function(String)? onChanged,
    VoidCallback? onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isError = errorText != null && errorText.isNotEmpty;

    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      onTap: onTap,
      style: TextStyle(color: cs.onSurface),
      cursorColor: AppColors.accentOrange,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isError ? Colors.red : cs.onSurface.withOpacity(0.7),
        ),
        filled: true,
        fillColor: cs.background,
        errorText: errorText,
        errorStyle: const TextStyle(fontSize: 12, color: Colors.redAccent),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isError ? Colors.redAccent : cs.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isError ? Colors.redAccent : AppColors.accentOrange,
            width: 2,
          ),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: cs.onSurface,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
