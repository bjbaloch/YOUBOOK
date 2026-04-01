part of manager_waiting_screen;

class _ManagerWaitingScreenState extends State<ManagerWaitingScreen> {
  bool _isLoading = false; // Loading state for verification checks

  @override
  void initState() {
    super.initState();
    // Store screen preference for navigation persistence
    _storeScreenPreference();
    // NOTE: Application was already submitted in ManagerCompanyDetailsScreen
    // This screen just waits for admin approval
    // Check internet connectivity
    _checkInternetConnectivity();
  }

  Future<void> _checkInternetConnectivity() async {
    final hasInternet = await _hasInternet();
    if (!hasInternet && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          SnackBarUtils.showSnackBar(
            context,
            'No internet connection. Please check your network.',
            type: SnackBarType.error,
          );
        }
      });
    }
  }

  Future<void> _storeScreenPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_manager_screen', 'waiting');
    } catch (e) {
      // Silently handle SharedPreferences errors
      print('Error storing screen preference: $e');
    }
  }



  Future<void> _checkVerificationStatus() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _isLoading = false);

    // TODO: Replace with real backend approval check when going online
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => const ManagerHomeUI(
          data: ManagerHomeData(),
        ),
        transitionsBuilder: (_, animation, __, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          final slide = Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));
          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) => _buildManagerWaitingUI(this);
}
