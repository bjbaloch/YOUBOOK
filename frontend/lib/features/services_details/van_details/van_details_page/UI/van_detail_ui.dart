// ui.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youbook/core/theme/app_colors.dart';
import 'package:youbook/features/services_details/service_confirmation/service_confirm_page/UI/service_confirm_ui.dart';
import 'package:youbook/features/services_details/van_details/van_details_page/Data/van_detail_data.dart';
import 'package:youbook/features/services_details/van_details/van_details_page/Logic/van_detail_logic.dart';

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

  @override
  void initState() {
    super.initState();
    data.priceController.addListener(() {
      logic.updateApplicationCharges(
          data.priceController, data.applicationController);
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _VanInformationSection(
                  selectedVanType: data.selectedVanType,
                  onVanTypeChanged: (value) {
                    setState(() {
                      data.selectedVanType = value;
                    });
                  },
                ),
                const _DriverInformationSection(),
                const _ProprietorInformationSection(),
                const _RouteInformationSection(),
                const _OfficeTerminalSection(),
                _ScheduleDetailsSection(
                  departureController: data.departureController,
                  arrivalController: data.arrivalController,
                  onPickDateTime: (controller) =>
                      logic.pickDateTime(context, controller),
                ),
                _SeatLayoutSection(
                  priceController: data.priceController,
                  applicationController: data.applicationController,
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
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => showServiceConfirmationDialog(context),
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
          keyboardType: widget.labelEn == 'Price Per Seat'
              ? TextInputType.number
              : TextInputType.text,
          inputFormatters: widget.labelEn == 'Price Per Seat'
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
              : [],
          onChanged: widget.onChanged,
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
              borderRadius:  BorderRadius.circular(10),
              borderSide: BorderSide(
                color: AppColors.accentOrange,
                width: 2,
              ),
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
  final String? selectedVanType;
  final ValueChanged<String?> onVanTypeChanged;

  const _VanInformationSection({
    required this.selectedVanType,
    required this.onVanTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(titleEn: 'Van Information', titleUr: 'وین معلومات', isRequired: true),
        const CustomInputField(labelEn: 'Van Name', labelUr: 'وین کا نام'),
        const CustomInputField(labelEn: 'Van Number', labelUr: 'وین نمبر'),
        const CustomInputField(labelEn: 'Van Color', labelUr: 'وین کا رنگ'),
      ],
    );
  }
}

class _DriverInformationSection extends StatelessWidget {
  const _DriverInformationSection();

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: const [
        SectionHeader(titleEn: 'Driver Information', titleUr: 'ڈرائیور معلوماتِ ', isRequired: true),
        CustomInputField(labelEn: 'Driver Name', labelUr: 'ڈرائیور نام'),
        CustomInputField(labelEn: 'Driving Experience', labelUr: 'ڈرائیونگ تجربہ'),
        CustomInputField(labelEn: 'Phone Number', labelUr: 'فون نمبر'),
        CustomInputField(labelEn: 'CNIC', labelUr: 'قومی شناختی کارڈ نمبر'),
      ],
    );
  }
}

class _ProprietorInformationSection extends StatelessWidget {
  const _ProprietorInformationSection();

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: const [
        SectionHeader(titleEn: 'Proprietor Information', titleUr: 'مالک کی معلومات', isRequired: true),
        CustomInputField(labelEn: 'Proprietor', labelUr: 'مالک'),
        CustomInputField(labelEn: 'General Manager', labelUr: 'جنرل منیجر'),
        CustomInputField(labelEn: 'Manager', labelUr: 'منیجر'),
        CustomInputField(labelEn: 'Secretary', labelUr: 'سیکرٹری'),
      ],
    );
  }
}

class _RouteInformationSection extends StatelessWidget {
  const _RouteInformationSection();

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: const [
        SectionHeader(titleEn: 'Route Information', titleUr: 'معلوماتِ راستہ', isRequired: true),
        CustomInputField(labelEn: 'From', labelUr: 'سے'),
        CustomInputField(labelEn: 'To', labelUr: 'تک'),
      ],
    );
  }
}

class _OfficeTerminalSection extends StatelessWidget {
  const _OfficeTerminalSection();

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: const [
        SectionHeader(titleEn: 'Office / Terminal Information', titleUr: 'دفتر / ٹرمینل کی معلومات', isRequired: true),
        CustomInputField(labelEn: 'Boarding Office/Terminal', labelUr: 'سوار ہونے کا دفتر/اڈا'),
        CustomInputField(labelEn: 'Arrival Office/Terminal', labelUr: 'منزل پر اترنے کا دفتر/اڈا'),
      ],
    );
  }
}

class _ScheduleDetailsSection extends StatelessWidget {
  final TextEditingController departureController;
  final TextEditingController arrivalController;
  final Future<void> Function(TextEditingController) onPickDateTime;

  const _ScheduleDetailsSection({
    required this.departureController,
    required this.arrivalController,
    required this.onPickDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(titleEn: 'Schedule Details', titleUr: 'شیڈول تفصیلات', isRequired: true),
        CustomInputField(
          labelEn: 'Departure Date & Time',
          labelUr: 'روانگی کی تاریخ اور وقت',
          controller: departureController,
          readOnly: true,
          suffixIcon: const Icon(Icons.calendar_month_rounded),
          onTap: () => onPickDateTime(departureController),
        ),
        CustomInputField(
          labelEn: 'Arrival Date & Time',
          labelUr: 'آمد کی تاریخ اور وقت',
          controller: arrivalController,
          readOnly: true,
          suffixIcon: const Icon(Icons.calendar_month_rounded),
          onTap: () => onPickDateTime(arrivalController),
        ),
      ],
    );
  }
}

class _SeatLayoutSection extends StatelessWidget {
  final TextEditingController priceController;
  final TextEditingController applicationController;

  const _SeatLayoutSection({
    required this.priceController,
    required this.applicationController,
  });

  @override
  Widget build(BuildContext context) {
    return _sectionContainer(
      children: [
        const SectionHeader(titleEn: 'Seat & Pricing Details', titleUr: 'نشست اور قیمت کی تفصیلات', isRequired: true),
        CustomInputField(labelEn: 'Price Per Seat', labelUr: 'فی نشست قیمت', controller: priceController),
        CustomInputField(labelEn: 'Application Charges', labelUr: 'ایپلیکیشن چارجز', controller: applicationController, readOnly: true),
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
