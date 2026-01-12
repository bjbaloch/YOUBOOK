part of splash_screen;

// Ripple effect classes
class _TouchRipple {
  _TouchRipple({required this.position, required this.controller});
  final Offset position;
  final AnimationController controller;
}

class _RipplePainter extends CustomPainter {
  _RipplePainter(this.ripples);
  final List<_TouchRipple> ripples;

  @override
  void paint(Canvas canvas, Size size) {
    for (final r in ripples) {
      final t = r.controller.value;
      final radius = (size.longestSide * 0.28) * t;
      final fill = Paint()
        ..color = AppColors.textWhite.withOpacity(0.08 * (1 - t))
        ..style = PaintingStyle.fill;
      final stroke = Paint()
        ..color = AppColors.textWhite.withOpacity(0.25 * (1 - t))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(r.position, radius, fill);
      canvas.drawCircle(r.position, radius, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) =>
      oldDelegate.ripples != ripples;
}
