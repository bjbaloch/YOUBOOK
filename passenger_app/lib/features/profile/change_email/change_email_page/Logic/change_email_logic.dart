import 'package:youbook/features/profile/change_email/change_email_page/Data/change_email_data.dart';

class ChangeEmailLogic {
  final ChangeEmailData data = ChangeEmailData();

  /// Validates email and sets error message if invalid
  void validateEmail(String value) {
    final input = value.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (input.isEmpty) {
      data.error = "Email is required";
    } else if (!emailRegex.hasMatch(input)) {
      data.error = "Invalid email format";
    } else {
      data.error = null;
      data.email = input;
    }
  }

  bool get isValid => data.error == null && data.email.isNotEmpty;
}
