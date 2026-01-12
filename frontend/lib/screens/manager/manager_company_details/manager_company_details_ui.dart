part of manager_company_details_screen;

Widget _buildManagerCompanyDetailsUI(_ManagerCompanyDetailsScreenState state) {
  return Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.lightSeaGreen,
      elevation: 0,
      toolbarHeight: 45.0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: const Text(
        'Add Business Details',
        style: TextStyle(
          color: AppColors.background,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.background),
    ),
    body: Form(
      key: state._formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Information Card
            _buildSectionCard(
              '1️⃣ Business Information',
              'These details help YouBook to confirm that your Business is real and currently operating in Pakistan.',
              [
                _buildTextField(
                  state.context,
                  'Business Name',
                  state._companyNameController,
                  'e.g: Al Basit Bus / Van Service',
                  icon: Icons.business,
                ),
                _buildDropdownField(
                  state.context,
                  'Business Type',
                  state._selectedBusinessType,
                  _businessTypes,
                  (value) {
                    state.setState(() => state._selectedBusinessType = value);
                  },
                ),
                _buildDropdownField(
                  state.context,
                  'Business Status',
                  state._selectedBusinessStatus,
                  _businessStatuses,
                  (value) {
                    state.setState(() => state._selectedBusinessStatus = value);
                  },
                ),
                _buildTextField(
                  state.context,
                  'Year Business Started',
                  state._businessStartYearController,
                  'e.g: 2005',
                  icon: Icons.calendar_today,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Business Registration Details Card
            _buildSectionCard(
              '2️⃣ Business Registration Details',
              'If your business is not officially registered, you can still apply, but approval may take more time.',
              [
                _buildTextField(
                  state.context,
                  'Registered Business Name',
                  state._registeredBusinessNameController,
                  '(If different from company name)',
                  icon: Icons.business_center,
                ),
                _buildDropdownField(
                  state.context,
                  'Business Registered With',
                  state._selectedRegistrationAuthority,
                  _registrationAuthorities,
                  (value) {
                    state.setState(() => state._selectedRegistrationAuthority = value);
                  },
                ),
                _buildTextField(
                  state.context,
                  'Registration / Trade License Number',
                  state._registrationNumberController,
                  'Enter official number if available',
                  icon: Icons.numbers,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Office Address Card
            _buildSectionCard('3️⃣ Office Address', '', [
              _buildTextField(
                state.context,
                'Office Address',
                state._officeAddressController,
                'Street, area, building name',
                icon: Icons.location_on,
              ),
              _buildTextField(
                state.context,
                'City',
                state._cityController,
                null,
                icon: Icons.location_city,
              ),
              _buildTextField(
                state.context,
                'Province',
                state._provinceController,
                null,
                icon: Icons.map,
              ),
              _buildTextField(
                state.context,
                'Country',
                state._countryController,
                null,
                enabled: false,
                icon: Icons.flag,
              ),
            ]),

            const SizedBox(height: 10),

            // Operating Information Card
            _buildSectionCard('4️⃣ Operating Information', '', [
              _buildDropdownField(
                state.context,
                'Main Service Type',
                state._selectedServiceType,
                _serviceTypes,
                (value) {
                  state.setState(() => state._selectedServiceType = value);
                },
              ),
            ]),

            const SizedBox(height: 10),

            // Tax Information Card
            _buildSectionCard('5️⃣ Tax Information (Optional)', '', [
              _buildTextField(
                state.context,
                'NTN (National Tax Number)',
                state._ntnController,
                null,
                required: false,
                icon: Icons.account_balance,
              ),
              _buildDropdownField(
                state.context,
                'Tax Registered?',
                state._selectedTaxRegistered,
                _taxOptions,
                (value) {
                  state.setState(() => state._selectedTaxRegistered = value);
                },
                required: false,
              ),
            ]),

            const SizedBox(height: 10),

            // Company Owner Details Card
            _buildSectionCard(
              '6️⃣ Business Owner Details (MANDATORY)',
              'This helps us confirm the real owner of the business.\n\nCNIC details are kept secure and used only for verification.',
              [
                _buildTextField(
                  state.context,
                  'Business Owner Full Name',
                  state._ownerNameController,
                  null,
                  icon: Icons.person,
                ),
                _buildTextField(
                  state.context,
                  'Owner CNIC Number',
                  state._ownerCnicController,
                  null,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  icon: Icons.credit_card,
                ),
                _buildFileUploadField(
                  state.context,
                  'Owner CNIC Front Photo',
                  state._cnicFrontPhoto,
                  () => state._pickImage(true),
                  isLoading: state._isPickingFrontImage,
                ),
                _buildFileUploadField(
                  state.context,
                  'Owner CNIC Back Photo',
                  state._cnicBackPhoto,
                  () => state._pickImage(false),
                  isLoading: state._isPickingBackImage,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Company Documents Upload Card
            _buildSectionCard(
              '7️⃣ Business Documents Upload',
              'Please upload clear photos or PDF files:',
              [
                _buildFileUploadField(
                  state.context,
                  'Business Registration or Trade License\n(SECP / Local Trade / Union document)',
                  state._businessRegistrationDocument,
                  state._pickDocument,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Confirmation & Agreement Card
            _buildSectionCard('🔒 Confirmation & Agreement', '', [
              _buildCheckboxField(
                'I confirm that all the information and documents I have provided are true and correct.',
                state._confirmInformation,
                (value) =>
                    state.setState(() => state._confirmInformation = value ?? false),
              ),
              _buildCheckboxField(
                'I understand that if any information or document is found to be false or incorrect, my Business will not be approved or may be removed from YouBook.',
                state._understandConsequences,
                (value) =>
                    state.setState(() => state._understandConsequences = value ?? false),
              ),
            ]),

            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: state._isSubmitting ? null : state._submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: state._isSubmitting
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.lightSeaGreen,
                        ),
                      )
                    : const Text(
                        'Submit Details',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textWhite,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  );
}

Widget _buildSectionCard(
  String title,
  String subtitle,
  List<Widget> children,
) {
  return Card(
    color: AppColors.lightSeaGreen,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.background,
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.background.withOpacity(0.8),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    ),
  );
}

Widget _buildTextField(
  BuildContext context,
  String label,
  TextEditingController controller,
  String? hint, {
  bool required = true,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  bool enabled = true,
  IconData? icon,
}) {
  final cs = Theme.of(context).colorScheme;

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      cursorColor: cs.secondary,
      cursorWidth: 2,
      cursorRadius: const Radius.circular(2),
      style: TextStyle(color: AppColors.background),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.background.withOpacity(0.85))
            : null,
        labelText: required ? '$label *' : label,
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.background.withOpacity(0.6)),
        labelStyle: TextStyle(color: AppColors.background),
        floatingLabelStyle: TextStyle(
          color: AppColors.background,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: AppColors.transparent,
        errorMaxLines: 2,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.accentOrange),
        ),
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '${label.replaceAll(' *', '')} is required';
              }
              // Special validation for CNIC field
              if (label.contains('CNIC')) {
                String digitsOnly = value.replaceAll('-', '');
                if (digitsOnly.length != 13) {
                  return 'CNIC must be exactly 13 digits';
                }
                if (!RegExp(r'^\d{5}-\d{7}-\d{1}$').hasMatch(value)) {
                  return 'Invalid CNIC format. Use XXXXX-XXXXXXX-X';
                }
              }
              return null;
            }
          : null,
      onChanged: (value) {
        if (label.contains('CNIC')) {
          _formatCnic(value!, controller);
        }
      },
    ),
  );
}

Widget _buildDropdownField(
  BuildContext context,
  String label,
  String? value,
  List<String> options,
  Function(String?) onChanged, {
  bool required = true,
}) {
  final cs = Theme.of(context).colorScheme;

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      value: value,
      menuMaxHeight: 300,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintStyle: TextStyle(color: AppColors.background.withOpacity(0.6)),
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
          borderRadius: BorderRadius.circular(30),
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
      dropdownColor: AppColors.lightSeaGreen,
      style: TextStyle(color: AppColors.background),
      items: options.map((option) {
        return DropdownMenuItem(
          value: option,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 96,
            ),
            child: Text(
              option,
              style: TextStyle(color: AppColors.background),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Please select ${label.replaceAll(' *', '')}';
              }
              return null;
              }
          : null,
    ),
  );
}

Widget _buildFileUploadField(
  BuildContext context,
  String label,
  File? file,
  VoidCallback onTap, {
  bool isLoading = false,
}) {
  final cs = Theme.of(context).colorScheme;

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: InkWell(
      onTap: isLoading ? null : onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: '$label *',
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
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: AppColors.accentOrange),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: cs.secondary, width: 2),
          ),
        ),
        child: Row(
          children: [
            isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accentOrange,
                    ),
                  )
                : Icon(
                    file != null ? Icons.check_circle : Icons.upload_file,
                    color: file != null
                        ? AppColors.green
                        : AppColors.background.withOpacity(0.85),
                    size: 20,
                  ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isLoading
                    ? 'Processing image...'
                    : file != null
                    ? 'File selected: ${file.path.split('/').last}'
                    : 'Tap to select file',
                style: TextStyle(color: AppColors.background, fontSize: 14),
              ),
            ),
            if (!isLoading)
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.background.withOpacity(0.6),
                size: 16,
              ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildCheckboxField(
  String label,
  bool value,
  Function(bool?) onChanged,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.green,
          checkColor: AppColors.textWhite,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.background, fontSize: 14),
          ),
        ),
      ],
    ),
  );
}
