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
            'No internet connection',
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
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if manager application is approved
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isApproved = await authProvider.isManagerApplicationApproved();

      if (!mounted) return;

      if (isApproved) {
        // Application approved, navigate to dashboard
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ManagerHomeUI(data:ManagerHomeData())),
            );
          }
        });
      } else {
        // Still pending, show message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            SnackBarUtils.showSnackBar(
              context,
              'Application is still under review. Please check back later.',
              type: SnackBarType.other,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            SnackBarUtils.showSnackBar(
              context,
              'Error checking status: ${e.toString()}',
              type: SnackBarType.error,
            );
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => _buildManagerWaitingUI(this);
}
