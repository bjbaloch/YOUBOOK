import 'package:flutter/material.dart';
import 'package:manager_driver_app/core/theme/app_colors.dart';

enum SnackBarType { success, error, warning, other }

class SnackBarUtils {
  static void showSnackBar(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.other,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final cfg = _SnackConfig.from(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        duration: duration,
        content: _SnackBarContent(message: message, config: cfg),
      ),
    );
  }
}

// ── Config ────────────────────────────────────────────────────────────────────

class _SnackConfig {
  final Color bg;
  final Color border;
  final Color iconBg;
  final Color iconColor;
  final Color titleColor;
  final Color messageColor;
  final IconData icon;
  final String title;

  const _SnackConfig({
    required this.bg,
    required this.border,
    required this.iconBg,
    required this.iconColor,
    required this.titleColor,
    required this.messageColor,
    required this.icon,
    required this.title,
  });

  factory _SnackConfig.from(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const _SnackConfig(
          bg: AppColors.background,
          border: Color(0xFF86EFAC),
          iconBg: Color(0xFFDCFCE7),
          iconColor: Color(0xFF16A34A),
          titleColor: Color(0xFF15803D),
          messageColor: Color(0xFF166534),
          icon: Icons.check_circle_rounded,
          title: 'Success',
        );
      case SnackBarType.error:
        return const _SnackConfig(
          bg: AppColors.background,
          border: Color(0xFFFCA5A5),
          iconBg: Color(0xFFFFE4E6),
          iconColor: Color(0xFFDC2626),
          titleColor: Color(0xFFB91C1C),
          messageColor: Color(0xFF991B1B),
          icon: Icons.error_rounded,
          title: 'Error',
        );
      case SnackBarType.warning:
        return const _SnackConfig(
          bg: AppColors.background,
          border: Color(0xFFFCD34D),
          iconBg: Color(0xFFFEF3C7),
          iconColor: Color(0xFFD97706),
          titleColor: Color(0xFFB45309),
          messageColor: Color(0xFF92400E),
          icon: Icons.warning_rounded,
          title: 'Notice',
        );
      case SnackBarType.other:
        return const _SnackConfig(
          bg: AppColors.background,
          border: Color(0xFF7DD3FC),
          iconBg: Color(0xFFE0F2FE),
          iconColor: Color(0xFF0284C7),
          titleColor: Color(0xFF0369A1),
          messageColor: Color(0xFF075985),
          icon: Icons.info_rounded,
          title: 'Info',
        );
    }
  }
}

// ── Animated content widget ───────────────────────────────────────────────────

class _SnackBarContent extends StatefulWidget {
  final String message;
  final _SnackConfig config;

  const _SnackBarContent({required this.message, required this.config});

  @override
  State<_SnackBarContent> createState() => _SnackBarContentState();
}

class _SnackBarContentState extends State<_SnackBarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _slide = Tween<double>(
      begin: 40,
      end: 0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = widget.config;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _slide.value),
        child: Opacity(
          opacity: _fade.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: cfg.bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cfg.border, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: cfg.iconColor.withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cfg.iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cfg.icon, color: cfg.iconColor, size: 22),
                ),

                const SizedBox(width: 12),

                // Title + message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cfg.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: cfg.titleColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: cfg.messageColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Dismiss ✕
                GestureDetector(
                  onTap: () =>
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: cfg.iconBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: cfg.iconColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
