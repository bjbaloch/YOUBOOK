part of manager_splash_screen;

class _ManagerSplashScreenState extends State<ManagerSplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;

  late AnimationController _textAnimationController;
  late Animation<double> _textOpacityAnimation;

  late AnimationController _progressAnimationController;

  String _currentStatus = 'Initializing...';
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.lightSeaGreen,
              AppColors.accentOrange,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            _buildBackgroundElements(),
            
            // Main content
            _buildMainContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundElements() {
    final screenSize = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // Floating elements
        Positioned(
          top: screenSize.height * 0.1,
          right: screenSize.width * 0.1,
          child: AnimatedBuilder(
            animation: _logoAnimationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _logoAnimationController.value * 0.5,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    final screenSize = MediaQuery.of(context).size;
    
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.08,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo section
            _buildLogoSection(),
            
            SizedBox(height: screenSize.height * 0.06),
            
            // App name section
            _buildAppTitleSection(),
            
            SizedBox(height: screenSize.height * 0.08),
            
            // Loading section
            _buildLoadingSection(),
            
            SizedBox(height: screenSize.height * 0.04),
            
            // Status text
            _buildStatusText(),
            
            const SizedBox(height: 20),
            
            // Progress percentage
            _buildProgressPercentage(),
            
            const SizedBox(height: 8),
            
            // Progress bar
            _buildProgressBar(),
            
            SizedBox(height: screenSize.height * 0.06),
            
            // Version info
            _buildVersionInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    final screenSize = MediaQuery.of(context).size;
    
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Opacity(
            opacity: _logoOpacityAnimation.value,
            child: Container(
              width: screenSize.width * 0.35,
              height: screenSize.width * 0.35,
              constraints: const BoxConstraints(
                maxWidth: 160,
                maxHeight: 160,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.lightSeaGreen.withOpacity(0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                    spreadRadius: -5,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.8),
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: screenSize.width * 0.3,
                    height: screenSize.width * 0.3,
                    constraints: const BoxConstraints(
                      maxWidth: 130,
                      maxHeight: 130,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.lightSeaGreen.withOpacity(0.1),
                          AppColors.accentOrange.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  Icon(
                    Icons.business_center,
                    size: screenSize.width * 0.15,
                    color: AppColors.lightSeaGreen,
                    shadows: [
                      Shadow(
                        color: AppColors.lightSeaGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppTitleSection() {
    final screenSize = MediaQuery.of(context).size;
    
    return AnimatedBuilder(
      animation: _textAnimationController,
      builder: (context, child) {
        return Opacity(
          opacity: _textOpacityAnimation.value,
          child: Transform.translate(
            offset: Offset(
              0,
              (1 - _textOpacityAnimation.value) * 30,
            ),
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: Text(
                    'YOUBOOK',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.09,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 3,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: AppColors.lightSeaGreen.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Manager Panel',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.04,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSection() {
    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      width: screenSize.width * 0.2,
      height: screenSize.width * 0.2,
      constraints: const BoxConstraints(
        maxWidth: 90,
        maxHeight: 90,
      ),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircularProgressIndicator(
          value: _progress,
          strokeWidth: 4,
          valueColor: const AlwaysStoppedAnimation<Color>(
            Colors.white,
          ),
          backgroundColor: Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(animation),
            ),
          );
        },
        child: Text(
          _currentStatus,
          key: ValueKey<String>(_currentStatus),
          style: TextStyle(
            color: Colors.white,
            fontSize: screenSize.width * 0.04,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildProgressPercentage() {
    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${(_progress * 100).round()}%',
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: screenSize.width * 0.035,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      width: screenSize.width * 0.5,
      constraints: const BoxConstraints(maxWidth: 220),
      height: 3,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: _progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                Colors.white.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    final screenSize = MediaQuery.of(context).size;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            size: screenSize.width * 0.04,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(width: 8),
          Text(
            'v1.0.0',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: screenSize.width * 0.03,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.easeIn),
    );

    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textAnimationController, curve: Curves.easeIn),
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Future<void> _startSplashSequence() async {
    await _logoAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _textAnimationController.forward();
    await _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Check if user is authenticated
      if (authProvider.isAuthenticated) {
        final user = authProvider.user;
        
        if (user?.role == 'manager') {
          await _checkManagerApplicationStatus();
        } else {
          // Not a manager, navigate to appropriate screen
          _navigateToNonManagerScreen();
        }
      } else {
        // Not authenticated, navigate to login
        _navigateToLogin();
      }
    } catch (e) {
      debugPrint('Manager splash screen initialization error: $e');
      setState(() {
        _currentStatus = 'Initialization failed';
      });
      await Future.delayed(const Duration(seconds: 2));
      _navigateToLogin();
    }
  }

  Future<void> _checkManagerApplicationStatus() async {
    // TODO: Restore backend check when connecting backend
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isApproved) {
      _navigateToManagerDashboard();
    } else if (authProvider.hasCompanyDetails) {
      _navigateToWaitingScreen();
    } else {
      _navigateToCompanyDetails();
    }
  }

  void _navigateToManagerDashboard() {
    if (!mounted) return;
    AppRouter.replaceAll(context, ManagerHomeUI(data: ManagerHomeData()));
  }

  void _navigateToWaitingScreen() {
    if (!mounted) return;
    AppRouter.replaceAll(context, const ManagerWaitingScreen());
  }

  void _navigateToCompanyDetails() {
    if (!mounted) return;
    AppRouter.replaceAll(context, const ManagerCompanyDetailsScreen());
  }

  void _navigateToNonManagerScreen() {
    if (!mounted) return;
    AppRouter.replaceAll(context, const LoginScreen());
  }

  void _navigateToLogin() {
    if (!mounted) return;
    AppRouter.replaceAll(context, const LoginScreen());
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _textAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }
}