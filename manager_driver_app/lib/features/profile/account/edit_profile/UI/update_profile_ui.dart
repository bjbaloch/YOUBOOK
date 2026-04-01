import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/widgets/success_dialog.dart';
import '../Logic/update_profile_logic.dart';

class EditProfilePageUI extends StatefulWidget {
  const EditProfilePageUI({super.key});

  @override
  State<EditProfilePageUI> createState() => _EditProfilePageUIState();
}

class _EditProfilePageUIState extends State<EditProfilePageUI>
    with SingleTickerProviderStateMixin {
  final EditProfileLogic _logic = EditProfileLogic();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _logic.setupCnicAutoDash(_cnicCtrl);
    _loadExistingData();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;
      if (currentUser != null) {
        setState(() => _nameCtrl.text = currentUser.fullName);
      }
    } catch (e) {
      debugPrint('Error loading existing data: $e');
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cnicCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    _logic.data.fullName = _nameCtrl.text.trim();
    _logic.data.phone = _phoneCtrl.text.trim();
    _logic.data.cnic = _cnicCtrl.text.trim();
    _logic.data.country = _countryCtrl.text.trim();
    _logic.data.stateProvince = _stateCtrl.text.trim();
    _logic.data.city = _cityCtrl.text.trim();
    _logic.data.address = _addressCtrl.text.trim();

    setState(() => _loading = true);

    String? errorMessage;
    try {
      final success = await _logic.updateProfile(context);
      if (!mounted) return;
      setState(() => _loading = false);
      if (success) {
        await SuccessDialog.show(
          context,
          title: 'Profile Updated!',
          message: 'Your profile has been updated successfully.',
          icon: Icons.check_circle,
        );
        Navigator.of(context).pop(true);
        return;
      } else {
        errorMessage = 'Failed to update profile. Please try again.';
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      errorMessage = e.toString();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage ?? 'Unknown error occurred'),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(ColorScheme cs) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: AppBar(
        toolbarHeight: 56,
        backgroundColor: cs.primary,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: cs.onPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'Update Profile',
              style: TextStyle(
                color: cs.onPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Keep your info up to date',
              style: TextStyle(
                color: cs.onPrimary.withOpacity(0.75),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Avatar Header ────────────────────────────────────────────────────────────
  Widget _buildAvatarHeader(ColorScheme cs) {
    final avatarImage =
        _logic.data.imageFile != null ? FileImage(_logic.data.imageFile!) : null;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, cs.primary.withOpacity(0.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: cs.onPrimary.withOpacity(0.6), width: 2.5),
                ),
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: cs.onPrimary.withOpacity(0.2),
                  backgroundImage: avatarImage,
                  child: avatarImage == null
                      ? Icon(Icons.person_rounded,
                          color: cs.onPrimary, size: 48)
                      : null,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Material(
                  color: cs.secondary,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () async {
                      await _logic.pickFromGallery();
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Icon(Icons.photo_library_rounded,
                          size: 16, color: cs.onSecondary),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Tap the icon to change photo',
            style: TextStyle(
              color: cs.onPrimary.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── Form Field ───────────────────────────────────────────────────────────────
  Widget _field({
    required ColorScheme cs,
    required IconData icon,
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? type,
    List<TextInputFormatter>? inputFormatters,
    bool isLast = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: type,
      inputFormatters: inputFormatters,
      style: TextStyle(color: cs.onSurface, fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: cs.primary, size: 20),
        labelText: label,
        labelStyle:
            TextStyle(color: cs.onSurface.withOpacity(0.6), fontSize: 13),
        floatingLabelStyle: TextStyle(
            color: cs.primary, fontWeight: FontWeight.w600, fontSize: 13),
        filled: true,
        fillColor: cs.surface,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.onSurface.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }

  // ── Form Group Card ──────────────────────────────────────────────────────────
  Widget _formCard({required ColorScheme cs, required List<Widget> fields}) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: cs.onBackground.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(fields.length, (i) {
          return Column(
            children: [
              fields[i],
              if (i < fields.length - 1) const SizedBox(height: 12),
            ],
          );
        }),
      ),
    );
  }

  Widget _sectionLabel(String text, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: cs.onBackground.withOpacity(0.45),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: _buildAppBar(cs),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildAvatarHeader(cs),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('Personal Info', cs),
                        _formCard(
                          cs: cs,
                          fields: [
                            _field(
                              cs: cs,
                              icon: Icons.person_rounded,
                              label: 'Full Name',
                              controller: _nameCtrl,
                              validator: (v) =>
                                  _logic.validateRequiredField(v, 'name'),
                            ),
                            _field(
                              cs: cs,
                              icon: Icons.phone_rounded,
                              label: 'Phone Number',
                              controller: _phoneCtrl,
                              type: TextInputType.phone,
                              validator: (v) =>
                                  _logic.validateRequiredField(v, 'phone number'),
                            ),
                            _field(
                              cs: cs,
                              icon: Icons.badge_rounded,
                              label: 'CNIC',
                              controller: _cnicCtrl,
                              type: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: _logic.validateCnic,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _sectionLabel('Location', cs),
                        _formCard(
                          cs: cs,
                          fields: [
                            _field(
                              cs: cs,
                              icon: Icons.flag_rounded,
                              label: 'Country',
                              controller: _countryCtrl,
                              validator: (v) =>
                                  _logic.validateRequiredField(v, 'country'),
                            ),
                            _field(
                              cs: cs,
                              icon: Icons.map_rounded,
                              label: 'State / Province',
                              controller: _stateCtrl,
                              validator: (v) =>
                                  _logic.validateRequiredField(v, 'state/province'),
                            ),
                            _field(
                              cs: cs,
                              icon: Icons.location_city_rounded,
                              label: 'City',
                              controller: _cityCtrl,
                              validator: (v) =>
                                  _logic.validateRequiredField(v, 'city'),
                            ),
                            _field(
                              cs: cs,
                              icon: Icons.location_on_rounded,
                              label: 'Address',
                              controller: _addressCtrl,
                              validator: (v) =>
                                  _logic.validateRequiredField(v, 'address'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _updateProfile,
                            icon: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.textWhite),
                                  )
                                : const Icon(Icons.save_rounded,
                                    color: AppColors.textWhite),
                            label: Text(
                              _loading ? 'Saving...' : 'Update Profile',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textWhite,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              disabledBackgroundColor:
                                  cs.primary.withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
