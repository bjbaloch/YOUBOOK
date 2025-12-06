import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youbook/core/theme/app_colors.dart';
import 'package:youbook/screens/auth/password_success_popup.dart';

class ResetPasswordPopup extends StatefulWidget {
  const ResetPasswordPopup({super.key});

  @override
  State<ResetPasswordPopup> createState() => _ResetPasswordPopupState();
}

class _ResetPasswordPopupState extends State<ResetPasswordPopup> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;

  // validation flags
  bool hasLower = false;
  bool hasUpper = false;
  bool hasNumber = false;
  bool hasSpecial = false;
  bool hasMinLength = false;

  String? _newPasswordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword(String value) {
    setState(() {
      hasLower = RegExp(r'[a-z]').hasMatch(value);
      hasUpper = RegExp(r'[A-Z]').hasMatch(value);
      hasNumber = RegExp(r'[0-9]').hasMatch(value);
      hasSpecial = RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(value);
      hasMinLength = value.length >= 8;

      // Clear error when user starts typing
      if (_newPasswordError != null && value.isNotEmpty) {
        _newPasswordError = null;
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      // Clear error when user starts typing
      if (_confirmPasswordError != null && value.isNotEmpty) {
        _confirmPasswordError = null;
      }
    });
  }

  bool _isNetworkError(dynamic e) {
    if (e is SocketException) return true;
    final msg = e.toString().toLowerCase();
    return msg.contains('network') ||
        msg.contains('host lookup') ||
        msg.contains('failed host lookup') ||
        msg.contains('socket') ||
        msg.contains('timed out') ||
        msg.contains('xmlhttprequest') ||
        msg.contains('failed to fetch');
  }

  Future<void> _resetPassword() async {
    setState(() {
      _newPasswordError = null;
      _confirmPasswordError = null;
    });

    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validate new password is not empty
    if (newPassword.isEmpty) {
      setState(() {
        _newPasswordError = "Enter the password";
      });
      return;
    }

    // Validate confirm password is not empty
    if (confirmPassword.isEmpty) {
      setState(() {
        _confirmPasswordError = "Confirm the password";
      });
      return;
    }

    // Validate passwords match
    if (newPassword != confirmPassword) {
      setState(() {
        _confirmPasswordError = "The confirm password not match";
      });
      return;
    }

    // Validate password strength
    if (!(hasLower && hasUpper && hasNumber && hasSpecial && hasMinLength)) {
      setState(() {
        _newPasswordError = "Password does not meet requirements";
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      // Latest supabase_flutter: updateUser with UserAttributes
      final resp = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (resp.user != null) {
        if (!mounted) return;

        // Close this ResetPasswordPopup BEFORE opening SuccessPopup
        Navigator.of(context).pop();
        // Give the Navigator a tick to remove this dialog before showing the next
        await Future.delayed(const Duration(milliseconds: 100));

        // Smooth navigation to success popup
        await _showSmoothDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: AppColors.overlay,
          child: const SuccessPopup(),
        );
      } else {
        setState(
          () => _newPasswordError = "Password reset failed. Please try again.",
        );
      }
    } on AuthException catch (e) {
      if (_isNetworkError(e)) {
        setState(
          () => _newPasswordError =
              "No internet connection. Please check your network.",
        );
      } else {
        // Common: session expired if user waited too long after OTP verify
        final msg = e.message.toLowerCase();
        if (msg.contains('session') ||
            msg.contains('expired') ||
            msg.contains('token')) {
          setState(
            () => _newPasswordError =
                "Your session expired. Request a new code and try again.",
          );
        } else {
          setState(() => _newPasswordError = e.message);
        }
      }
    } on SocketException {
      setState(
        () => _newPasswordError =
            "No internet connection. Please check your network.",
      );
    } catch (e) {
      if (_isNetworkError(e)) {
        setState(
          () => _newPasswordError =
              "No internet connection. Please check your network.",
        );
      } else {
        setState(
          () => _newPasswordError = "Something went wrong. Please try again.",
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _rule(String text, bool ok) {
    return Row(
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: ok ? AppColors.success : AppColors.error,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: ok ? AppColors.success : AppColors.error,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth > 500 ? 500 : screenWidth - 45;

    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
      // Block system back; do not navigate back to Forget Password
      onWillPop: () async => false,
      child: Center(
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.background,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dialogWidth),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 24), // Spacer for centering
                          const Text(
                            "Reset password",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: AppColors.background.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Text("New password"),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        onChanged: _validatePassword,
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
                              _obscureNew
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.lightSeaGreen,
                            ),
                            onPressed: () =>
                                setState(() => _obscureNew = !_obscureNew),
                          ),
                        ),
                      ),
                      if (_newPasswordError != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          _newPasswordError!,
                          style: TextStyle(color: cs.error, fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 10),
                      const Text("Confirm new password"),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        onChanged: _validateConfirmPassword,
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
                              _obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.lightSeaGreen,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                          ),
                        ),
                      ),
                      if (_confirmPasswordError != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          _confirmPasswordError!,
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
                            _rule("At least one lowercase letter", hasLower),
                            _rule("At least one uppercase letter", hasUpper),
                            _rule("At least one number", hasNumber),
                            _rule("At least one special character", hasSpecial),
                            _rule("Minimum 8 characters", hasMinLength),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _loading
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
                                      context,
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
        ),
      ),
    );
  }
}

// Smooth dialog helper (fade + gentle scale)
Future<T?> _showSmoothDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = false,
  Color barrierColor = AppColors.overlay,
  Duration duration = const Duration(milliseconds: 260),
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
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
          child: widget,
        ),
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
