part of forget_password_popup;

// Data elements for forget password popup
const int cooldownSeconds = 90;

const String enterEmailMessage = "Enter the email address";
const String invalidEmailMessage = "Please enter a valid email address";
const String noInternetMessage = "No internet connection. Please check your network.";
const String codeSentMessage = "A 6-digit code has been sent to your email address.";
const String enterCodeMessage = "Please enter the code";
const String invalidCodeMessage = "Invalid or expired code. Please try again.";
const String codeLengthMessage = "Code must be 6 digits";
const String errorSendingMessage = "Error sending code. Please try again.";
const String invalidExpiredCodeMessage = "Invalid or expired code. Please try again.";

// Email regex for validation
final RegExp emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$');
