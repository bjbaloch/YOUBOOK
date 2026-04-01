part of reset_password_popup;

Widget _buildResetPasswordUI(_ResetPasswordPopupState state) {
  final size = MediaQuery.of(state.context).size;

  return Scaffold(
    backgroundColor: AppColors.lightSeaGreen,
    body: Stack(
      children: [
        // Decorative circles
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentOrange.withOpacity(0.07),
            ),
          ),
        ),

        SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: state._formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Back button + title
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(state.context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.background.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.background.withOpacity(0.2),
                              ),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Reset Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.04),

                    // Icon
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          size: 40,
                          color: AppColors.lightSeaGreen,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        'Create a strong new password\nfor your account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.04),

                    // Card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // New password
                          const _RpLabel(text: 'New password'),
                          const SizedBox(height: 8),
                          StatefulBuilder(
                            builder: (_, setLocal) => _fpField(
                              controller: state._newPasswordController,
                              hint: 'Enter new password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: state._obscureNew,
                              onChanged: state._validatePassword,
                              hasError: state._newPasswordError != null,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  state._obscureNew
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.hintGrey,
                                  size: 20,
                                ),
                                onPressed: () => state.setState(
                                  () => state._obscureNew = !state._obscureNew,
                                ),
                              ),
                            ),
                          ),
                          if (state._newPasswordError != null) ...[
                            const SizedBox(height: 6),
                            _RpErrorText(text: state._newPasswordError!),
                          ],

                          const SizedBox(height: 16),

                          // Confirm password
                          const _RpLabel(text: 'Confirm new password'),
                          const SizedBox(height: 8),
                          StatefulBuilder(
                            builder: (_, setLocal) => _fpField(
                              controller: state._confirmPasswordController,
                              hint: 'Re-enter new password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: state._obscureConfirm,
                              onChanged: state._validateConfirmPassword,
                              hasError: state._confirmPasswordError != null,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  state._obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.hintGrey,
                                  size: 20,
                                ),
                                onPressed: () => state.setState(
                                  () => state._obscureConfirm =
                                      !state._obscureConfirm,
                                ),
                              ),
                            ),
                          ),
                          if (state._confirmPasswordError != null) ...[
                            const SizedBox(height: 6),
                            _RpErrorText(text: state._confirmPasswordError!),
                          ],

                          const SizedBox(height: 20),

                          // Password rules
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.lightSeaGreen.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.lightSeaGreen.withOpacity(0.15),
                              ),
                            ),
                            child: Column(
                              children: [
                                state._rule('At least one lowercase letter',
                                    state.hasLower),
                                const SizedBox(height: 6),
                                state._rule('At least one uppercase letter',
                                    state.hasUpper),
                                const SizedBox(height: 6),
                                state._rule(
                                    'At least one number', state.hasNumber),
                                const SizedBox(height: 6),
                                state._rule('At least one special character',
                                    state.hasSpecial),
                                const SizedBox(height: 6),
                                state._rule(
                                    'Minimum 8 characters', state.hasMinLength),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Change Password button
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  state._loading ? null : state._resetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightSeaGreen,
                                disabledBackgroundColor:
                                    AppColors.lightSeaGreen.withOpacity(0.5),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: state._loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Change Password',
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

                    SizedBox(height: size.height * 0.04),

                    Center(
                      child: Text(
                        'YouBook.com — Multi-Service Booking Platform',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _RpLabel extends StatelessWidget {
  final String text;
  const _RpLabel({required this.text});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.lightSeaGreen,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _RpErrorText extends StatelessWidget {
  final String text;
  const _RpErrorText({required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline, size: 13, color: AppColors.red),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

Widget _fpField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  bool readOnly = false,
  VoidCallback? onTap,
  ValueChanged<String>? onChanged,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  bool hasError = false,
  bool obscureText = false,
  Widget? suffixIcon,
}) {
  final borderColor =
      hasError ? AppColors.red : AppColors.lightSeaGreen.withOpacity(0.3);
  final focusedColor = hasError ? AppColors.red : AppColors.lightSeaGreen;

  return TextField(
    controller: controller,
    readOnly: readOnly,
    onTap: onTap,
    onChanged: onChanged,
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    obscureText: obscureText,
    cursorColor: AppColors.lightSeaGreen,
    cursorWidth: 2,
    style: const TextStyle(
      color: AppColors.textBlack,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.hintGrey, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.lightSeaGreen, size: 19),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.background,
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: focusedColor, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.red, width: 1.8),
      ),
    ),
  );
}

// kept for compatibility — no longer used as a dialog
Future<T?> _showSmoothDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = false,
  Color barrierColor = AppColors.overlay,
  Duration duration = const Duration(milliseconds: 300),
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor,
    transitionDuration: duration,
    pageBuilder: (_, __, ___) => SafeArea(child: Center(child: child)),
    transitionBuilder: (_, anim, __, widget) {
      final scale = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
      );
      final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: anim, curve: Curves.easeOut),
      );
      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(scale: scale, child: widget),
      );
    },
  );
}
