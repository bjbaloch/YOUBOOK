import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Enum for snackbar types
enum SnackBarType { success, error, other }

/// Internal snackbar data model
class _SnackBarData {
  final String message;
  final Color backgroundColor;
  final Duration duration;
  final Completer<void> completer;

  _SnackBarData(
    this.message,
    this.backgroundColor,
    this.duration,
    this.completer,
  );
}

class _TopSnackBar extends StatefulWidget {
  final _SnackBarData data;

  const _TopSnackBar(this.data);

  @override
  _TopSnackBarState createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<_TopSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _dismissTimer;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Schedule dismissal
    _dismissTimer = Timer(
      widget.data.duration - const Duration(milliseconds: 300),
      () {
        if (mounted && !_isDismissed) {
          _dismiss();
        }
      },
    );
  }

  void _dismiss() {
    if (_isDismissed) return;
    _isDismissed = true;

    _controller.reverse().then((_) {
      if (mounted) {
        SnackBarUtils._onSnackBarDismissed(widget.data);
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8),
        child: FadeTransition(
          opacity: _animation,
          child: Material(
            color: Colors.transparent,
            elevation: 3,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              constraints: const BoxConstraints(minWidth: 200, maxWidth: 400),
              decoration: BoxDecoration(
                color: widget.data.backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.data.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textWhite),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SnackBarUtils {
  static OverlayEntry? _currentOverlay;
  static final Queue<_SnackBarData> _queue = Queue<_SnackBarData>();
  static bool _isProcessing = false;

  /// Standardized snackbar utility for consistent display
  static void showSnackBar(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.other,
    Duration duration = const Duration(seconds: 4),
  }) {
    final Color backgroundColor;
    switch (type) {
      case SnackBarType.success:
        backgroundColor = AppColors.circleGreen;
        break;
      case SnackBarType.error:
        backgroundColor = AppColors.error;
        break;
      case SnackBarType.other:
        backgroundColor = AppColors.accentOrange;
        break;
    }

    final data = _SnackBarData(
      message,
      backgroundColor,
      duration,
      Completer<void>(),
    );
    _queue.add(data);
    _processQueue(context);
  }

  static void _processQueue(BuildContext context) {
    if (_isProcessing || _queue.isEmpty) return;

    _isProcessing = true;
    final data = _queue.removeFirst();

    try {
      final overlay = Overlay.of(context);
      if (overlay == null) {
        // Context might be invalid, complete and skip
        data.completer.complete();
        _isProcessing = false;
        _processQueue(context);
        return;
      }

      // Dismiss current snackbar if exists
      _currentOverlay?.remove();
      _currentOverlay = null;

      final overlayEntry = OverlayEntry(
        builder: (context) => _TopSnackBar(data),
      );

      overlay.insert(overlayEntry);
      _currentOverlay = overlayEntry;

      // Wait for this snackbar to complete
      data.completer.future.whenComplete(() {
        _isProcessing = false;
        // Process next in queue after a small delay
        Future.delayed(const Duration(milliseconds: 100), () {
          if (context.mounted) {
            _processQueue(context);
          }
        });
      });
    } catch (e) {
      // If insertion fails, complete and move to next
      data.completer.complete();
      _isProcessing = false;
      _processQueue(context);
    }
  }

  static void _onSnackBarDismissed(_SnackBarData data) {
    _currentOverlay?.remove();
    _currentOverlay = null;
    data.completer.complete();
  }

  /// Force dismiss all pending snackbars (useful for navigation)
  static void dismissAll() {
    _queue.clear();
    _currentOverlay?.remove();
    _currentOverlay = null;
    _isProcessing = false;
  }
}
