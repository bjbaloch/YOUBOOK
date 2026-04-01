part of signup_screen;

Widget _buildSignupUI(_SignupScreenState state) {
  final size = MediaQuery.of(state.context).size;

  return Scaffold(
    backgroundColor: AppColors.lightSeaGreen,
    body: Stack(
      children: [
        // Decorative background circles
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
          bottom: -100,
          left: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentOrange.withOpacity(0.07),
            ),
          ),
        ),

        SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: state._formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Centered header
                    Center(
                      child: Column(
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Y',
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextSpan(
                                  text: 'O',
                                  style: TextStyle(color: AppColors.logoYellow),
                                ),
                                TextSpan(
                                  text: 'U',
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextSpan(
                                  text: 'B',
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextSpan(
                                  text: 'O',
                                  style: TextStyle(color: AppColors.logoYellow),
                                ),
                                TextSpan(
                                  text: 'O',
                                  style: TextStyle(color: AppColors.logoYellow),
                                ),
                                TextSpan(
                                  text: 'K',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Create your account',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // White card
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
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Role selector
                          const _SectionLabel(text: 'Select Role'),
                          const SizedBox(height: 10),
                          _RoleSelector(state: state),

                          const SizedBox(height: 20),
                          const _SectionLabel(text: 'Personal Information'),
                          const SizedBox(height: 12),

                          // First & Last name row
                          Row(
                            children: [
                              Expanded(
                                child: _SignupField(
                                  controller: state._firstNameController,
                                  label: 'First Name',
                                  hint: 'John',
                                  icon: Icons.person_outline_rounded,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Enter first name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SignupField(
                                  controller: state._lastNameController,
                                  label: 'Last Name',
                                  hint: 'Doe',
                                  icon: Icons.person_outline_rounded,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty) {
                                      return 'Enter last name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Email
                          _SignupField(
                            controller: state._emailController,
                            focusNode: state._emailFN,
                            label: 'Email',
                            hint: 'you@example.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            hasError: !state._isEmailValid &&
                                state._emailController.text.isNotEmpty,
                            serverError: state._emailServerError,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter email';
                              }
                              if (!emailRegex.hasMatch(_canonicalEmail(v))) {
                                return 'Enter a valid email';
                              }
                              if (state._emailServerError != null) {
                                return state._emailServerError;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          // Phone
                          _SignupField(
                            controller: state._phoneController,
                            focusNode: state._phoneFN,
                            label: 'Phone Number',
                            hint: '03XXXXXXXXX',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            hasError: !state._isPhoneValid &&
                                state._phoneController.text.isNotEmpty,
                            serverError: state._phoneServerError,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter phone number';
                              }
                              if (!phoneRegex.hasMatch(v)) {
                                return 'Enter a valid phone number';
                              }
                              if (state._phoneServerError != null) {
                                return state._phoneServerError;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 14),

                          // CNIC
                          _SignupField(
                            controller: state._cnicController,
                            focusNode: state._cnicFN,
                            label: 'CNIC (13 digits)',
                            hint: 'XXXXX-XXXXXXX-X',
                            icon: Icons.credit_card_outlined,
                            keyboardType: TextInputType.number,
                            hasError: !state._isCnicValid &&
                                state._cnicController.text.isNotEmpty,
                            serverError: state._cnicServerError,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Enter CNIC';
                              }
                              if (v.replaceAll('-', '').length != 13) {
                                return 'CNIC must be 13 digits';
                              }
                              if (state._cnicServerError != null) {
                                return state._cnicServerError;
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),
                          const _SectionLabel(text: 'Security'),
                          const SizedBox(height: 12),

                          // Password
                          StatefulBuilder(
                            builder: (ctx, setLocal) => _SignupField(
                              controller: state._passwordController,
                              label: 'Password',
                              hint: 'Min 8 chars, A-Z, 0-9, !@#',
                              icon: Icons.lock_outline_rounded,
                              obscureText: !state._isPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  state._isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.hintGrey,
                                  size: 20,
                                ),
                                onPressed: () => setLocal(() {
                                  state._isPasswordVisible =
                                      !state._isPasswordVisible;
                                }),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Enter password';
                                }
                                if (!passwordRegex.hasMatch(v)) {
                                  return 'Min 8 chars with A-Z, a-z, 0-9, special char';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Confirm Password
                          StatefulBuilder(
                            builder: (ctx, setLocal) => _SignupField(
                              controller: state._confirmPasswordController,
                              label: 'Confirm Password',
                              hint: 'Re-enter password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: !state._isConfirmPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  state._isConfirmPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.hintGrey,
                                  size: 20,
                                ),
                                onPressed: () => setLocal(() {
                                  state._isConfirmPasswordVisible =
                                      !state._isConfirmPasswordVisible;
                                }),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Confirm your password';
                                }
                                if (v != state._passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Terms text
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textBlack54,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'By signing up you are agree to the ',
                                  ),
                                  TextSpan(
                                    text: 'terms and conditions',
                                    style: TextStyle(
                                      color: AppColors.lightSeaGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(text: ' of '),
                                  TextSpan(
                                    text: 'YouBook',
                                    style: TextStyle(
                                      color: AppColors.accentOrange,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Sign Up button
                          SizedBox(
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  state._isLoading
                                      ? null
                                      : state._handleSignup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightSeaGreen,
                                disabledBackgroundColor:
                                    AppColors.lightSeaGreen.withOpacity(0.5),
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Create Account',
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

                          // Sign in link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: AppColors.textBlack54,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(state.context).pop(),
                                child: const Text(
                                  'Sign In',
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

                    const SizedBox(height: 24),

                    Center(
                      child: Text(
                        'YouBook.com — Multi-Service Booking Platform',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
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
      ],
    ),
  );
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.lightSeaGreen,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final _SignupScreenState state;
  const _RoleSelector({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoleTile(
          label: 'Manager',
          icon: Icons.business_center_outlined,
          value: AppConstants.roleManager,
          groupValue: state._selectedRole,
          onTap: () => state._onRoleChanged(AppConstants.roleManager),
        ),
        const SizedBox(width: 12),
        _RoleTile(
          label: 'Driver',
          icon: Icons.directions_car_outlined,
          value: AppConstants.roleDriver,
          groupValue: state._selectedRole,
          onTap: () => state._onRoleChanged(AppConstants.roleDriver),
        ),
      ],
    );
  }
}

class _RoleTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String groupValue;
  final VoidCallback onTap;

  const _RoleTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.lightSeaGreen
                : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.lightSeaGreen
                  : AppColors.lightSeaGreen.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : AppColors.textBlack54,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textBlack54,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignupField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool hasError;
  final String? serverError;
  final Widget? suffixIcon;
  final String? Function(String?) validator;

  const _SignupField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.hasError = false,
    this.serverError = null,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = (hasError || serverError != null)
        ? AppColors.red
        : AppColors.lightSeaGreen.withOpacity(0.3);
    final focusedColor =
        (hasError || serverError != null) ? AppColors.red : AppColors.lightSeaGreen;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      cursorColor: AppColors.lightSeaGreen,
      cursorWidth: 2,
      style: const TextStyle(
        color: AppColors.textBlack,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.hintGrey, fontSize: 13),
        labelStyle: TextStyle(color: AppColors.textBlack54, fontSize: 13),
        floatingLabelStyle: TextStyle(
          color: AppColors.lightSeaGreen,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        prefixIcon: Icon(icon, color: AppColors.lightSeaGreen, size: 19),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.background,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        errorStyle: const TextStyle(color: AppColors.red, fontSize: 11),
      ),
      validator: validator,
    );
  }
}
