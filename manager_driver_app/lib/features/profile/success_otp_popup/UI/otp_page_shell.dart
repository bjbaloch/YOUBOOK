import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manager_driver_app/core/theme/app_colors.dart';

class OtpPageShell extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int secondsRemaining;
  final bool isVerifying;
  final bool isResending;
  final bool isOtpComplete;
  final List<TextEditingController> otpControllers;
  final List<FocusNode> focusNodes;
  final void Function(String val, int index) onOtpChanged;
  final VoidCallback onVerify;
  final VoidCallback onResend;

  const OtpPageShell({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.secondsRemaining,
    required this.isVerifying,
    required this.isResending,
    required this.isOtpComplete,
    required this.otpControllers,
    required this.focusNodes,
    required this.onOtpChanged,
    required this.onVerify,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.lightSeaGreen,
        elevation: 0,
        toolbarHeight: 56,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.lightSeaGreen, AppColors.accentOrange],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        child: Column(
          children: [
            // ── Icon + subtitle ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icon badge
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.lightSeaGreen.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.lightSeaGreen.withOpacity(0.25),
                        width: 2,
                      ),
                    ),
                    child: Icon(icon,
                        color: AppColors.lightSeaGreen, size: 38),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.black.withOpacity(0.5),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── OTP boxes card ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Enter Verification Code',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withOpacity(0.55),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) {
                      final isFilled = otpControllers[i].text.isNotEmpty;
                      return _OtpBox(
                        controller: otpControllers[i],
                        focusNode: focusNodes[i],
                        isFilled: isFilled,
                        onChanged: (val) => onOtpChanged(val, i),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  // Countdown ring + resend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CountdownRing(secondsRemaining: secondsRemaining),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            secondsRemaining > 0
                                ? 'Code expires in'
                                : "Didn't receive the code?",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.45),
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: (isResending || secondsRemaining > 0)
                                ? null
                                : onResend,
                            child: isResending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.lightSeaGreen,
                                    ),
                                  )
                                : Text(
                                    secondsRemaining > 0
                                        ? _formatTime(secondsRemaining)
                                        : 'Resend Code',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: secondsRemaining > 0
                                          ? Colors.black87
                                          : AppColors.lightSeaGreen,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Divider(color: Colors.grey.withOpacity(0.12), height: 1),
                  const SizedBox(height: 24),

                  // Verify button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: (isVerifying || !isOtpComplete)
                          ? null
                          : onVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightSeaGreen,
                        disabledBackgroundColor:
                            AppColors.lightSeaGreen.withOpacity(0.4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isVerifying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Verify Code',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Security note ─────────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accentOrange.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 18,
                      color: AppColors.accentOrange.withOpacity(0.8)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Never share your OTP with anyone. YouBook will never ask for it.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.accentOrange.withOpacity(0.85),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

// ── Single OTP box ────────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFilled;
  final void Function(String) onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.isFilled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (_, __) {
        final hasFocus = focusNode.hasFocus;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 54,
          decoration: BoxDecoration(
            color: isFilled
                ? AppColors.lightSeaGreen.withOpacity(0.08)
                : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasFocus
                  ? AppColors.lightSeaGreen
                  : isFilled
                      ? AppColors.lightSeaGreen.withOpacity(0.4)
                      : Colors.grey.withOpacity(0.25),
              width: hasFocus ? 2 : 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.lightSeaGreen,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: onChanged,
          ),
        );
      },
    );
  }
}

// ── Circular countdown ring ───────────────────────────────────────────────────

class _CountdownRing extends StatelessWidget {
  final int secondsRemaining;
  static const int _total = 60;

  const _CountdownRing({required this.secondsRemaining});

  @override
  Widget build(BuildContext context) {
    final progress = secondsRemaining / _total;
    final isExpired = secondsRemaining <= 0;

    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(52, 52),
            painter: _RingPainter(
              progress: progress,
              color: isExpired
                  ? Colors.grey.withOpacity(0.3)
                  : AppColors.lightSeaGreen,
              trackColor: Colors.grey.withOpacity(0.12),
            ),
          ),
          Icon(
            isExpired ? Icons.timer_off_rounded : Icons.timer_rounded,
            size: 20,
            color: isExpired
                ? Colors.grey.withOpacity(0.4)
                : AppColors.lightSeaGreen,
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = (size.width - 6) / 2;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Track
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}
