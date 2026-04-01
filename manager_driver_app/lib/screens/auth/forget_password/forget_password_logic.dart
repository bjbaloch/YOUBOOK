part of forget_password_popup;

class ForgetPasswordPopup extends StatefulWidget {
  const ForgetPasswordPopup({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ForgetPasswordPopup> createState() => _ForgetPasswordPopupState();

  static Future<void> show(BuildContext context, {String? initialEmail}) {
    return AppRouter.push(
      context,
      ForgetPasswordPopup(initialEmail: initialEmail),
    );
  }
}

class _ForgetPasswordPopupState extends State<ForgetPasswordPopup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  // TODO: Restore when connecting backend

  String? _emailError;
  String? _codeError;
  String? _successMessage;

  bool _isSending = false;
  bool _isVerifying = false;

  int _cooldown = 0;
  Timer? _cooldownTimer;

  bool get _hasInitialEmail =>
      widget.initialEmail != null && widget.initialEmail!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
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

    // TODO: Restore Supabase OTP when connecting backend
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _successMessage = codeSentMessage;
      _isSending = false;
    });
    _startCooldown();
    FocusScope.of(context).unfocus();
  }

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

    // TODO: Restore Supabase OTP verification when connecting backend
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isVerifying = false);
    AppRouter.replace(context, const ResetPasswordPopup());
  }

  @override
  Widget build(BuildContext context) => _buildForgetPasswordUI(this, widget);
}
