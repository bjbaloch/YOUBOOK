// ui.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youbook/core/theme/app_colors.dart';
import 'package:youbook/features/services_details/bus_details/bus_detail_page/Data/bus_detail_data.dart';
import 'package:youbook/features/services_details/bus_details/bus_detail_page/Logic/bus_detail_logic.dart';
import 'package:youbook/features/services_details/service_confirmation/service_confirm_page/UI/service_confirm_ui.dart';


// ---------- SCREEN ----------
class AddBusDetailsScreen extends StatefulWidget {
  const AddBusDetailsScreen({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute(builder: (_) => const AddBusDetailsScreen());
  }

  @override
  State<AddBusDetailsScreen> createState() => _AddBusDetailsScreenState();
}

class _AddBusDetailsScreenState extends State<AddBusDetailsScreen> {
  final BusFormData data = BusFormData();
  final BusFormLogic logic = BusFormLogic();
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
            elevation: 0,
            title: const Text(
              'Add Bus Details',
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
                  _BusInformationSection(
                    selectedBusType: data.selectedBusType,
                    onBusTypeChanged: (value) {
                      setState(() {
                        data.selectedBusType = value;
                      });
                    },
                    formKey: _formKey,
                  ),
                  _DriverInformationSection(formKey: _formKey),
                  _ProprietorInformationSection(formKey: _formKey),
                  _RouteInformationSection(formKey: _formKey),
                  _OfficeTerminalSection(formKey: _formKey),
                  _ScheduleDetailsSection(
                    departureController: data.departureController,
                    arrivalController: data.arrivalController,
                    onPickDateTime: (controller) =>
                        logic.pickDateTime(context, controller),
                    formKey: _formKey,
                  ),
                  _SeatLayoutSection(
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
              showServiceConfirmationDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentOrange,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Text(
              'Save Bus Details',
              style: TextStyle(fontSize: 16, color: AppColors.textWhite),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Section Widgets ----------

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
  final GlobalKey<FormState> formKey;

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
    required this.formKey,
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
          keyboardType: widget.keyboardType ?? TextInputType.text,
          inputFormatters: widget.inputFormatters,
          onChanged: (value) {
            widget.onChanged?.call(value);
            widget.formKey.currentState?.validate();
          },
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          validator: (value) {
            if (widget.isRequired && (value == null || value.isEmpty)) {
              return 'Enter the ${widget.labelEn}';
            }
            return widget.customValidator?.call(value);
          },
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

/// ---------- Sections ----------

class _BusInformationSection extends StatelessWidget {
  final String? selectedBusType;
  final ValueChanged<String?> onBusTypeChanged;
  final GlobalKey<FormState> formKey;

  const _BusInformationSection({
    required this.selectedBusType,
    required this.onBusTypeChanged,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Bus Information',
          titleUr: 'بس کی معلومات',
          isRequired: true,
        ),
        CustomInputField(
          labelEn: 'Bus Name',
          labelUr: 'بس نام',
          isRequired: true,
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'Bus Number',
          labelUr: 'بس نمبر',
          isRequired: true,
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'Bus Color',
          labelUr: 'بس رنگ',
          isRequired: true,
          formKey: formKey,
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _DriverInformationSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const _DriverInformationSection({required this.formKey});

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(
          titleEn: 'Driver Information',
          titleUr: 'ڈرائیور کی معلومات',
          isRequired: true,
        ),
        CustomInputField(
          labelEn: 'Driver Name',
          labelUr: 'ڈرائیور نام',
          isRequired: true,
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'Driving Experience',
          labelUr: 'ڈرائیونگ تجربہ',
          isRequired: true,
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'Phone Number',
          labelUr: 'فون نمبر',
          isRequired: true,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          customValidator: (value) {
            if (value == null || value.isEmpty)
              return 'Enter the Driver Phone Number';
            if (!value.startsWith('03'))
              return 'Phone number must start with 03';
            if (value.length != 11)
              return 'Phone number must be exactly 11 digits';
            return null;
          },
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'CNIC',
          labelUr: 'قومی شناختی کارڈ نمبر',
          isRequired: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            CnicInputFormatter(),
            LengthLimitingTextInputFormatter(15),
          ],
          customValidator: (value) {
            if (value == null || value.isEmpty) return 'Enter the Driver CNIC';
            if (!RegExp(r'^\d{5}-\d{7}-\d{1}$').hasMatch(value))
              return 'Invalid CNIC format (e.g., XXXXX-XXXXXXX-X)';
            return null;
          },
          formKey: formKey,
        ),
      ],
    );
  }
}

class _ProprietorInformationSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  const _ProprietorInformationSection({required this.formKey});

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
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'General Manager',
          labelUr: 'جنرل منیجر',
          isRequired: true,
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'Manager',
          labelUr: 'منیجر',
          isRequired: true,
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'Secretary',
          labelUr: 'سیکرٹری',
          isRequired: true,
          formKey: formKey,
        ),
      ],
    );
  }
}

class _RouteInformationSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  const _RouteInformationSection({required this.formKey});

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
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'To',
          labelUr: 'تک',
          isRequired: true,
          formKey: formKey,
        ),
      ],
    );
  }
}

class _OfficeTerminalSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  const _OfficeTerminalSection({required this.formKey});

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
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'Arrival Office/Terminal',
          labelUr: 'منزل پر اترنے کا دفتر/اڈا',
          isRequired: true,
          formKey: formKey,
        ),
      ],
    );
  }
}

class _ScheduleDetailsSection extends StatelessWidget {
  final TextEditingController departureController;
  final TextEditingController arrivalController;
  final Function(TextEditingController) onPickDateTime;
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
          titleUr: 'شیڈول کی تفصیلات',
          isRequired: true,
        ),
        CustomInputField(
          labelEn: 'Departure Time',
          labelUr: ' روانگی کا وقت',
          isRequired: true,
          controller: departureController,
          readOnly: true,
          onTap: () => onPickDateTime(departureController),
          suffixIcon: const Icon(Icons.calendar_today),
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'Arrival Time',
          labelUr: 'آمد کا وقت',
          isRequired: true,
          controller: arrivalController,
          readOnly: true,
          onTap: () => onPickDateTime(arrivalController),
          suffixIcon: const Icon(Icons.calendar_today),
          formKey: formKey,
        ),
      ],
    );
  }
}

class _OperationalControlsSection extends StatefulWidget {
  const _OperationalControlsSection();

  @override
  State<_OperationalControlsSection> createState() => _OperationalControlsSectionState();
}

class _OperationalControlsSectionState extends State<_OperationalControlsSection> {
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
        const SectionHeader(titleEn: 'Operational Controls', titleUr: 'عملی کنٹرولز', isRequired: true),
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Instructions for Passengers (ہدایات براۓ مسافر)', style: TextStyle(fontSize: 14)),
                Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
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
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.25))),
                focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: AppColors.accentOrange, width: 2)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
      ],
    );
  }
}

class _SeatLayoutSection extends StatelessWidget {
  final TextEditingController priceController;
  final TextEditingController applicationController;
  final bool isSeatLayoutConfigured;
  final ValueChanged<bool> onSeatLayoutConfigured;
  final GlobalKey<FormState> formKey;

  const _SeatLayoutSection({
    required this.priceController,
    required this.applicationController,
    required this.isSeatLayoutConfigured,
    required this.onSeatLayoutConfigured,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
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
          isRequired: true,
          controller: priceController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
          formKey: formKey,
        ),
        CustomInputField(
          labelEn: 'Application Charges',
          labelUr: 'ایپلیکیشن چارجز',
          controller: applicationController,
          readOnly: true,
          formKey: formKey,
        ),
        CheckboxListTile(
          title: const Text('Seat layout configured'),
          value: isSeatLayoutConfigured,
          onChanged: (value) => onSeatLayoutConfigured(value ?? false),
        ),
      ],
    );
  }
}

class _DisclaimerSection extends StatefulWidget {
  final bool isAgreed;
  final ValueChanged<bool?> onChanged;

  const _DisclaimerSection({
    required this.isAgreed,
    required this.onChanged,
  });

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
          subtitle: const Text('I have read and accepted all terms and conditions of the service.'),
          value: widget.isAgreed,
          onChanged: widget.onChanged,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }
}
