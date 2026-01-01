part of email_confirmation_screen;

// Data elements for email confirmation screen
const int resendCountdownDuration = 60;

const String confirmationEmailSentMessage = 'Confirmation email sent successfully!';
const String emailNotConfirmedMessage =
    'Email not yet confirmed. Please check your email and click the confirmation link.';
const String unableToCheckStatusMessage = 'Unable to check verification status. Please try again.';
const String userNotFoundMessage = 'User account not found. Please sign up again.';
const String rateLimitMessage = 'Too many requests. Please wait before trying again.';
const String emailServiceUnavailableMessage = 'Email service temporarily unavailable. Please try again later.';
const String failedToResendMessage = 'Failed to resend email.';
