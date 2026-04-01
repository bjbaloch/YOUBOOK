part of manager_company_details_screen;

Widget _buildManagerCompanyDetailsUI(_ManagerCompanyDetailsScreenState state) {
  return Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.lightSeaGreen,
      elevation: 0,
      toolbarHeight: 56,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: const Text(
        'Add Business Details',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3),
        child: Container(
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.lightSeaGreen, AppColors.accentOrange],
            ),
          ),
        ),
      ),
    ),
    body: Form(
      key: state._formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            _buildHeaderBanner(),
            const SizedBox(height: 20),

            _buildSectionCard(
              step: 1,
              title: 'Business Information',
              subtitle:
                  'These details help YouBook to confirm that your Business is real and currently operating in Pakistan.',
              children: [
                _buildTextField(
                  state.context,
                  'Business Name',
                  state._companyNameController,
                  'e.g: Al Basit Bus / Van Service',
                  icon: Icons.business_rounded,
                ),
                _buildDropdownField(
                  state.context,
                  'Business Type',
                  state._selectedBusinessType,
                  _businessTypes,
                  (value) =>
                      state.setState(() => state._selectedBusinessType = value),
                ),
                _buildDropdownField(
                  state.context,
                  'Business Status',
                  state._selectedBusinessStatus,
                  _businessStatuses,
                  (value) => state.setState(
                    () => state._selectedBusinessStatus = value,
                  ),
                ),
                _buildTextField(
                  state.context,
                  'Year Business Started',
                  state._businessStartYearController,
                  'e.g: 2005',
                  icon: Icons.calendar_today_rounded,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSectionCard(
              step: 2,
              title: 'Business Registration Details',
              subtitle:
                  'If your business is not officially registered, you can still apply, but approval may take more time.',
              children: [
                _buildTextField(
                  state.context,
                  'Registered Business Name',
                  state._registeredBusinessNameController,
                  '(If different from company name)',
                  icon: Icons.business_center_rounded,
                ),
                _buildDropdownField(
                  state.context,
                  'Business Registered With',
                  state._selectedRegistrationAuthority,
                  _registrationAuthorities,
                  (value) => state.setState(
                    () => state._selectedRegistrationAuthority = value,
                  ),
                ),
                _buildTextField(
                  state.context,
                  'Registration / Trade License Number',
                  state._registrationNumberController,
                  'Enter official number if available',
                  icon: Icons.numbers_rounded,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSectionCard(
              step: 3,
              title: 'Office Address',
              subtitle: '',
              children: [
                _buildTextField(
                  state.context,
                  'Office Address',
                  state._officeAddressController,
                  'Street, area, building name',
                  icon: Icons.location_on_rounded,
                ),
                _buildTextField(
                  state.context,
                  'City',
                  state._cityController,
                  null,
                  icon: Icons.location_city_rounded,
                ),
                _buildTextField(
                  state.context,
                  'Province',
                  state._provinceController,
                  null,
                  icon: Icons.map_rounded,
                ),
                _buildTextField(
                  state.context,
                  'Country',
                  state._countryController,
                  null,
                  enabled: false,
                  icon: Icons.flag_rounded,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSectionCard(
              step: 4,
              title: 'Operating Information',
              subtitle: '',
              children: [
                _buildDropdownField(
                  state.context,
                  'Main Service Type',
                  state._selectedServiceType,
                  _serviceTypes,
                  (value) =>
                      state.setState(() => state._selectedServiceType = value),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSectionCard(
              step: 5,
              title: 'Tax Information (Optional)',
              subtitle: '',
              children: [
                _buildTextField(
                  state.context,
                  'NTN (National Tax Number)',
                  state._ntnController,
                  null,
                  required: false,
                  icon: Icons.account_balance_rounded,
                ),
                _buildDropdownField(
                  state.context,
                  'Tax Registered?',
                  state._selectedTaxRegistered,
                  _taxOptions,
                  (value) => state.setState(
                    () => state._selectedTaxRegistered = value,
                  ),
                  required: false,
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildSectionCard(
              step: 6,
              title: 'Business Owner Details (MANDATORY)',
              subtitle:
                  'This helps us confirm the real owner of the business.\n\nCNIC details are kept secure and used only for verification.',
              children: [
                _buildTextField(
                  state.context,
                  'Business Owner Full Name',
                  state._ownerNameController,
                  null,
                  icon: Icons.person_rounded,
                ),
                _buildTextField(
                  state.context,
                  'Owner CNIC Number',
                  state._ownerCnicController,
                  null,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  icon: Icons.credit_card_rounded,
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

            const SizedBox(height: 16),

            _buildSectionCard(
              step: 7,
              title: 'Business Documents Upload',
              subtitle: 'Please upload clear photos or PDF files:',
              children: [
                _buildFileUploadField(
                  state.context,
                  'Business Registration or Trade License\n(SECP / Local Trade / Union document)',
                  state._businessRegistrationDocument,
                  state._pickDocument,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Agreement card
            _buildAgreementCard(state),

            const SizedBox(height: 28),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: state._isSubmitting ? null : state._submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightSeaGreen,
                  disabledBackgroundColor: AppColors.lightSeaGreen.withOpacity(
                    0.5,
                  ),
                  elevation: 3,
                  shadowColor: AppColors.lightSeaGreen.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: state._isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Submit Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildHeaderBanner() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.lightSeaGreen.withOpacity(0.12),
          AppColors.accentOrange.withOpacity(0.08),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.lightSeaGreen.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.lightSeaGreen.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.verified_user_rounded,
            color: AppColors.lightSeaGreen,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Business Verification',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Complete all sections to get your business approved on YouBook.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSectionCard({
  required int step,
  required String title,
  required String subtitle,
  required List<Widget> children,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: AppColors.lightSeaGreen.withOpacity(0.07),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            border: Border(
              bottom: BorderSide(
                color: AppColors.lightSeaGreen.withOpacity(0.15),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.lightSeaGreen,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$step',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.accentOrange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 15,
                        color: AppColors.accentOrange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade800,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              ...children,
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildAgreementCard(_ManagerCompanyDetailsScreenState state) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: AppColors.lightSeaGreen.withOpacity(0.07),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            border: Border(
              bottom: BorderSide(
                color: AppColors.lightSeaGreen.withOpacity(0.15),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.lightSeaGreen.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_rounded,
                  color: AppColors.lightSeaGreen,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Confirmation & Agreement',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            children: [
              _buildCheckboxField(
                'I confirm that all the information and documents I have provided are true and correct.',
                state._confirmInformation,
                (value) => state.setState(
                  () => state._confirmInformation = value ?? false,
                ),
              ),
              _buildCheckboxField(
                'I understand that if any information or document is found to be false or incorrect, my Business will not be approved or may be removed from YouBook.',
                state._understandConsequences,
                (value) => state.setState(
                  () => state._understandConsequences = value ?? false,
                ),
              ),
            ],
          ),
        ),
      ],
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
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      cursorColor: AppColors.lightSeaGreen,
      cursorWidth: 2,
      style: const TextStyle(
        color: Color(0xFF1A1A2E),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.lightSeaGreen, size: 20)
            : null,
        labelText: required ? '$label *' : label,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0B8C1), fontSize: 13),
        labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        floatingLabelStyle: TextStyle(
          color: AppColors.lightSeaGreen,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        filled: true,
        fillColor: enabled ? const Color(0xFFF9FAFB) : const Color(0xFFF0F0F0),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.lightSeaGreen, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        errorMaxLines: 2,
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '${label.replaceAll(' *', '')} is required';
              }
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
          _formatCnic(value, controller);
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
  final bool hasValue = value != null && value.isNotEmpty;

  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: FormField<String>(
      initialValue: value,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: required
          ? (v) {
              if (v == null || v.isEmpty) {
                return 'Please select ${label.replaceAll(' *', '')}';
              }
              return null;
            }
          : null,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () async {
                final selected = await showModalBottomSheet<String>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => _DropdownSheet(
                    label: label,
                    options: options,
                    selected: value,
                  ),
                );
                if (selected != null) {
                  onChanged(selected);
                  field.didChange(selected);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: hasValue
                      ? AppColors.lightSeaGreen.withOpacity(0.04)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: field.hasError
                        ? AppColors.error
                        : hasValue
                        ? AppColors.lightSeaGreen.withOpacity(0.6)
                        : const Color(0xFFE5E7EB),
                    width: hasValue ? 1.5 : 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.list_alt_rounded,
                      size: 20,
                      color: hasValue
                          ? AppColors.lightSeaGreen
                          : const Color(0xFFB0B8C1),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            required ? '$label *' : label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: hasValue
                                  ? AppColors.lightSeaGreen
                                  : const Color(0xFF9CA3AF),
                              letterSpacing: 0.2,
                            ),
                          ),
                          if (hasValue) ...[
                            const SizedBox(height: 2),
                            Text(
                              value,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ] else
                            Text(
                              'Tap to select...',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFB0B8C1),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: hasValue
                            ? AppColors.lightSeaGreen.withOpacity(0.1)
                            : const Color(0xFFF0F0F0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: hasValue
                            ? AppColors.lightSeaGreen
                            : const Color(0xFFB0B8C1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 14),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(color: AppColors.error, fontSize: 11),
                ),
              ),
          ],
        );
      },
    ),
  );
}

class _DropdownSheet extends StatefulWidget {
  final String label;
  final List<String> options;
  final String? selected;

  const _DropdownSheet({
    required this.label,
    required this.options,
    this.selected,
  });

  @override
  State<_DropdownSheet> createState() => _DropdownSheetState();
}

class _DropdownSheetState extends State<_DropdownSheet> {
  late String? _hovered;

  @override
  void initState() {
    super.initState();
    _hovered = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightSeaGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.list_alt_rounded,
                    color: AppColors.lightSeaGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        'Select one option below',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: const Color(0xFF9CA3AF),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(height: 1, color: const Color(0xFFF3F4F6)),
          const SizedBox(height: 8),

          // Options list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              itemCount: widget.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final option = widget.options[index];
                final isSelected = option == widget.selected;

                return GestureDetector(
                  onTap: () => Navigator.pop(context, option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.lightSeaGreen
                          : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.lightSeaGreen
                            : const Color(0xFFE5E7EB),
                        width: 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.lightSeaGreen.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.white.withOpacity(0.25)
                                : const Color(0xFFE5E7EB),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFFD1D5DB),
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF374151),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Selected',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildFileUploadField(
  BuildContext context,
  String label,
  File? file,
  VoidCallback onTap, {
  bool isLoading = false,
}) {
  final bool hasFile = file != null;

  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: hasFile ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasFile ? const Color(0xFF86EFAC) : const Color(0xFFE5E7EB),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasFile
                    ? const Color(0xFFDCFCE7)
                    : AppColors.lightSeaGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.lightSeaGreen,
                      ),
                    )
                  : Icon(
                      hasFile
                          ? Icons.check_circle_rounded
                          : Icons.upload_file_rounded,
                      color: hasFile
                          ? const Color(0xFF16A34A)
                          : AppColors.lightSeaGreen,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$label *',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isLoading
                        ? 'Processing image...'
                        : hasFile
                        ? file.path.split('/').last
                        : 'Tap to select file',
                    style: TextStyle(
                      color: hasFile
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF9CA3AF),
                      fontSize: 13,
                      fontWeight: hasFile ? FontWeight.w600 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!isLoading)
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: const Color(0xFFD1D5DB),
                size: 14,
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
    padding: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: value
              ? AppColors.lightSeaGreen.withOpacity(0.06)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value
                ? AppColors.lightSeaGreen.withOpacity(0.4)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.lightSeaGreen,
                checkColor: Colors.white,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(
                  color: value
                      ? AppColors.lightSeaGreen
                      : const Color(0xFFD1D5DB),
                  width: 1.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: value
                      ? const Color(0xFF1A1A2E)
                      : const Color(0xFF6B7280),
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: value ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
