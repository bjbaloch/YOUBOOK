part of login_screen;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

Widget _buildLoginUI(_LoginScreenState state) {
  final size = MediaQuery.of(state.context).size;

  return Scaffold(
    backgroundColor: AppColors.lightSeaGreen,
    body: Stack(
      children: [
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background.withOpacity(0.06),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.12,
          left: -50,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentOrange.withOpacity(0.08),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          right: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.background.withOpacity(0.04),
            ),
          ),
        ),

        SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: state._formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: size.height * 0.07),

                      // Logo + brand
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.directions_bus_rounded,
                                size: 48,
                                color: AppColors.lightSeaGreen,
                              ),
                            ),
                            const SizedBox(height: 20),
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                ),
                                children: [
                                  TextSpan(text: 'Y', style: TextStyle(color: Colors.white)),
                                  TextSpan(text: 'O', style: TextStyle(color: AppColors.logoYellow)),
                                  TextSpan(text: 'U', style: TextStyle(color: Colors.white)),
                                  TextSpan(text: 'B', style: TextStyle(color: Colors.white)),
                                  TextSpan(text: 'O', style: TextStyle(color: AppColors.logoYellow)),
                                  TextSpan(text: 'O', style: TextStyle(color: AppColors.logoYellow)),
                                  TextSpan(text: 'K', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.05),

                      // Card
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Welcome Back',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.lightSeaGreen,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sign in to continue as Manager or Driver',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textBlack54,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            const SizedBox(height: 28),

                            _buildField(
                              controller: state._emailController,
                              focusNode: state._emailFN,
                              label: 'Email',
                              hint: 'Enter your email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              context: state.context,
                              hasError: !state._isEmailValid &&
                                  state._emailController.text.isNotEmpty,
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Enter email';
                                if (!emailRegex.hasMatch(value)) return 'Enter valid email';
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            StatefulBuilder(
                              builder: (context, setLocalState) => _buildField(
                                controller: state._passwordController,
                                label: 'Password',
                                hint: 'Enter your password',
                                icon: Icons.lock_outline_rounded,
                                obscureText: !state._isPasswordVisible,
                                context: state.context,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    state._isPasswordVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: AppColors.hintGrey,
                                    size: 20,
                                  ),
                                  onPressed: () => setLocalState(() {
                                    state._isPasswordVisible = !state._isPasswordVisible;
                                  }),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Enter password';
                                  return null;
                                },
                              ),
                            ),

                            const SizedBox(height: 10),

                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  ForgetPasswordPopup.show(
                                    state.context,
                                    initialEmail: state._emailController.text.trim().isNotEmpty
                                        ? state._emailController.text.trim()
                                        : null,
                                  );
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: AppColors.accentOrange,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: state._isLoading ? null : state._handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lightSeaGreen,
                                  disabledBackgroundColor: AppColors.lightSeaGreen.withOpacity(0.6),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: state._isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: AppColors.lightSeaGreen.withOpacity(0.15),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'or',
                                    style: TextStyle(
                                      color: AppColors.textBlack54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: AppColors.lightSeaGreen.withOpacity(0.15),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: AppColors.textBlack54,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => AppRouter.push(state.context, const SignupScreen()),
                                  child: const Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: AppColors.accentOrange,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.05),

                      Center(
                        child: Text(
                          'YouBook.com — Multi-Service Booking Platform',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildField({
  required TextEditingController controller,
  required String label,
  required String hint,
  required IconData icon,
  required BuildContext context,
  required String? Function(String?) validator,
  FocusNode? focusNode,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
  bool hasError = false,
  Widget? suffixIcon,
}) {
  final borderColor = hasError ? AppColors.red : AppColors.lightSeaGreen.withOpacity(0.3);
  final focusedColor = hasError ? AppColors.red : AppColors.lightSeaGreen;

  return TextFormField(
    controller: controller,
    focusNode: focusNode,
    obscureText: obscureText,
    keyboardType: keyboardType,
    cursorColor: AppColors.lightSeaGreen,
    cursorWidth: 2,
    cursorRadius: const Radius.circular(2),
    style: const TextStyle(
      color: AppColors.textBlack,
      fontSize: 15,
      fontWeight: FontWeight.w500,
    ),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.hintGrey, fontSize: 14),
      labelStyle: const TextStyle(color: AppColors.textBlack54, fontSize: 14),
      floatingLabelStyle: const TextStyle(
        color: AppColors.lightSeaGreen,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: AppColors.lightSeaGreen, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.background,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: focusedColor, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.red, width: 1.8),
      ),
      errorStyle: const TextStyle(color: AppColors.red, fontSize: 12),
    ),
    validator: validator,
  );
}
