part of password_success_popup;

class SuccessPopup extends StatefulWidget {
  const SuccessPopup({super.key});

  @override
  State<SuccessPopup> createState() => _SuccessPopupState();
}

Widget _buildPasswordSuccessUI(_SuccessPopupState state) {
  final cs = Theme.of(state.context).colorScheme;

  // Responsive calculations
  final screenSize = MediaQuery.of(state.context).size;
  final screenWidth = screenSize.width;
  final screenHeight = screenSize.height;

  // Adaptive dialog width: 90% of screen width, max 400px
  final dialogWidth = screenWidth < 400 ? screenWidth * 0.9 : 400.0;

  // Adaptive padding: scales from 16px (small) to 24px (large)
  final padding = screenWidth < 400 ? 16.0 : (screenWidth < 600 ? 20.0 : 24.0);

  // Adaptive icon size: scales with screen size
  final iconSize = screenWidth < 400 ? 40.0 : 48.0;

  // Adaptive text sizes
  final titleSize = screenWidth < 400 ? 20.0 : 24.0;
  final subtitleSize = screenWidth < 400 ? 14.0 : 16.0;
  final buttonSize = screenWidth < 400 ? 14.0 : 16.0;

  return Dialog(
    backgroundColor: AppColors.background,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    elevation: 8,
    child: Container(
      width: dialogWidth,
      padding: EdgeInsets.all(padding),
      constraints: BoxConstraints(
        maxWidth: dialogWidth,
        maxHeight: screenHeight * 0.8, // Prevent overflow on very small screens
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Header (styled like logout popup)
            Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: AppColors.lightSeaGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: iconSize,
                color: AppColors.lightSeaGreen,
              ),
            ),
            SizedBox(height: padding),

            // Title
            Text(
              'Success!',
              style: TextStyle(
                color: AppColors.lightSeaGreen,
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: padding * 0.5),

            // Subtitle
            Text(
              'Your password has been changed successfully',
              style: TextStyle(
                color: AppColors.lightSeaGreen.withOpacity(0.8),
                fontSize: subtitleSize,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: padding * 1.3),

            // Done button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state._goToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Done",
                  style: TextStyle(
                    fontSize: buttonSize,
                    color: Theme.of(state.context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Helper to open SuccessPopup:
/// - Closes any other open popups behind it
/// - Uses professional showGeneralDialog with logout-style animations
Future<void> showSuccessPopup(BuildContext context) async {
  // Close all PopupRoutes (dialogs, bottom sheets) before showing this one
  Navigator.of(
    context,
    rootNavigator: true,
  ).popUntil((route) => route is PageRoute);

  // Show success popup with professional styling
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: '',
    barrierColor: AppColors.overlay,
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final scaleAnimation = Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut));

      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

      return ScaleTransition(
        scale: scaleAnimation,
        child: FadeTransition(opacity: fadeAnimation, child: child),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return const SuccessPopup();
    },
  );
}
