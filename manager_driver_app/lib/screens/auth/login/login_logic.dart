part of login_screen;

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final _emailFN = FocusNode();
  final _emailDebouncer = Debouncer(600);
  bool _isEmailValid = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _emailController.addListener(() {
      final currentText = _emailController.text;
      final canonicalText = _canonicalEmail(currentText);
      if (currentText != canonicalText) {
        _emailController.value = _emailController.value.copyWith(
          text: canonicalText,
          selection: TextSelection.collapsed(offset: canonicalText.length),
        );
      }
      if (mounted) {
        setState(() {
          _isEmailValid = emailRegex.hasMatch(canonicalText);
        });
      }
    });

    _emailFN.addListener(() {
      if (!_emailFN.hasFocus) {
        setState(() {
          _isEmailValid = emailRegex.hasMatch(_canonicalEmail(_emailController.text));
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFN.dispose();
    _emailDebouncer.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      SnackBarUtils.showSnackBar(
        context,
        authProvider.error ?? 'Invalid email or password.',
        type: SnackBarType.error,
      );
      return;
    }

    final role = authProvider.userRole;

    SnackBarUtils.showSnackBar(
      context,
      'Welcome back, ${authProvider.user?.fullName ?? role}!',
      type: SnackBarType.success,
    );
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    if (role == AppConstants.roleDriver) {
      AppRouter.replaceAll(context, const DriverHomeScreen());
    } else {
      // Manager — route based on onboarding state
      if (!authProvider.hasCompanyDetails) {
        AppRouter.replaceAll(context, const ManagerCompanyDetailsScreen());
      } else if (!authProvider.isApproved) {
        AppRouter.replaceAll(
          context,
          ManagerWaitingScreen(companyName: authProvider.user?.fullName),
        );
      } else {
        AppRouter.replaceAll(context, ManagerHomeUI(data: ManagerHomeData()));
      }
    }
  }

  @override
  Widget build(BuildContext context) => _buildLoginUI(this);
}
