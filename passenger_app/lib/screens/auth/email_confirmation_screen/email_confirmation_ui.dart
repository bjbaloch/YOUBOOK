 part of email_confirmation_screen;

class EmailConfirmationScreen extends StatefulWidget {
  final String email;
  final String role;
  final String? companyName;
  final String? credentialDetails;

  const EmailConfirmationScreen({
    super.key,
    required this.email,
    required this.role,
    this.companyName,
    this.credentialDetails,
  });

  @override
  State<EmailConfirmationScreen> createState() =>
      _EmailConfirmationScreenState();
}

Widget _buildEmailConfirmationUI(_EmailConfirmationScreenState state, EmailConfirmationScreen widget) {
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
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: "Check Your\n",
                    style: TextStyle(color: AppColors.background),
                  ),
                  TextSpan(
                    text: "Email",
                    style: TextStyle(color: AppColors.logoYellow),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Subtitle
            Text(
              'We sent a confirmation link to',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.background.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Email address
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentOrange),
              ),
              child: Text(
                widget.email,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.background,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            // Instruction text
            Text(
              'Click the link in the email to verify your account and start using YOUBOOK.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.background.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Status message
            if (state._message != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: state._message!.contains('successfully')
                      ? AppColors.circleGreen
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: state._message!.contains('successfully')
                        ? AppColors.circleGreen
                        : AppColors.accentOrange,
                  ),
                ),
                child: Text(
                  state._message!,
                  style: TextStyle(
                    color: state._message!.contains('successfully')
                        ? AppColors.background
                        : AppColors.accentOrange,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            if (state._message != null) const SizedBox(height: 20),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: state._isLoading ? null : state._checkVerificationStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: state._isLoading
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.lightSeaGreen,
                        ),
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textWhite,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 1),

            // Resend email button
            TextButton(
              onPressed: (state._isResending || state._resendCountdown > 0)
                  ? null
                  : state._resendConfirmationEmail,
              child: Text(
                state._resendCountdown > 0
                    ? 'Resend email in ${state._resendCountdown}s'
                    : state._isResending
                    ? 'Sending...'
                    : 'Didn\'t receive the email? Resend',
                style: TextStyle(
                  color: (state._isResending || state._resendCountdown > 0)
                      ? AppColors.background
                      : AppColors.accentOrange,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 20),

            // Back to login
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  state.context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Text(
                'Back to Login',
                style: TextStyle(color: AppColors.accentOrange, fontSize: 14),
              ),
            ),

            const SizedBox(height: 2),

            // Help text
            Text(
              'or Check your spam folder if you don\'t see the email in your inbox.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.background.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
