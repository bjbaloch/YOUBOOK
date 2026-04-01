part of email_confirmation_screen;

Widget _buildEmailConfirmationUI(
  _EmailConfirmationScreenState state,
  EmailConfirmationScreen widget,
) {
  return Scaffold(
    backgroundColor: AppColors.lightSeaGreen,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Email icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.email_outlined,
                size: 50,
                color: AppColors.accentOrange,
              ),
            ),

            const SizedBox(height: 30),

            // Title
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                children: const [
                  TextSpan(
                    text: "Verify Your Email\nto Continue",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Message
            Text(
              'A confirmation email has been sent to:',
              style: TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Email address
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accentOrange, width: 1),
              ),
              child: Text(
                widget.email,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // Instructions
            Text(
              'Click the link in the email to verify your account.\nCheck your spam folder if you don\'t see it.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // Message display
            if (state._message != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accentOrange, width: 1),
                ),
                child: Text(
                  state._message!,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),

            const Spacer(),

            // Resend button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state._isResending || state._resendCountdown > 0
                    ? null
                    : state._resendConfirmationEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  disabledBackgroundColor: AppColors.accentOrange.withOpacity(
                    0.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: state._isResending
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        state._resendCountdown > 0
                            ? 'Resend Email (${state._resendCountdown}s)'
                            : 'Resend Confirmation Email',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            // Back to login link
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  state.context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Text(
                'Back to Login',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.accentOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
