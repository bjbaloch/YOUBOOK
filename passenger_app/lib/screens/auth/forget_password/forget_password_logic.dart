part of forget_password_popup;

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
  int _cooldown = 0;
  Timer? _cooldownTimer;

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
    setState(() => _cooldown = cooldownSeconds);
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
      setState(() => _emailError = enterEmailMessage);
      return;
    }
    if (!emailRegex.hasMatch(email)) {
      setState(() => _emailError = invalidEmailMessage);
      return;
    }
    if (_cooldown > 0) {
      return;
    }

    if (!await _hasInternet()) {
      setState(() => _emailError = noInternetMessage);
      return;
    }

    setState(() => _isSending = true);

    try {
      await supabase.auth.signInWithOtp(email: email, shouldCreateUser: false);

      setState(() {
        _successMessage = codeSentMessage;
      });

      _startCooldown();

      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) FocusScope.of(context).unfocus();
    } on AuthException catch (e) {
      setState(
        () => _emailError = _looksLikeNetworkError(e)
            ? noInternetMessage
            : e.message,
      );
    } on SocketException {
      setState(() => _emailError = noInternetMessage);
    } catch (_) {
      setState(() => _emailError = errorSendingMessage);
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
      setState(() => _codeError = enterCodeMessage);
      return;
    }
    if (code.length != 6) {
      setState(() => _codeError = codeLengthMessage);
      return;
    }

    if (!await _hasInternet()) {
      setState(() => _codeError = noInternetMessage);
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

      // ✅ Smooth open ResetPasswordPopup too
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierLabel: "Reset Password",
        barrierColor: AppColors.black45,
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => const ResetPasswordPopup(),
        transitionBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
              child: child,
            ),
          );
        },
      );
    } catch (e) {
      setState(() => _codeError = invalidExpiredCodeMessage);
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) => _buildForgetPasswordUI(this, widget);
}
