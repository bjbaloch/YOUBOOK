part of forget_password_popup;

class ForgetPasswordPopup extends StatefulWidget {
  const ForgetPasswordPopup({
    super.key,
    this.initialEmail, // Pass the login email to prefill
  });

  final String? initialEmail;

  @override
  State<ForgetPasswordPopup> createState() => _ForgetPasswordPopupState();

  /// Professional helper with logout-style animations
  static Future<void> show(BuildContext context, {String? initialEmail}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: AppColors.overlay,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) =>
          ForgetPasswordPopup(initialEmail: initialEmail),
      transitionBuilder: (_, anim, __, child) {
        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.elasticOut));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut));

        return ScaleTransition(
          scale: scaleAnimation,
          child: FadeTransition(opacity: fadeAnimation, child: child),
        );
      },
    );
  }
}

Widget _buildForgetPasswordUI(_ForgetPasswordPopupState state, ForgetPasswordPopup widget) {
  final bool lockEmailField = !state._hasInitialEmail;
  final String emailTrim = state._emailController.text.trim();
  final bool disableGetButton =
      state._isSending ||
      state._cooldown > 0 ||
      emailTrim.isEmpty ||
      !emailRegex.hasMatch(emailTrim);

  final cs = Theme.of(state.context).colorScheme;

  // Responsive calculations
  final screenSize = MediaQuery.of(state.context).size;
  final screenWidth = screenSize.width;
  final screenHeight = screenSize.height;

  // Adaptive dialog width: 90% of screen width, max 500px (more content)
  final dialogWidth = screenWidth < 400 ? screenWidth * 0.9 : (screenWidth < 600 ? screenWidth * 0.95 : 500.0);

  // Adaptive padding: scales from 16px (small) to 24px (large)
  final padding = screenWidth < 400 ? 16.0 : (screenWidth < 600 ? 20.0 : 24.0);

  // Adaptive icon size: scales with screen size
  final iconSize = screenWidth < 400 ? 40.0 : 48.0;

  // Adaptive text sizes
  final titleSize = screenWidth < 400 ? 20.0 : 24.0;
  final subtitleSize = screenWidth < 400 ? 14.0 : 16.0;
  final bodySize = screenWidth < 400 ? 12.0 : 14.0;
  final buttonSize = screenWidth < 400 ? 14.0 : 16.0;

  // Check if buttons should be stacked (small screens)
  final stackButtons = screenWidth < 400;

  return Dialog(
    backgroundColor: AppColors.background,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 8,
    child: Container(
      width: dialogWidth,
      constraints: BoxConstraints(
        maxWidth: dialogWidth,
        maxHeight: screenHeight * 0.9, // Allow more height for content
      ),
      child: Form(
        key: state._formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header
              Container(
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(
                  color: AppColors.lightSeaGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.email_rounded,
                  size: iconSize,
                  color: AppColors.lightSeaGreen,
                ),
              ),
              SizedBox(height: padding),

              // Title
              Text(
                'Forgot Password',
                style: TextStyle(
                  color: AppColors.lightSeaGreen,
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: padding * 0.5),

              // Subtitle
              Text(
                'Enter your email to reset your password.',
                style: TextStyle(
                  color: AppColors.lightSeaGreen.withOpacity(0.8),
                  fontSize: subtitleSize,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: padding),

              const Text("Email address"),
              const SizedBox(height: 5),
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextField(
                    controller: state._emailController,
                    readOnly: lockEmailField,
                    enableInteractiveSelection: !lockEmailField,
                    onTap: lockEmailField
                        ? () => FocusScope.of(state.context).unfocus()
                        : null,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: cs.secondary,
                    cursorWidth: 2,
                    cursorRadius: const Radius.circular(2),
                    style: TextStyle(color: AppColors.textBlack),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColors.lightSeaGreen,
                      ),
                      hintText: lockEmailField
                          ? "Enter email on Login page"
                          : "Email address",
                      labelText: "Email address",
                      labelStyle: TextStyle(
                        color: AppColors.lightSeaGreen.withOpacity(0.4),
                      ),
                      floatingLabelStyle: TextStyle(
                        color: AppColors.textBlack,
                        fontWeight: FontWeight.w600,
                      ),
                      hintStyle: TextStyle(
                        color: AppColors.textBlack.withOpacity(0.4),
                      ),
                      filled: true,
                      fillColor: AppColors.transparent,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: AppColors.accentOrange,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: AppColors.accentOrange,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: cs.secondary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 80,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: disableGetButton
                            ? null
                            : state._sendResetCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: state._isSending
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.lightSeaGreen,
                                ),
                              )
                            : Text(
                                state._cooldown > 0
                                    ? "Resend ${state._cooldown}s"
                                    : "Get",
                                style: TextStyle(
                                  color: Theme.of(
                                    state.context,
                                  ).colorScheme.onPrimary,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              if (state._emailError != null)
                Text(
                  state._emailError!,
                  style: TextStyle(color: cs.error, fontSize: 12),
                ),
              if (state._successMessage != null)
                Text(
                  state._successMessage!,
                  style: TextStyle(
                    color: AppColors.successGreen,
                    fontSize: 12,
                  ),
                ),

              const SizedBox(height: 10),
              const Text("Enter the code that was sent to your email"),
              const SizedBox(height: 5),
              TextField(
                controller: state._codeController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                cursorColor: cs.secondary,
                cursorWidth: 2,
                cursorRadius: const Radius.circular(2),
                style: TextStyle(color: AppColors.textBlack),
                decoration: InputDecoration(
                  labelText: "Enter the code",
                  hintText: "Enter the code",
                  labelStyle: TextStyle(
                    color: AppColors.lightSeaGreen.withOpacity(0.4),
                  ),
                  floatingLabelStyle: TextStyle(
                    color: AppColors.textBlack,
                    fontWeight: FontWeight.w600,
                  ),
                  hintStyle: TextStyle(
                    color: AppColors.textBlack.withOpacity(0.4),
                  ),
                  filled: true,
                  fillColor: AppColors.transparent,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: AppColors.accentOrange,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: AppColors.accentOrange,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: cs.secondary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              if (state._codeError != null)
                Text(
                  state._codeError!,
                  style: TextStyle(color: cs.error, fontSize: 12),
                ),

              SizedBox(height: padding),

              // Buttons - responsive layout
              if (stackButtons)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Continue Button (primary action first on mobile)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state._isVerifying ? null : state._continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: state._isVerifying
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.lightSeaGreen,
                                ),
                              )
                            : Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: buttonSize,
                                  color: Theme.of(state.context).colorScheme.onPrimary,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(state.context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.accentOrange, width: 2),
                          padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: buttonSize,
                            color: Theme.of(state.context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: screenWidth < 600 ? 120 : 150,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(state.context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.accentOrange),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: buttonSize,
                            color: Theme.of(state.context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: screenWidth < 600 ? 120 : 150,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: state._isVerifying ? null : state._continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: state._isVerifying
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.lightSeaGreen,
                                ),
                              )
                            : Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: buttonSize,
                                  color: Theme.of(state.context).colorScheme.onPrimary,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
