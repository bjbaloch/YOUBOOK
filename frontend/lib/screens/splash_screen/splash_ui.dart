part of splash_screen;

Widget _buildSplashUI(_SplashScreenState state) {
  return AnimatedBuilder(
    animation: state._bgController,
    builder: (context, _) {
      return Scaffold(
        backgroundColor: AppColors.lightSeaGreen,
        body: Stack(
          key: state._stackKey,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: _animatedGradient(state._bgController.value),
              ),
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo animation
                      ScaleTransition(
                        scale: state._scaleAnim,
                        child: AnimatedBuilder(
                          animation: state._logoGlowAnim,
                          builder: (context, child) {
                            return Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.accentOrange,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.textWhite.withOpacity(0.25),
                                    blurRadius: 6 + state._logoGlowAnim.value,
                                    spreadRadius:
                                        1 + (state._logoGlowAnim.value / 2),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  "assets/yb_logo.png",
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback to icon if image fails to load
                                    return const Icon(
                                      Icons.info,
                                      size: 80,
                                      color: AppColors.accentOrange,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Welcome text
                      SlideTransition(
                        position: state._welcomeOffset,
                        child: FadeTransition(
                          opacity: state._welcomeOpacity,
                          child: const Text(
                            "Welcome to\nMulti-Service Booking Platform",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: AppColors.textWhite,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // YOUBOOK.com
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _animatedLetter(state,
                            char: "Y",
                            color: AppColors.textWhite,
                            index: 0,
                          ),
                          _animatedLetter(state,
                            char: "O",
                            color: AppColors.logoYellow,
                            index: 1,
                          ),
                          _animatedLetter(state,
                            char: "U",
                            color: AppColors.textWhite,
                            index: 2,
                          ),
                          _animatedLetter(state,
                            char: "B",
                            color: AppColors.textWhite,
                            index: 3,
                          ),
                          _animatedLetter(state,
                            char: "O",
                            color: AppColors.logoYellow,
                            index: 4,
                          ),
                          _animatedLetter(state,
                            char: "O",
                            color: AppColors.logoYellow,
                            index: 5,
                          ),
                          _animatedLetter(state,
                            char: "K",
                            color: AppColors.textWhite,
                            index: 6,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 1.0),
                            child: _animatedLetter(state,
                              char: ".com",
                              color: AppColors.textWhite,
                              index: 7,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 180),

                      // Attractive progress area
                      FadeTransition(
                        opacity: state._buttonOpacity,
                        child: ScaleTransition(
                          scale: state._buttonScale,
                          child: SizedBox(
                            width: 220,
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: LinearProgressIndicator(
                                    value: state._progress / 100,
                                    minHeight: 10,
                                    backgroundColor: Colors.white24,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          AppColors.accentOrange,
                                        ),
                                  ),
                                ),
                                // Bus icon moving along the bar
                                AnimatedBuilder(
                                  animation: state._loadingController,
                                  builder: (context, _) {
                                    return Positioned(
                                      left: (state._loadingController.value * 200)
                                          .clamp(0, 200),
                                      top: -6,
                                      child: Transform.rotate(
                                        angle: 0,
                                        child: const Icon(
                                          Icons.directions_bus_rounded,
                                          color: AppColors.textWhite,
                                          size: 28,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                      Text(
                        "${state._progress.toInt()}%",
                        style: const TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Ripple painter overlay
            IgnorePointer(
              ignoring: true,
              child: CustomPaint(
                painter: _RipplePainter(state._ripples),
                size: Size.infinite,
              ),
            ),

            // Tap ripple effect
            Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (e) => _spawnRipple(state, e.position),
            ),
          ],
        ),
      );
    },
  );
}

LinearGradient _animatedGradient(double t) {
  final phase = (math.sin(t * 2 * math.pi) + 1) / 2;
  return LinearGradient(
    begin: Alignment.lerp(Alignment.topLeft, Alignment.bottomRight, phase)!,
    end: Alignment.lerp(Alignment.bottomRight, Alignment.topLeft, phase)!,
    colors: const [AppColors.lightSeaGreen, AppColors.background],
  );
}

Widget _animatedLetter(_SplashScreenState state, {
  required String char,
  required Color color,
  required int index,
}) {
  final double start = 0.40 + index * 0.07;
  final double end = (start + 0.30).clamp(0.0, 1.0);
  final anim = CurvedAnimation(
    parent: state._introController,
    curve: Interval(start, end, curve: Curves.easeOutBack),
  );
  return ScaleTransition(
    scale: Tween<double>(begin: 0.6, end: 1.0).animate(anim),
    child: FadeTransition(
      opacity: anim,
      child: Text(
        char,
        style: TextStyle(
          fontSize: 20,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

void _spawnRipple(_SplashScreenState state, Offset globalPos) {
  final box = state._stackKey.currentContext?.findRenderObject() as RenderBox?;
  if (box == null) return;
  final local = box.globalToLocal(globalPos);

  final controller = AnimationController(
    vsync: state,
    duration: const Duration(milliseconds: 600),
  );
  late final _TouchRipple ripple;
  ripple = _TouchRipple(position: local, controller: controller);

  controller.addListener(() => state.setState(() {}));
  controller.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      controller.dispose();
      state.setState(() {
        state._ripples.remove(ripple);
      });
    }
  });

  state.setState(() {
    state._ripples.add(ripple);
  });
  controller.forward();
}
