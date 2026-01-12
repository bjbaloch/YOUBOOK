class ServiceConfirmationData {
  static const Duration transitionDuration = Duration(milliseconds: 300);
  static const Duration loadingDelay = Duration(seconds: 3);
  static const Duration successPopupDelay = Duration(milliseconds: 120);

  static const double borderRadius = 12;

  static const String title = "Service Details Confirmation";
  static const String message =
      "Are you sure you provided the correct service information?";
}
