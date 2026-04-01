library splash_screen;

import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../core/providers/auth_provider.dart';
// import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/app_router.dart';
import '../auth/login/login_screen.dart';
// import '../driver/driver_home_screen.dart';
// import '../manager/Home/Data/manager_home_data.dart';
// import '../manager/Home/UI/manager_home_ui.dart';
// import '../manager/manager_waiting_screen/manager_waiting_screen.dart';
// import '../manager/manager_company_details/manager_company_details_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;

  double _progress = 0.0;
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn),
    );
    _runSplash();
  }

  Future<void> _runSplash() async {
    await _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _textCtrl.forward();
    await _initializeAndNavigate();
  }

  void _setStatus(String status) {
    if (!mounted) return;
    setState(() => _status = status);
  }

  Future<void> _animateProgressTo(double target) async {
    const steps = 20;
    final start = _progress;
    final diff = target - start;
    for (int i = 1; i <= steps; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      setState(() => _progress = start + diff * (i / steps));
    }
  }

  Future<void> _initializeAndNavigate() async {
    // TODO: Uncomment when connecting to Supabase
    // Run auth work and 5-second timer in parallel
    // final minWait = Future.delayed(const Duration(seconds: 5));
    // ... auth checks ...

    // UI-only mode: just show the progress bar for 5 seconds then go to login
    final minWait = Future.delayed(const Duration(seconds: 5));

    _setStatus('Loading...');
    await _animateProgressTo(0.3);
    _setStatus('Preparing interface...');
    await _animateProgressTo(0.6);
    _setStatus('Almost ready...');
    await _animateProgressTo(0.85);

    await minWait;

    if (!mounted) return;
    _setStatus('Ready!');
    await _animateProgressTo(1.0);
    await Future.delayed(const Duration(milliseconds: 400));

    _goTo(const LoginScreen());
  }

  void _goTo(Widget screen) {
    if (!mounted) return;
    AppRouter.replaceAll(context, screen);
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.lightSeaGreen, Color(0xFF0A6B66)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentOrange.withOpacity(0.08),
                ),
              ),
            ),
            // Version pinned to bottom
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Text(
                'v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _logoCtrl,
                      builder: (_, __) => Transform.scale(
                        scale: _logoScale.value,
                        child: Opacity(
                          opacity: _logoOpacity.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.directions_bus_rounded,
                              size: 64,
                              color: AppColors.lightSeaGreen,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    AnimatedBuilder(
                      animation: _textCtrl,
                      builder: (_, __) => Opacity(
                        opacity: _textOpacity.value,
                        child: Column(
                          children: [
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Y',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: 'O',
                                    style: TextStyle(color: AppColors.logoYellow),
                                  ),
                                  TextSpan(
                                    text: 'U',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: 'B',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: 'O',
                                    style: TextStyle(color: AppColors.logoYellow),
                                  ),
                                  TextSpan(
                                    text: 'O',
                                    style: TextStyle(color: AppColors.logoYellow),
                                  ),
                                  TextSpan(
                                    text: 'K',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Welcome to Multi-Service Booking Platform',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'YouBook.com',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.logoYellow,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.08),
                    AnimatedBuilder(
                      animation: _textCtrl,
                      builder: (_, __) => Opacity(
                        opacity: _textOpacity.value,
                        child: Column(
                          children: [
                            SizedBox(
                              width: 56,
                              height: 56,
                              child: CircularProgressIndicator(
                                value: _progress,
                                strokeWidth: 4,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.accentOrange,
                                ),
                                backgroundColor: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            const SizedBox(height: 20),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              child: Text(
                                _status,
                                key: ValueKey(_status),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.85),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: size.width * 0.5,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.accentOrange,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
