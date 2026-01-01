part of splash_screen;

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _introController;
  late final AnimationController _bgController;
  late final AnimationController _loadingController;

  late final Animation<double> _scaleAnim;
  late final Animation<double> _logoGlowAnim;
  late final Animation<double> _welcomeOpacity;
  late final Animation<Offset> _welcomeOffset;
  late final Animation<double> _buttonOpacity;
  late final Animation<double> _buttonScale;

  final GlobalKey _stackKey = GlobalKey();
  final List<_TouchRipple> _ripples = [];

  double _progress = 0.0;

  @override
  void initState() {
    super.initState();

    // Pulsing logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.94, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _logoGlowAnim = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Intro animations
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();

    _welcomeOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.25, 0.60, curve: Curves.easeOut),
    );
    _welcomeOffset =
        Tween<Offset>(begin: const Offset(0, 0.20), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.25, 0.60, curve: Curves.easeOut),
          ),
        );

    _buttonOpacity = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );
    _buttonScale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.65, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // Animated background
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // 3-second progress animation
    _loadingController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addListener(() {
            setState(() {
              _progress = _loadingController.value * 100;
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              if (mounted) {
                _navigateToNextScreen(context.read<AuthProvider>());
              }
            }
          });

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize authentication
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initializeAuth();

      // Start loading animation after intro
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          _loadingController.forward();
        }
      });
    } catch (e) {
      // If something goes wrong, still show the animation but redirect to login
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        }
      });
    }
  }

  Future<void> _navigateToNextScreen(AuthProvider authProvider) async {
    print('DEBUG: Starting _navigateToNextScreen');

    // Check for stored manager screen preference
    final prefs = await SharedPreferences.getInstance();
    final lastManagerScreen = prefs.getString('last_manager_screen');

    if (lastManagerScreen != null) {
      print('DEBUG: Found stored manager screen: $lastManagerScreen');
      // Clear the stored preference after reading
      await prefs.remove('last_manager_screen');
    }

    Widget nextScreen = const LoginScreen(); // Default fallback

    // Check for pending email confirmation data
    // prefs already obtained above
    final pendingEmail = prefs.getString('pending_email');
    final pendingRole = prefs.getString('pending_role');

    // Check if Supabase user exists (even if profile doesn't)
    final supabaseUser = Supabase.instance.client.auth.currentUser;

    print('DEBUG: pendingEmail: $pendingEmail');
    print('DEBUG: pendingRole: $pendingRole');
    print('DEBUG: supabaseUser exists: ${supabaseUser != null}');
    print('DEBUG: supabaseUser email: ${supabaseUser?.email}');
    print('DEBUG: emailConfirmedAt: ${supabaseUser?.emailConfirmedAt}');
    print(
      'DEBUG: authProvider.isAuthenticated: ${authProvider.isAuthenticated}',
    );
    print('DEBUG: authProvider.user: ${authProvider.user}');
    print('DEBUG: authProvider.userRole: ${authProvider.userRole}');

    print('DEBUG: Evaluating navigation conditions...');

    if (pendingEmail != null && pendingRole != null && supabaseUser != null) {
      print('DEBUG: Has pending confirmation data and supabase user');
      // User is authenticated in Supabase but might be in email confirmation flow
      if (supabaseUser.emailConfirmedAt == null) {
        print('DEBUG: Email not confirmed, showing EmailConfirmationScreen');
        // Email not confirmed yet, show confirmation screen
        final pendingCompanyName = prefs.getString('pending_company_name');
        final pendingCredentialDetails = prefs.getString(
          'pending_credential_details',
        );

        nextScreen = EmailConfirmationScreen(
          email: pendingEmail,
          role: pendingRole,
          companyName: pendingCompanyName,
          credentialDetails: pendingCredentialDetails,
        );
      } else {
        print(
          'DEBUG: Email confirmed, clearing pending data and navigating normally',
        );
        // Email is confirmed, clear stored data and navigate normally
        await _clearPendingConfirmationData();

        // Navigate based on user role (now that profile should exist)
        if (authProvider.isAuthenticated) {
          print(
            'DEBUG: User authenticated, navigating based on role: ${authProvider.userRole}',
          );
          try {
            switch (authProvider.userRole) {
          case AppConstants.roleManager:
            print(
              'DEBUG: User is manager, checking if application submitted...',
            );
            // For managers, check if they've submitted an application (not just approved)
            final hasSubmittedApplication = await _checkIfManagerApplicationExists(supabaseUser!.id);

            print(
              'DEBUG: Manager has submitted application: $hasSubmittedApplication',
            );

            if (hasSubmittedApplication) {
              // Check if application is approved
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final isApproved = await authProvider.isManagerApplicationApproved();

              // Determine valid screens based on current approval status
              List<String> validScreens;
              Widget defaultScreen;

              if (isApproved) {
                // If approved, valid screens are dashboard and waiting
                validScreens = ['dashboard', 'waiting'];
                defaultScreen = const ManagerDashboard();
              } else {
                // If not approved, only waiting screen is valid
                validScreens = ['waiting'];
                defaultScreen = const ManagerWaitingScreen();
              }

              // Check if we have a stored screen preference and it's valid for current state
              if (lastManagerScreen != null && validScreens.contains(lastManagerScreen)) {
                print('DEBUG: Using stored preference: $lastManagerScreen');

                if (lastManagerScreen == 'dashboard') {
                  nextScreen = const ManagerDashboard();
                } else if (lastManagerScreen == 'waiting') {
                  nextScreen = const ManagerWaitingScreen();
                }
              } else {
                // No stored preference or invalid preference, use default for current status
                print('DEBUG: Using default screen for current approval status: ${isApproved ? 'approved' : 'not approved'}');
                nextScreen = defaultScreen;
              }
            } else {
              print('DEBUG: Manager has not submitted application, going to ManagerCompanyDetailsScreen');
              nextScreen = const ManagerCompanyDetailsScreen();
            }
            break;
              case AppConstants.roleDriver:
                nextScreen = const DriverHomeScreen();
                break;
              case AppConstants.rolePassenger:
              default:
                nextScreen = const HomeShell();
                break;
            }
          } catch (e) {
            print('DEBUG: Error during navigation, defaulting to login: $e');
            nextScreen = const LoginScreen();
          }
        } else {
          print(
            'DEBUG: User not authenticated after confirmation, going to login',
          );
          // Profile still doesn't exist, go to login
          nextScreen = const LoginScreen();
        }
      }
    } else if (authProvider.isAuthenticated) {
      print(
        'DEBUG: No pending data but user authenticated, navigating based on role: ${authProvider.userRole}',
      );
      // Navigate based on user role
      try {
        switch (authProvider.userRole) {
          case AppConstants.roleManager:
            print(
              'DEBUG: User is manager, checking if application submitted...',
            );
            // For managers, check if they've submitted an application (not just approved)
            final hasSubmittedApplication = await _checkIfManagerApplicationExists(supabaseUser!.id);

            print(
              'DEBUG: Manager has submitted application: $hasSubmittedApplication',
            );

            if (hasSubmittedApplication) {
              // Check if application is approved
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final isApproved = await authProvider.isManagerApplicationApproved();

              // Determine valid screens based on current approval status
              List<String> validScreens;
              Widget defaultScreen;

              if (isApproved) {
                // If approved, valid screens are dashboard and waiting
                validScreens = ['dashboard', 'waiting'];
                defaultScreen = const ManagerDashboard();
              } else {
                // If not approved, only waiting screen is valid
                validScreens = ['waiting'];
                defaultScreen = const ManagerWaitingScreen();
              }

              // Check if we have a stored screen preference and it's valid for current state
              if (lastManagerScreen != null && validScreens.contains(lastManagerScreen)) {
                print('DEBUG: Using stored preference: $lastManagerScreen');

                if (lastManagerScreen == 'dashboard') {
                  nextScreen = const ManagerDashboard();
                } else if (lastManagerScreen == 'waiting') {
                  nextScreen = const ManagerWaitingScreen();
                }
              } else {
                // No stored preference or invalid preference, use default for current status
                print('DEBUG: Using default screen for current approval status: ${isApproved ? 'approved' : 'not approved'}');
                nextScreen = defaultScreen;
              }
            } else {
              print('DEBUG: Manager has not submitted application, going to ManagerCompanyDetailsScreen');
              nextScreen = const ManagerCompanyDetailsScreen();
            }
            break;
          case AppConstants.roleDriver:
            nextScreen = const DriverHomeScreen();
            break;
          case AppConstants.rolePassenger:
          default:
            nextScreen = const HomeShell();
            break;
        }
      } catch (e) {
        print('DEBUG: Error during navigation, defaulting to login: $e');
        nextScreen = const LoginScreen();
      }
    } else {
      print('DEBUG: User not authenticated, going to login screen');
      // User not authenticated, go to login
      nextScreen = const LoginScreen();
    }

    print('DEBUG: Next screen decided: ${nextScreen.runtimeType}');

    if (mounted) {
      print('DEBUG: Navigating to ${nextScreen.runtimeType}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
      );
      print('DEBUG: Navigation completed');
    } else {
      print('DEBUG: Component not mounted, skipping navigation');
    }
  }

  Future<bool> _checkIfManagerApplicationExists(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('manager_applications')
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      print('DEBUG: Error checking manager application existence: $e');
      return false;
    }
  }

  Future<void> _clearPendingConfirmationData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_email');
    await prefs.remove('pending_role');
    await prefs.remove('pending_company_name');
    await prefs.remove('pending_credential_details');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _introController.dispose();
    _bgController.dispose();
    _loadingController.dispose();
    for (final r in _ripples) {
      r.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _buildSplashUI(this);
}
