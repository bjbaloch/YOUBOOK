import 'dart:async'; // Timer
import 'dart:io'; // SocketException + lookup
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:youbook/screens/auth/reset_password_popup.dart';
import 'package:youbook/core/theme/app_colors.dart';

class ForgetPasswordPopup extends StatefulWidget {
  const ForgetPasswordPopup({
    super.key,
    this.initialEmail, // Pass the login email to prefill
  });

  final String? initialEmail;

  @override
  State<ForgetPasswordPopup> createState() => _ForgetPasswordPopupState();

  /// ✅ Added: Helper to **open with smooth transitions**
  static Future<void> show(BuildContext context, {String? initialEmail}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Forget Password",
      barrierColor: AppColors.black45,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) =>
          ForgetPasswordPopup(initialEmail: initialEmail),
      transitionBuilder: (_, anim1, __, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }
}

class _ForgetPasswordPopupState extends State<ForgetPasswordPopup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  final supabase = Supabase.instance.client;

  String? _emailError;
  String? _codeError;
  String? _successMessage;

  bool _isSending = false; // "Get" button spinner
  bool _isVerifying = false; // "Continue" button spinner

  // 90s resend cooldown
  static const int _cooldownSeconds = 90;
  int _cooldown = 0;
  Timer? _cooldownTimer;

  // Real email validation
  final RegExp _emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');

  bool get _hasInitialEmail =>
      widget.initialEmail != null && widget.initialEmail!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Prefill from login if provided
    if (_hasInitialEmail) {
      _emailController.text = widget.initialEmail!.trim();
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // Cross-platform network check (fast)
  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool _looksLikeNetworkError(dynamic e) {
    if (e is SocketException) return true;
    final m = e.toString().toLowerCase();
    return m.contains('network') ||
        m.contains('host lookup') ||
        m.contains('failed host lookup') ||
        m.contains('socket') ||
        m.contains('timed out') ||
        m.contains('xmlhttprequest') ||
        m.contains('failed to fetch');
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldown = _cooldownSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_cooldown > 0) {
          _cooldown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  // Send 6-digit email OTP
  Future<void> _sendResetCode() async {
    setState(() {
      _emailError = null;
      _successMessage = null;
    });

    final email = _emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      setState(() => _emailError = "Enter the email address");
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      setState(() => _emailError = "Please enter a valid email address");
      return;
    }
    if (_cooldown > 0) {
      return;
    }

    if (!await _hasInternet()) {
      setState(
        () =>
            _emailError = "No internet connection. Please check your network.",
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      await supabase.auth.signInWithOtp(email: email, shouldCreateUser: false);

      setState(() {
        _successMessage = "A 6-digit code has been sent to your email address.";
      });

      _startCooldown();

      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) FocusScope.of(context).unfocus();
    } on AuthException catch (e) {
      setState(
        () => _emailError = _looksLikeNetworkError(e)
            ? "No internet connection."
            : e.message,
      );
    } on SocketException {
      setState(
        () =>
            _emailError = "No internet connection. Please check your network.",
      );
    } catch (_) {
      setState(() => _emailError = "Error sending code. Please try again.");
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // Verify code -> navigate Reset popup
  Future<void> _continue() async {
    setState(() {
      _codeError = null;
    });

    final code = _codeController.text.trim();
    final email = _emailController.text.trim().toLowerCase();

    if (code.isEmpty) {
      setState(() => _codeError = "Please enter the code");
      return;
    }
    if (code.length != 6) {
      setState(() => _codeError = "Code must be 6 digits");
      return;
    }

    if (!await _hasInternet()) {
      setState(
        () => _codeError = "No internet connection. Please check your network.",
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      await supabase.auth.verifyOTP(
        type: OtpType.email,
        email: email,
        token: code,
      );

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      // // ✅ Smooth open ResetPasswordPopup too
      // showGeneralDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   barrierLabel: "Reset Password",
      //   barrierColor: AppColors.black45,
      //   transitionDuration: const Duration(milliseconds: 300),
      //   pageBuilder: (_, __, ___) => const ResetPasswordPopup(),
      //   transitionBuilder: (_, anim, __, child) {
      //     return FadeTransition(
      //       opacity: anim,
      //       child: ScaleTransition(
      //         scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
      //         child: child,
      //       ),
      //     );
      //   },
      // );

      // For now, just show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code verified successfully!')),
      );
    } catch (e) {
      setState(() => _codeError = "Invalid or expired code. Please try again.");
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dialogWidth = screenWidth > 500 ? 500 : screenWidth - 45;
    const double dialogHeight = 370;

    final bool lockEmailField = !_hasInitialEmail;
    final String emailTrim = _emailController.text.trim();
    final bool disableGetButton =
        _isSending ||
        _cooldown > 0 ||
        emailTrim.isEmpty ||
        !_emailRegex.hasMatch(emailTrim);

    final cs = Theme.of(context).colorScheme;

    return WillPopScope(
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
          child: SizedBox(
            width: dialogWidth,
            height: dialogHeight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 24), // Spacer for centering
                          const Text(
                            "Forget password",
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

                      const Text("Email address"),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _emailController,
                              readOnly: lockEmailField,
                              enableInteractiveSelection: !lockEmailField,
                              onTap: lockEmailField
                                  ? () => FocusScope.of(context).unfocus()
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
                                  color: AppColors.lightSeaGreen.withOpacity(
                                    0.4,
                                  ),
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
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 80,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: disableGetButton
                                  ? null
                                  : _sendResetCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: _isSending
                                  ? SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.lightSeaGreen,
                                      ),
                                    )
                                  : Text(
                                      _cooldown > 0
                                          ? "Resend${_cooldown}s"
                                          : "Get",
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      if (_emailError != null)
                        Text(
                          _emailError!,
                          style: TextStyle(color: cs.error, fontSize: 12),
                        ),
                      if (_successMessage != null)
                        Text(
                          _successMessage!,
                          style: TextStyle(
                            color: AppColors.successGreen,
                            fontSize: 12,
                          ),
                        ),

                      const SizedBox(height: 10),
                      const Text("Enter the code that was sent to your email"),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _codeController,
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
                      if (_codeError != null)
                        Text(
                          _codeError!,
                          style: TextStyle(color: cs.error, fontSize: 12),
                        ),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _isVerifying ? null : _continue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: _isVerifying
                                  ? CircularProgressIndicator(
                                      color: AppColors.lightSeaGreen,
                                    )
                                  : Text(
                                      "Continue",
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
