import 'package:flutter/material.dart';
import 'package:manager_driver_app/core/theme/app_colors.dart';
import 'package:manager_driver_app/core/widgets/success_dialog.dart';
import 'package:manager_driver_app/features/profile/change_password/change_password_page/Data/change_pass_data.dart';
import 'package:manager_driver_app/features/profile/change_password/change_password_page/Logic/change_pass_logic.dart';

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

  void _onUpdate() {
    _logic.updatePassword(
      context,
      () => setState(() {}),
      () => SuccessDialog.show(
        context,
        title: 'Password Updated!',
        message:
            'Your password has been changed successfully. Use your new password next time you sign in.',
        icon: Icons.lock_open_rounded,
        buttonLabel: 'Done',
        onDone: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppBar(
        backgroundColor: AppColors.lightSeaGreen,
        elevation: 0,
        toolbarHeight: 56,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.lightSeaGreen, AppColors.accentOrange],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: Column(
          children: [
            // ── Info banner ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.lightSeaGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.lightSeaGreen.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightSeaGreen.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.lightSeaGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Choose a strong password with at least 8 characters, including uppercase, lowercase, number and special character.',
                      style: TextStyle(
                        color: AppColors.lightSeaGreen.withOpacity(0.85),
                        fontSize: 12.5,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Fields card ───────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _fieldLabel('Current Password'),
                  const SizedBox(height: 8),
                  _buildField(
                    controller: _data.oldPasswordCtrl,
                    hint: 'Enter current password',
                    obscure: _data.obscureOld,
                    onToggle: () =>
                        setState(() => _data.obscureOld = !_data.obscureOld),
                    errorText: _data.oldPassError,
                    onChanged: (_) =>
                        _logic.validateFields(() => setState(() {})),
                  ),

                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.withOpacity(0.12), height: 1),
                  const SizedBox(height: 20),

                  _fieldLabel('New Password'),
                  const SizedBox(height: 8),
                  _buildField(
                    controller: _data.newPasswordCtrl,
                    hint: 'Enter new password',
                    obscure: _data.obscureNew,
                    onToggle: () =>
                        setState(() => _data.obscureNew = !_data.obscureNew),
                    errorText: _data.newPassError,
                    onTap: () => setState(() => _data.touchedNew = true),
                    onChanged: (_) =>
                        _logic.validateFields(() => setState(() {})),
                  ),

                  // Strength indicators
                  if (_data.touchedNew &&
                      _data.newPasswordCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildStrengthRow(_data.newPasswordCtrl.text),
                  ],

                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.withOpacity(0.12), height: 1),
                  const SizedBox(height: 20),

                  _fieldLabel('Confirm New Password'),
                  const SizedBox(height: 8),
                  _buildField(
                    controller: _data.confirmPasswordCtrl,
                    hint: 'Re-enter new password',
                    obscure: _data.obscureConfirm,
                    onToggle: () => setState(
                        () => _data.obscureConfirm = !_data.obscureConfirm),
                    errorText: _data.confirmPassError,
                    onTap: () => setState(() => _data.touchedConfirm = true),
                    onChanged: (_) =>
                        _logic.validateFields(() => setState(() {})),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Update button ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _data.isLoading ? null : _onUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightSeaGreen,
                  disabledBackgroundColor:
                      AppColors.lightSeaGreen.withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _data.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Update Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black.withOpacity(0.6),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? errorText,
    void Function(String)? onChanged,
    VoidCallback? onTap,
  }) {
    final isError = errorText != null && errorText.isNotEmpty;
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      onTap: onTap,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.withOpacity(0.5),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: isError
              ? AppColors.error
              : AppColors.lightSeaGreen.withOpacity(0.7),
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey.withOpacity(0.6),
            size: 20,
          ),
          onPressed: onToggle,
        ),
        errorText: errorText,
        errorStyle: const TextStyle(fontSize: 11.5, color: AppColors.error),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.05),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isError
                ? AppColors.error
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isError ? AppColors.error : AppColors.lightSeaGreen,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildStrengthRow(String pass) {
    final rules = [
      _Rule('8+ characters', pass.length >= 8),
      _Rule('Uppercase', RegExp(r'[A-Z]').hasMatch(pass)),
      _Rule('Lowercase', RegExp(r'[a-z]').hasMatch(pass)),
      _Rule('Number', RegExp(r'[0-9]').hasMatch(pass)),
      _Rule('Special char', RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(pass)),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: rules
          .map((r) => _RuleChip(label: r.label, met: r.met))
          .toList(),
    );
  }
}

class _Rule {
  final String label;
  final bool met;
  const _Rule(this.label, this.met);
}

class _RuleChip extends StatelessWidget {
  final String label;
  final bool met;
  const _RuleChip({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: met
            ? AppColors.lightSeaGreen.withOpacity(0.1)
            : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: met
              ? AppColors.lightSeaGreen.withOpacity(0.4)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 13,
            color: met ? AppColors.lightSeaGreen : Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: met
                  ? AppColors.lightSeaGreen
                  : Colors.grey.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
