part of reset_password_popup;

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
      setState(() => _newPasswordError = enterPasswordMessage);
      return;
    }

    // Validate confirm password is not empty
    if (confirmPassword.isEmpty) {
      setState(() => _confirmPasswordError = confirmPasswordMessage);
      return;
    }

    // Validate passwords match
    if (newPassword != confirmPassword) {
      setState(() => _confirmPasswordError = passwordsNotMatchMessage);
      return;
    }

    // Validate password strength
    if (!(hasLower && hasUpper && hasNumber && hasSpecial && hasMinLength)) {
      setState(() => _newPasswordError = passwordRequirementsMessage);
      return;
    }

    setState(() => _loading = true);

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
        setState(() => _newPasswordError = passwordResetFailedMessage);
      }
    } on AuthException catch (e) {
      if (_isNetworkError(e)) {
        setState(() => _newPasswordError = noInternetMessage);
      } else {
        // Common: session expired if user waited too long after OTP verify
        final msg = e.message.toLowerCase();
        if (msg.contains('session') ||
            msg.contains('expired') ||
            msg.contains('token')) {
          setState(() => _newPasswordError = sessionExpiredMessage);
        } else {
          setState(() => _newPasswordError = e.message);
        }
      }
    } on SocketException {
      setState(() => _newPasswordError = noInternetMessage);
    } catch (e) {
      if (_isNetworkError(e)) {
        setState(() => _newPasswordError = noInternetMessage);
      } else {
        setState(() => _newPasswordError = somethingWentWrongMessage);
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
  Widget build(BuildContext context) => _buildResetPasswordUI(this);
}
