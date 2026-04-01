part of login_screen;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

Widget _buildLoginUI(_LoginScreenState state) {
  final authProvider = Provider.of<AuthProvider>(state.context);

  return Scaffold(
    backgroundColor: AppColors.lightSeaGreen,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: state._formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              // Card for the overall content
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(
                    0.1,
                  ), // Card background from app color (assuming AppColors.background is white) with transparency
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors
                        .accentOrange, // Border color accentOrange
                    width: 2.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome text with YOUBOOK styling - White text like signup
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        children: const [
                          TextSpan(
                            text: "Welcome Back to\nY",
                            style: TextStyle(color: AppColors.background),
                          ),
                          TextSpan(
                            text: "O",
                            style: TextStyle(color: AppColors.logoYellow),
                          ),
                          TextSpan(
                            text: "U",
                            style: TextStyle(color: AppColors.background),
                          ),
                          TextSpan(
                            text: "B",
                            style: TextStyle(color: AppColors.background),
                          ),
                          TextSpan(
                            text: "O",
                            style: TextStyle(color: AppColors.logoYellow),
                          ),
                          TextSpan(
                            text: "O",
                            style: TextStyle(color: AppColors.logoYellow),
                          ),
                          TextSpan(
                            text: "K",
                            style: TextStyle(color: AppColors.background),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to continue',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.background.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    // Email field - styled like signup fields with live validation
                    TextFormField(
                      controller: state._emailController,
                      focusNode: state._emailFN,
                      cursorColor: Theme.of(
                        state.context,
                      ).colorScheme.secondary,
                      cursorWidth: 2,
                      cursorRadius: const Radius.circular(2),
                      style: TextStyle(color: AppColors.background),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.email,
                          color: AppColors.background.withOpacity(0.85),
                        ),
                        labelText: "Email",
                        labelStyle: TextStyle(
                          color: AppColors.background,
                        ),
                        floatingLabelStyle: TextStyle(
                          color: AppColors.background,
                          fontWeight: FontWeight.w600,
                        ),
                        filled: true,
                        fillColor: AppColors.transparent,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            color:
                                (!state._isEmailValid &&
                                    state._emailController.text.isNotEmpty)
                                ? AppColors.red
                                : AppColors.accentOrange,
                          ),
                        ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(30),
                            ),
                            borderSide: BorderSide(
                              color:
                                  (!state._isEmailValid &&
                                      state._emailController.text.isNotEmpty)
                                  ? AppColors.red
                                  : Theme.of(state.context).colorScheme.secondary,
                              width: 2,
                            ),
                          ),
                        errorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                          borderSide: BorderSide(color: AppColors.red),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                          borderSide: BorderSide(
                            color: AppColors.red,
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter email';
                        }
                        if (!emailRegex.hasMatch(value)) {
                          return 'Enter valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    // Password field - styled like signup fields
                    StatefulBuilder(
                      builder: (context, setState) => TextFormField(
                        controller: state._passwordController,
                        obscureText: !state._isPasswordVisible,
                        cursorColor: Theme.of(
                          state.context,
                        ).colorScheme.secondary,
                        cursorWidth: 2,
                        cursorRadius: const Radius.circular(2),
                        style: TextStyle(color: AppColors.background),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            color: AppColors.background.withOpacity(0.85),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              state._isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.background.withOpacity(
                                0.75,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                state._isPasswordVisible = !state._isPasswordVisible;
                              });
                            },
                          ),
                          labelText: "Password",
                          labelStyle: TextStyle(
                            color: AppColors.background,
                          ),
                          floatingLabelStyle: TextStyle(
                            color: AppColors.background,
                            fontWeight: FontWeight.w600,
                          ),
                          filled: true,
                          fillColor: AppColors.transparent,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(30),
                            ),
                            borderSide: BorderSide(
                              color: AppColors.accentOrange,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(30),
                            ),
                            borderSide: BorderSide(
                              color: Theme.of(
                                state.context,
                              ).colorScheme.secondary,
                              width: 2,
                            ),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                            borderSide: BorderSide(color: AppColors.red),
                          ),
                          focusedErrorBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                            borderSide: BorderSide(
                              color: AppColors.red,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter password';
                          }
                          // Removed regex validation, just check if password is not empty
                          // Invalid password message will come from server-side validation
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 10),
                    // Forgot password link - right aligned
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ForgetPasswordPopup.show(
                              state.context,
                              initialEmail:
                                  state._emailController.text.trim().isNotEmpty
                                  ? state._emailController.text.trim()
                                  : null,
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: AppColors.accentOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Center the login button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: authProvider.isLoading
                                ? null
                                : state._handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: authProvider.isLoading
                                ? SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.background,
                                    ),
                                  )
                                : Text(
                                    "Sign In",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(
                                        state.context,
                                      ).colorScheme.onPrimary,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Sign up link - matching signup page style
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: AppColors.background),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              state.context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              color: AppColors.accentOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
