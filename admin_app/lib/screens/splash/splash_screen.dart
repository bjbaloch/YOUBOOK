import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/core.dart';
import '../../core/widgets/main_layout.dart';
import '../dashboard/dashboard_screen.dart';
import '../auth/auth.dart';

class AdminSplashScreen extends StatefulWidget {
  const AdminSplashScreen({super.key});

  @override
  State<AdminSplashScreen> createState() => _AdminSplashScreenState();
}

class _AdminSplashScreenState extends State<AdminSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;

  late AnimationController _textAnimationController;
  late Animation<double> _textOpacityAnimation;

  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  String _currentStatus = 'Initializing...';
  double _progress = 0.0;

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

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
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
      setState(() {
        _currentStatus = 'Connecting to database...';
        _progress = 0.1;
      });
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _currentStatus = 'Database connected';
        _progress = 0.3;
      });
      await _progressAnimationController.forward();

      setState(() {
        _currentStatus = 'Setting up notifications...';
        _progress = 0.5;
      });
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _currentStatus = 'Notifications ready';
        _progress = 0.7;
      });
      await _progressAnimationController.forward();

      setState(() {
        _currentStatus = 'Checking authentication...';
        _progress = 0.9;
      });
      await Future.delayed(const Duration(milliseconds: 300));

      final authProvider = Provider.of<AdminAuthProvider>(
        context,
        listen: false,
      );

      setState(() {
        _currentStatus = 'Ready!';
        _progress = 1.0;
      });

      await Future.delayed(const Duration(milliseconds: 800));
      _navigateToNextScreen();
    } catch (e) {
      debugPrint('Splash screen initialization error: $e');
      setState(() {
        _currentStatus = 'Initialization failed';
      });
      await Future.delayed(const Duration(seconds: 2));
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    final authProvider = Provider.of<AdminAuthProvider>(context, listen: false);

    Widget nextScreen;
    if (authProvider.isAuthenticated) {
      nextScreen = MainLayout(
        title: 'Dashboard',
        child: const DashboardScreen(),
      );
    } else {
      nextScreen = const LoginScreen();
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => nextScreen));
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _textAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
              const Color(0xFF1A237E),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.03,
                child: CustomPaint(painter: BackgroundPatternPainter()),
              ),
            ),

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

            Positioned(
              bottom: screenSize.height * 0.15,
              left: screenSize.width * 0.08,
              child: AnimatedBuilder(
                animation: _textAnimationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      (1 - _textAnimationController.value) * 20,
                    ),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Center(
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
                    AnimatedBuilder(
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
                                    color: AppColors.primary.withOpacity(0.2),
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
                                          AppColors.primary.withOpacity(0.1),
                                          AppColors.primaryDark.withOpacity(0.2),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  Icon(
                                    Icons.admin_panel_settings,
                                    size: screenSize.width * 0.15,
                                    color: AppColors.primary,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.primary.withOpacity(0.3),
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
                    ),

                    SizedBox(height: screenSize.height * 0.06),

                    // App name section
                    AnimatedBuilder(
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
                                          color: AppColors.primary.withOpacity(0.3),
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
                                    'Administrator Panel',
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
                    ),

                    SizedBox(height: screenSize.height * 0.08),

                    // Loading section
                    Container(
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
                    ),

                    SizedBox(height: screenSize.height * 0.04),

                    // Status text
                    Container(
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
                    ),

                    const SizedBox(height: 20),

                    // Progress percentage
                    Container(
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
                    ),

                    const SizedBox(height: 8),

                    // Progress bar
                    Container(
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
                    ),

                    SizedBox(height: screenSize.height * 0.06),

                    // Version info
                    Container(
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        if ((x / spacing + y / spacing) % 2 == 0) {
          canvas.drawCircle(Offset(x, y), 1, paint);
        }
        if (x + spacing < size.width && (x / spacing) % 3 == 0) {
          canvas.drawLine(Offset(x, y), Offset(x + spacing, y), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
