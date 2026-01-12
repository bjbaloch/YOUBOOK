part of signup_screen;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

Widget _buildSignupUI(_SignupScreenState state) {
  final cs = Theme.of(state.context).colorScheme;

  return Scaffold(
    backgroundColor: AppColors.background,
    body: SingleChildScrollView(
      child: Form(
        key: state._formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            // Green Header Section with YOUBOOK text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 40,
                horizontal: 24,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightSeaGreen,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // YOUBOOK text with special styling
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 28),
                      children: [
                        TextSpan(
                          text: "Y",
                          style: TextStyle(color: AppColors.background),
                        ),
                        const TextSpan(
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
                        const TextSpan(
                          text: "O",
                          style: TextStyle(color: AppColors.logoYellow),
                        ),
                        const TextSpan(
                          text: "O",
                          style: TextStyle(color: AppColors.logoYellow),
                        ),
                        TextSpan(
                          text: "K",
                          style: TextStyle(color: AppColors.background),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.background,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Create your account to get started",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.background,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Form Fields in Header
                  _buildTextField(
                    state: state,
                    icon: Icons.person,
                    hint: "Full Name",
                    controller: state._firstNameController,
                    validator: (val) => (val == null || val.isEmpty)
                        ? "Enter your full name"
                        : null,
                    borderColor: AppColors.accentOrange,
                  ),
                  const SizedBox(height: 10),

                  _buildTextField(
                    state: state,
                    icon: Icons.email,
                    hint: "Email",
                    controller: state._emailController,
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Enter email";
                      if (!emailRegex.hasMatch(val))
                        return "Enter valid email";
                      return null;
                    },
                    borderColor: (state._emailServerError != null || !state._isEmailValid)
                        ? AppColors.error
                        : AppColors.accentOrange,
                    serverError: state._emailServerError,
                    focusNode: state._emailFN,
                  ),
                  const SizedBox(height: 10),

                  _buildTextField(
                    state: state,
                    icon: Icons.phone,
                    hint: "Phone Number",
                    controller: state._phoneController,
                    validator: (val) {
                      if (val == null || val.isEmpty)
                        return "Enter phone number";
                      if (!phoneRegex.hasMatch(val))
                        return "Must be 11 digits starting with 03";
                      return null;
                    },
                    borderColor: (state._phoneServerError != null || !state._isPhoneValid)
                        ? AppColors.error
                        : AppColors.accentOrange,
                    serverError: state._phoneServerError,
                    focusNode: state._phoneFN,
                  ),
                  const SizedBox(height: 10),

                  _buildTextField(
                    state: state,
                    icon: Icons.badge,
                    hint: "CNIC",
                    controller: state._cnicController,
                    validator: (val) {
                      if (val == null || val.isEmpty) return "Enter CNIC";
                      if (val.length != 15)
                        return "Must be 13 digits (XXXXX-XXXXXXX-X)";
                      return null;
                    },
                    borderColor: (state._cnicServerError != null)
                        ? AppColors.error
                        : AppColors.accentOrange,
                    serverError: state._cnicServerError,
                    focusNode: state._cnicFN,
                  ),
                  const SizedBox(height: 10),

                  _buildPasswordField(state, "Password", true, state._passwordController, (
                    val,
                  ) {
                    if (val == null || val.isEmpty) return "Enter password";
                    if (!passwordRegex.hasMatch(val)) {
                      return "8+ chars, 1 upper, 1 lower, 1 number, 1 special";
                    }
                    return null;
                  }),
                  const SizedBox(height: 10),

                  _buildPasswordField(
                    state,
                    "Confirm Password",
                    false,
                    state._confirmPasswordController,
                    (val) {
                      if (val != state._passwordController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Role Selection Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: AppColors.lightSeaGreen,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Choose Account Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.background,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                state._onRoleChanged(AppConstants.rolePassenger),
                            child: Container(
                              height: 45,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    state._selectedRole ==
                                          AppConstants.rolePassenger
                                      ? AppColors.accentOrange.withOpacity(0.9)
                                      : AppColors.background.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color:
                                      state._selectedRole ==
                                          AppConstants.rolePassenger
                                      ? AppColors.accentOrange
                                      : AppColors.accentOrange,
                                  width:
                                      state._selectedRole ==
                                          AppConstants.rolePassenger
                                      ? 2
                                      : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color:
                                        state._selectedRole ==
                                            AppConstants.rolePassenger
                                        ? AppColors.textWhite
                                        : AppColors.background,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Passenger',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          state._selectedRole ==
                                              AppConstants.rolePassenger
                                          ? AppColors.textWhite
                                          : AppColors.background,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                state._onRoleChanged(AppConstants.roleManager),
                            child: Container(
                              height: 45,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    state._selectedRole == AppConstants.roleManager
                                      ? AppColors.accentOrange.withOpacity(0.9)
                                      : AppColors.background.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color:
                                      state._selectedRole ==
                                          AppConstants.roleManager
                                      ? AppColors.accentOrange
                                      : AppColors.accentOrange,
                                  width:
                                      state._selectedRole ==
                                          AppConstants.roleManager
                                      ? 2
                                      : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.business,
                                    color:
                                        state._selectedRole ==
                                            AppConstants.roleManager
                                        ? AppColors.textWhite
                                        : AppColors.background,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Manager',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          state._selectedRole ==
                                              AppConstants.roleManager
                                          ? AppColors.textWhite
                                          : AppColors.background,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Terms & Conditions Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "By signing up you agree to our Terms & Conditions & Privacy Policy",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onBackground.withOpacity(0.6),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Sign Up Button
            SizedBox(
              width: 200,
              height: 40,
              child: ElevatedButton(
                onPressed: state._isLoading ? null : state._handleSignup,
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
                    : Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 16, color: cs.onPrimary),
                      ),
              ),
            ),

            const SizedBox(height: 10),

            // Login Link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an Account? ",
                  style: TextStyle(color: cs.onBackground),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    state.context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(
                      color: AppColors.lightSeaGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}

Widget _buildTextField({
  required _SignupScreenState state,
  required IconData icon,
  required String hint,
  required TextEditingController controller,
  required String? Function(String?)? validator,
  Color borderColor = AppColors.accentOrange,
  String? serverError,
  FocusNode? focusNode,
}) {
  final cs = Theme.of(state.context).colorScheme;

  return TextFormField(
    focusNode: focusNode,
    controller: controller,
    validator: validator,
    cursorColor: cs.secondary,
    cursorWidth: 2,
    cursorRadius: const Radius.circular(2),
    style: TextStyle(color: AppColors.background),
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: AppColors.background.withOpacity(0.85)),
      labelText: hint,
      labelStyle: TextStyle(color: AppColors.background),
      floatingLabelStyle: TextStyle(
        color: AppColors.background,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: AppColors.transparent,
      errorText: serverError,
      errorMaxLines: 2,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        borderSide: BorderSide(color: cs.secondary, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
    ),
    keyboardType: (hint == "Phone Number" || hint == "CNIC")
        ? TextInputType.number
        : TextInputType.text,
    inputFormatters: (hint == "Phone Number" || hint == "CNIC")
        ? [FilteringTextInputFormatter.digitsOnly]
        : [],
  );
}

Widget _buildPasswordField(
  _SignupScreenState state,
  String hint,
  bool isPassword,
  TextEditingController controller,
  String? Function(String?)? validator,
) {
  final cs = Theme.of(state.context).colorScheme;

  return StatefulBuilder(
    builder: (context, setState) => TextFormField(
      controller: controller,
      obscureText: isPassword
          ? !state._isPasswordVisible
          : !state._isConfirmPasswordVisible,
      validator: validator,
      cursorColor: cs.secondary,
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
            isPassword
                ? (state._isPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off)
                : (state._isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
            color: AppColors.background.withOpacity(0.75),
          ),
          onPressed: () {
            setState(() {
              if (isPassword) {
                state._isPasswordVisible = !state._isPasswordVisible;
              } else {
                state._isConfirmPasswordVisible = !state._isConfirmPasswordVisible;
              }
            });
          },
        ),
        labelText: hint,
        labelStyle: TextStyle(color: AppColors.background),
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
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: AppColors.accentOrange),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: cs.secondary, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    ),
  );
}
