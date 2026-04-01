part of reset_password_popup;

class ResetPasswordPopup extends StatefulWidget {
  const ResetPasswordPopup({super.key});

  @override
  State<ResetPasswordPopup> createState() => _ResetPasswordPopupState();
}

Widget _buildResetPasswordUI(_ResetPasswordPopupState state) {
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

  return WillPopScope(
    // Block system back; do not navigate back to Forget Password
    onWillPop: () async => false,
    child: Dialog(
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
                    Icons.lock_reset_rounded,
                    size: iconSize,
                    color: AppColors.lightSeaGreen,
                  ),
                ),
                SizedBox(height: padding),

                // Title
                Text(
                  'Reset Password',
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
                  'Enter your new password below.',
                  style: TextStyle(
                    color: AppColors.lightSeaGreen.withOpacity(0.8),
                    fontSize: subtitleSize,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: padding),

                const Text("New password"),
                const SizedBox(height: 5),
                TextField(
                  controller: state._newPasswordController,
                  obscureText: state._obscureNew,
                  onChanged: state._validatePassword,
                  textInputAction: TextInputAction.next,
                  autocorrect: true,
                  cursorColor: cs.secondary,
                  cursorWidth: 2,
                  cursorRadius: const Radius.circular(2),
                  style: TextStyle(color: AppColors.textBlack),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppColors.lightSeaGreen,
                    ),
                    hintText: "New password",
                    labelText: "New password",
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
                    suffixIcon: IconButton(
                      icon: Icon(
                        state._obscureNew
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.lightSeaGreen,
                      ),
                      onPressed: () =>
                          state.setState(() => state._obscureNew = !state._obscureNew),
                    ),
                  ),
                ),
                if (state._newPasswordError != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    state._newPasswordError!,
                    style: TextStyle(color: cs.error, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 10),
                const Text("Confirm new password"),
                const SizedBox(height: 5),
                TextField(
                  controller: state._confirmPasswordController,
                  obscureText: state._obscureConfirm,
                  onChanged: state._validateConfirmPassword,
                  textInputAction: TextInputAction.done,
                  autocorrect: true,
                  cursorColor: cs.secondary,
                  cursorWidth: 2,
                  cursorRadius: const Radius.circular(2),
                  style: TextStyle(color: AppColors.textBlack),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: AppColors.lightSeaGreen,
                    ),
                    hintText: "Confirm new password",
                    labelText: "Confirm new password",
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
                    suffixIcon: IconButton(
                      icon: Icon(
                        state._obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.lightSeaGreen,
                      ),
                      onPressed: () => state.setState(
                        () => state._obscureConfirm = !state._obscureConfirm,
                      ),
                    ),
                  ),
                ),
                if (state._confirmPasswordError != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    state._confirmPasswordError!,
                    style: TextStyle(color: cs.error, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 12),

                // Rules
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      state._rule("At least one lowercase letter", state.hasLower),
                      state._rule("At least one uppercase letter", state.hasUpper),
                      state._rule("At least one number", state.hasNumber),
                      state._rule("At least one special character", state.hasSpecial),
                      state._rule("Minimum 8 characters", state.hasMinLength),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: state._loading ? null : state._resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: state._loading
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.lightSeaGreen,
                            ),
                          )
                        : Text(
                            "Change Password",
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(
                                state.context,
                              ).colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// Professional dialog helper (matching logout popup style)
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
    pageBuilder: (context, anim1, anim2) =>
        SafeArea(child: Center(child: child)),
    transitionBuilder: (context, anim, secondary, widget) {
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
        child: FadeTransition(opacity: fadeAnimation, child: widget),
      );
    },
  );
}

// Helper to open ResetPasswordPopup (non-dismissible and keyboard/overlay safe) with smooth transition
Future<void> showResetPasswordPopup(BuildContext context) {
  return _showSmoothDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.overlay,
    child: const ResetPasswordPopup(),
  );
}
