// ui.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youbook/core/theme/app_colors.dart';
import 'package:youbook/core/services/api_service.dart';
import 'package:youbook/features/services_details/service_confirmation/service_confirm_page/UI/service_confirm_ui.dart';
import 'package:youbook/features/services_details/van_details/van_details_page/Data/van_detail_data.dart';
import 'package:youbook/features/services_details/van_details/van_details_page/Logic/van_detail_logic.dart';
import 'package:youbook/features/services_details/van_details/van_seatlayout/UI/van_seatlayout_ui.dart';

// ---------- SCREEN ----------
class AddVanDetailsScreen extends StatefulWidget {
  const AddVanDetailsScreen({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute(builder: (_) => const AddVanDetailsScreen());
  }

  @override
  State<AddVanDetailsScreen> createState() => _AddVanDetailsScreenState();
}

class _AddVanDetailsScreenState extends State<AddVanDetailsScreen> {
  final VanFormData data = VanFormData();
  final VanFormLogic logic = VanFormLogic();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    data.priceController.addListener(() {
      logic.updateApplicationCharges(
        data.priceController,
        data.applicationController,
      );
    });
  }

  @override
  void dispose() {
    data.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: cs.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: AppBar(
            toolbarHeight: 45,
            elevation: 0,
            title: const Text(
              'Add Van Details',
              style: TextStyle(fontSize: 20),
            ),
            centerTitle: true,
            backgroundColor: cs.primary,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _VanInformationSection(
                    data: data,
                    selectedVanType: data.selectedVanType,
                    onVanTypeChanged: (value) {
                      setState(() {
                        data.selectedVanType = value;
                      });
                    },
                    formKey: _formKey,
                  ),
                  _ProprietorInformationSection(data: data, formKey: _formKey),
                  _RouteInformationSection(data: data, formKey: _formKey),
                  _OfficeTerminalSection(data: data, formKey: _formKey),
                  _ScheduleDetailsSection(
                    departureController: data.departureController,
                    arrivalController: data.arrivalController,
                    onPickDateTime: (controller) =>
                        logic.pickDateTime(context, controller),
                    formKey: _formKey,
                  ),
                  _SeatLayoutSection(
                    data: data,
                    priceController: data.priceController,
                    applicationController: data.applicationController,
                    isSeatLayoutConfigured: data.isSeatLayoutConfigured,
                    onSeatLayoutConfigured: (configured) {
                      setState(() {
                        data.isSeatLayoutConfigured = configured;
                      });
                    },
                    formKey: _formKey,
                  ),
                  const _OperationalControlsSection(),
                  _DisclaimerSection(
                    isAgreed: data.isAgreedToTerms,
                    onChanged: (newValue) {
                      setState(() {
                        data.isAgreedToTerms = newValue ?? false;
                      });
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              if (!(_formKey.currentState?.validate() ?? false)) return;
              if (!data.isAgreedToTerms) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please check the agreement.'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              showServiceConfirmationDialog(context, formData: data.toJson());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentOrange,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Text(
              'Save Van Details',
              style: TextStyle(fontSize: 16, color: AppColors.textWhite),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- COMMON WIDGETS ----------
class SectionHeader extends StatelessWidget {
  final String titleEn;
  final String titleUr;
  final bool isRequired;

  const SectionHeader({
    super.key,
    required this.titleEn,
    required this.titleUr,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Row(
        children: [
          Flexible(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
                children: [
                  TextSpan(text: '$titleEn ($titleUr)'),
                  if (isRequired)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomInputField extends StatefulWidget {
  final String labelEn;
  final String labelUr;
  final bool isRequired;
  final Icon? suffixIcon;
  final TextEditingController? controller;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? customValidator;
  final GlobalKey<FormState>? formKey;

  const CustomInputField({
    super.key,
    required this.labelEn,
    required this.labelUr,
    this.isRequired = false,
    this.suffixIcon,
    this.controller,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.customValidator,
    this.formKey,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: TextFormField(
          controller: widget.controller,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          maxLines: widget.maxLines,
          keyboardType:
              widget.keyboardType ??
              (widget.labelEn == 'Price Per Seat'
                  ? TextInputType.number
                  : TextInputType.text),
          inputFormatters:
              widget.inputFormatters ??
              (widget.labelEn == 'Price Per Seat'
                  ? [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ]
                  : null),
          onChanged: (value) {
            widget.onChanged?.call(value);
            widget.formKey?.currentState?.validate();
          },
          validator: (value) {
            if (widget.isRequired && (value == null || value.isEmpty)) {
              return 'Enter the ${widget.labelEn}';
            }
            return widget.customValidator?.call(value);
          },
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: '${widget.labelEn} (${widget.labelUr})',
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              fontWeight: _isFocused ? FontWeight.bold : FontWeight.normal,
            ),
            filled: true,
            fillColor: cs.surface,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            suffixIcon: widget.suffixIcon,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: cs.onSurface.withOpacity(0.25)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.accentOrange,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _sectionContainer({required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.all(12.0),
    margin: const EdgeInsets.only(bottom: 12.0),
    decoration: BoxDecoration(
      color: AppColors.lightSeaGreen.withOpacity(0.5),
      borderRadius: BorderRadius.circular(10.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

// ---------- ALL SECTIONS ----------
class _VanInformationSection extends StatelessWidget {
  final VanFormData data;
  final String? selectedVanType;
  final ValueChanged<String?> onVanTypeChanged;
  final GlobalKey<FormState> formKey;

  const _VanInformationSection({
    required this.data,
    required this.selectedVanType,
    required this.onVanTypeChanged,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Van Information',
          titleUr: 'وین معلومات',
          isRequired: true,
        ),
        CustomInputField(
          labelEn: 'Van Name',
          labelUr: 'وین کا نام',
          isRequired: true,
          controller: data.vanNameController,
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'Van Number',
          labelUr: 'وین نمبر',
          isRequired: true,
          controller: data.vanNumberController,
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'Van Color',
          labelUr: 'وین کا رنگ',
          isRequired: true,
          controller: data.vanColorController,
          formKey: formKey,
        ),
      ],
    );
  }
}



class _ProprietorInformationSection extends StatelessWidget {
  final VanFormData data;
  final GlobalKey<FormState> formKey;

  const _ProprietorInformationSection({
    required this.data,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Proprietor Information',
          titleUr: 'مالک کی معلومات',
          isRequired: true,
        ),
        CustomInputField(
          labelEn: 'Proprietor',
          labelUr: 'مالک',
          isRequired: true,
          controller: data.proprietorController,
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'General Manager',
          labelUr: 'جنرل منیجر',
          isRequired: true,
          controller: data.generalManagerController,
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'Manager',
          labelUr: 'منیجر',
          isRequired: true,
          controller: data.managerController,
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'Secretary',
          labelUr: 'سیکرٹری',
          isRequired: true,
          controller: data.secretaryController,
          formKey: formKey,
        ),
      ],
    );
  }
}

class _RouteInformationSection extends StatelessWidget {
  final VanFormData data;
  final GlobalKey<FormState> formKey;

  const _RouteInformationSection({required this.data, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Route Information',
          titleUr: 'معلوماتِ راستہ',
          isRequired: true,
        ),
        CustomInputField(
          labelEn: 'From',
          labelUr: 'سے',
          isRequired: true,
          controller: data.fromController,
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'To',
          labelUr: 'تک',
          isRequired: true,
          controller: data.toController,
          formKey: formKey,
        ),
      ],
    );
  }
}

class _OfficeTerminalSection extends StatelessWidget {
  final VanFormData data;
  final GlobalKey<FormState> formKey;

  const _OfficeTerminalSection({required this.data, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Office / Terminal Information',
          titleUr: 'دفتر / ٹرمینل کی معلومات',
          isRequired: true,
        ),
        CustomInputField(
          labelEn: 'Boarding Office/Terminal',
          labelUr: 'سوار ہونے کا دفتر/اڈا',
          isRequired: true,
          controller: data.boardingOfficeController,
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'Arrival Office/Terminal',
          labelUr: 'منزل پر اترنے کا دفتر/اڈا',
          isRequired: true,
          controller: data.arrivalOfficeController,
          formKey: formKey,
        ),
      ],
    );
  }
}

class _ScheduleDetailsSection extends StatelessWidget {
  final TextEditingController departureController;
  final TextEditingController arrivalController;
  final Future<void> Function(TextEditingController) onPickDateTime;
  final GlobalKey<FormState> formKey;

  const _ScheduleDetailsSection({
    required this.departureController,
    required this.arrivalController,
    required this.onPickDateTime,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Schedule Details',
          titleUr: 'شیڈول تفصیلات',
          isRequired: true,
        ),
        CustomInputField(
          labelEn: 'Departure Date & Time',
          labelUr: 'روانگی کی تاریخ اور وقت',
          controller: departureController,
          readOnly: true,
          suffixIcon: const Icon(Icons.calendar_month_rounded),
          onTap: () => onPickDateTime(departureController),
          isRequired: true,
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'Arrival Date & Time',
          labelUr: 'آمد کی تاریخ اور وقت',
          controller: arrivalController,
          readOnly: true,
          suffixIcon: const Icon(Icons.calendar_month_rounded),
          onTap: () => onPickDateTime(arrivalController),
          isRequired: true,
          formKey: formKey,
        ),
      ],
    );
  }
}

class _SeatLayoutSection extends StatelessWidget {
  final VanFormData data;
  final TextEditingController priceController;
  final TextEditingController applicationController;
  final bool isSeatLayoutConfigured;
  final ValueChanged<bool> onSeatLayoutConfigured;
  final GlobalKey<FormState> formKey;

  const _SeatLayoutSection({
    required this.data,
    required this.priceController,
    required this.applicationController,
    required this.isSeatLayoutConfigured,
    required this.onSeatLayoutConfigured,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Seat & Pricing Details',
          titleUr: 'نشست اور قیمت کی تفصیلات',
          isRequired: true,
        ),
        CustomInputField(
          labelEn: 'Price Per Seat',
          labelUr: 'فی نشست قیمت',
          controller: priceController,
          isRequired: true,
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'Application Charges',
          labelUr: 'ایپلیکیشن چارجز',
          controller: applicationController,
          readOnly: true,
          formKey: formKey,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const VanSeatLayoutFromImagePage(),
              ),
            ).then((result) {
              if (result != null && result is Map<String, dynamic>) {
                data.setSeatLayoutData(result);
                onSeatLayoutConfigured(true);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outline.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  isSeatLayoutConfigured
                      ? Icons.check_circle
                      : Icons.airport_shuttle,
                  color: isSeatLayoutConfigured ? Colors.green : cs.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'View Seat Layout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        isSeatLayoutConfigured
                            ? 'Seat layout configured'
                            : 'Tap to configure seating layout',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: cs.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OperationalControlsSection extends StatefulWidget {
  const _OperationalControlsSection();

  @override
  State<_OperationalControlsSection> createState() =>
      _OperationalControlsSectionState();
}

class _OperationalControlsSectionState
    extends State<_OperationalControlsSection> {
  bool _isExpanded = false;

  final TextEditingController _instructionsController = TextEditingController(
    text: '''
روانگی سے 15 منٹ پہلے پہنچ جائیں۔
سواری اپنے سامان کی خود حفاظت کرے۔
ایک ٹکٹ پر 10 کلو سامان فری لے جاسکتے ہیں۔
گاڑی میں سفر کرتے وقت ڈرائیور کو تیز چلانے پر مجبور نہ کریں۔
سیٹ کینسل کروانے کی صورت میں روانگی سے 1 گھنٹہ قبل رجوع کرے ٪50 کٹوتی ہوگی۔
اتفاقیہ حادثے کی صورت میں کسی بھی جان ومال کے نقصان کی صورت میں بکنگ کمپنی آفس زمہ دار نہیں ہوگی۔
بیگ کے اندر نقدی اور زیورات رکھنا منع ہے گُم ہونے کی صورت میں کمپنی زمہ دار نہ ہوگی۔
وقت پر نہ پہنچنے پر ٹکٹ ضائع ہو جائے گا۔
غیر قانونی سامان کا مسافر خود زمہ دار ہوگا۔
وقت کی پابندی اور نماز قائم کرے۔
غیر قانونی اشیاء کی بکنگ نہیں کی جائے گی۔
ڈرائیور کے ساتھ کسی قسم کے لین دین کی سواری خود زمہ دار ہو گی، کمپنی زمہ دار نہ ہوگی۔''',
  );

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Operational Controls',
          titleUr: 'عملی کنٹرولز',
          isRequired: true,
        ),
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Instructions for Passengers (ہدایات براۓ مسافر)',
                  style: TextStyle(fontSize: 14),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: TextFormField(
              controller: _instructionsController,
              maxLines: null,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.25),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(
                    color: AppColors.accentOrange,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
      ],
    );
  }
}

class _DisclaimerSection extends StatefulWidget {
  final bool isAgreed;
  final ValueChanged<bool?> onChanged;

  const _DisclaimerSection({required this.isAgreed, required this.onChanged});

  @override
  State<_DisclaimerSection> createState() => _DisclaimerSectionState();
}

class _DisclaimerSectionState extends State<_DisclaimerSection> {
  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Disclaimer',
          titleUr: 'ڈس کلیمر',
          isRequired: true,
        ),
        CheckboxListTile(
          title: const Text('I agree to the terms and conditions'),
          subtitle: const Text(
            'I have read and accepted all terms and conditions of the service.',
          ),
          value: widget.isAgreed,
          onChanged: widget.onChanged,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }
}
