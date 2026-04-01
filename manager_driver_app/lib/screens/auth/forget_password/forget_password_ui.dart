part of forget_password_popup;

Widget _buildForgetPasswordUI(
  _ForgetPasswordPopupState state,
  ForgetPasswordPopup widget,
) {
  final bool lockEmailField = !state._hasInitialEmail;
  final String emailTrim = state._emailController.text.trim();
  final bool disableGetButton =
      state._isSending ||
      state._cooldown > 0 ||
      emailTrim.isEmpty ||
      !emailRegex.hasMatch(emailTrim);

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
                          'Forgot Password',
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
                          Icons.lock_open_rounded,
                          size: 40,
                          color: AppColors.lightSeaGreen,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        'Enter your email to receive a\nverification code',
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
                          // Email label
                          const _FpLabel(text: 'Email address'),
                          const SizedBox(height: 8),

                          // Email + Get button row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _fpField(
                                  controller: state._emailController,
                                  hint: lockEmailField
                                      ? 'Enter email on Login page'
                                      : 'you@example.com',
                                  icon: Icons.email_outlined,
                                  readOnly: lockEmailField,
                                  onTap: lockEmailField
                                      ? () => FocusScope.of(state.context)
                                          .unfocus()
                                      : null,
                                  keyboardType: TextInputType.emailAddress,
                                  hasError: state._emailError != null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: disableGetButton
                                      ? null
                                      : state._sendResetCode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentOrange,
                                    disabledBackgroundColor:
                                        AppColors.accentOrange.withOpacity(0.4),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                  ),
                                  child: state._isSending
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          state._cooldown > 0
                                              ? '${state._cooldown}s'
                                              : 'Get',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),

                          if (state._emailError != null) ...[
                            const SizedBox(height: 6),
                            _FpErrorText(text: state._emailError!),
                          ],
                          if (state._successMessage != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 14,
                                  color: AppColors.successGreen,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    state._successMessage!,
                                    style: const TextStyle(
                                      color: AppColors.successGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Code label
                          const _FpLabel(text: 'Verification code'),
                          const SizedBox(height: 8),
                          _fpField(
                            controller: state._codeController,
                            hint: 'Enter 6-digit code',
                            icon: Icons.pin_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            hasError: state._codeError != null,
                          ),
                          if (state._codeError != null) ...[
                            const SizedBox(height: 6),
                            _FpErrorText(text: state._codeError!),
                          ],

                          const SizedBox(height: 28),

                          // Continue button
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  state._isVerifying ? null : state._continue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightSeaGreen,
                                disabledBackgroundColor:
                                    AppColors.lightSeaGreen.withOpacity(0.5),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: state._isVerifying
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Continue',
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

class _FpLabel extends StatelessWidget {
  final String text;
  const _FpLabel({required this.text});
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

class _FpErrorText extends StatelessWidget {
  final String text;
  const _FpErrorText({required this.text});
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
