part of password_success_popup;

class _SuccessPopupState extends State<SuccessPopup> {
  bool _canClose = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Must display for at least minimumDisplaySeconds seconds
    _timer = Timer(Duration(seconds: minimumDisplaySeconds), () {
      if (mounted) setState(() => _canClose = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _goToLogin() async {
    if (!_canClose || !mounted) return;
    // Push Login and clear everything (including this dialog)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) => _buildPasswordSuccessUI(this);
}
