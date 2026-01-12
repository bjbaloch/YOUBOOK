import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SuccessDialog extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final double? iconSize;

  const SuccessDialog({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.check,
    this.iconBackgroundColor = AppColors.circleGreen,
    this.iconColor = AppColors.textOnCircle,
    this.iconSize = 60.0,
  });

  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    IconData? icon,
    Color? iconBackgroundColor,
    Color? iconColor,
    double? iconSize,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => SuccessDialog(
        message: message,
        title: title,
        icon: icon,
        iconBackgroundColor: iconBackgroundColor,
        iconColor: iconColor,
        iconSize: iconSize,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Dialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor,
              ),
            ),
            if (title != null) ...[
              const SizedBox(height: 16),
              Text(
                title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            SizedBox(height: title != null ? 8 : 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurface, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
