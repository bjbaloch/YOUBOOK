import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/widgets/success_dialog.dart';
import '../../../../../core/services/profile_storage_service.dart';
import '../Logic/update_profile_logic.dart';

class EditProfilePageUI extends StatefulWidget {
  const EditProfilePageUI({super.key});

  @override
  State<EditProfilePageUI> createState() => _EditProfilePageUIState();
}

class _EditProfilePageUIState extends State<EditProfilePageUI> {
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

  @override
  void initState() {
    super.initState();
    _logic.setupCnicAutoDash(_cnicCtrl);
    // Load existing data from storage
    _loadExistingData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data if AuthProvider user changes
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      _loadExistingData();
    }
  }

  Future<void> _loadExistingData() async {
    try {
      // Only load data if there's an authenticated user
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;

      if (currentUser != null) {
        // Use authenticated user data from database
        setState(() {
          _nameCtrl.text = currentUser.fullName ?? '';
          _phoneCtrl.text = currentUser.phoneNumber ?? '';
          _cnicCtrl.text = currentUser.cnic ?? '';
          _countryCtrl.text = currentUser.country ?? '';
          _stateCtrl.text = currentUser.stateProvince ?? '';
          _cityCtrl.text = currentUser.city ?? '';
          _addressCtrl.text = currentUser.address ?? '';
        });
      }
      // If no authenticated user, leave fields empty
    } catch (e) {
      debugPrint('Error loading existing data: $e');
      // Keep fields empty on error
    }
  }

  @override
  void dispose() {
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

    // Transfer form data to logic data object
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

  PreferredSizeWidget _appBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PreferredSize(
      preferredSize: const Size.fromHeight(45),
      child: AppBar(
        toolbarHeight: 45,
        backgroundColor: cs.primary,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Update Profile',
          style: TextStyle(color: cs.onPrimary, fontSize: 20),
        ),
      ),
    );
  }

  Widget _field({
    required BuildContext context,
    required IconData icon,
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? type,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: type,
      inputFormatters: inputFormatters,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: cs.onSurface.withOpacity(0.85)),
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? AppColors.textWhite : AppColors.textBlack,
        ),
        floatingLabelStyle: TextStyle(
          color: isDark ? AppColors.textWhite : AppColors.textBlack,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: cs.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cs.onSurface.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accentOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final avatarImage = _logic.data.imageFile != null
        ? FileImage(_logic.data.imageFile!)
        : null;

    return Scaffold(
      backgroundColor: cs.background,
      appBar: _appBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Avatar Section
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: cs.onPrimary,
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? Icon(Icons.person, color: cs.primary, size: 52)
                          : null,
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Material(
                        color: cs.secondary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () async {
                            await _logic.pickFromGallery();
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.photo_library_rounded,
                              size: 16,
                              color: cs.onSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Form Fields
                _field(
                  context: context,
                  icon: Icons.person,
                  label: 'Full Name',
                  controller: _nameCtrl,
                  validator: (v) => _logic.validateRequiredField(v, 'name'),
                ),
                const SizedBox(height: 12),

                _field(
                  context: context,
                  icon: Icons.phone,
                  label: 'Phone Number',
                  controller: _phoneCtrl,
                  type: TextInputType.phone,
                  validator: (v) =>
                      _logic.validateRequiredField(v, 'phone number'),
                ),
                const SizedBox(height: 12),

                _field(
                  context: context,
                  icon: Icons.badge,
                  label: 'CNIC',
                  controller: _cnicCtrl,
                  type: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _logic.validateCnic,
                ),
                const SizedBox(height: 12),

                _field(
                  context: context,
                  icon: Icons.flag_outlined,
                  label: 'Country',
                  controller: _countryCtrl,
                  validator: (v) => _logic.validateRequiredField(v, 'country'),
                ),
                const SizedBox(height: 12),

                _field(
                  context: context,
                  icon: Icons.map_outlined,
                  label: 'State/Province',
                  controller: _stateCtrl,
                  validator: (v) =>
                      _logic.validateRequiredField(v, 'state/province'),
                ),
                const SizedBox(height: 12),

                _field(
                  context: context,
                  icon: Icons.location_city,
                  label: 'City',
                  controller: _cityCtrl,
                  validator: (v) => _logic.validateRequiredField(v, 'city'),
                ),
                const SizedBox(height: 12),

                _field(
                  context: context,
                  icon: Icons.location_on,
                  label: 'Address',
                  controller: _addressCtrl,
                  validator: (v) => _logic.validateRequiredField(v, 'address'),
                ),
                const SizedBox(height: 26),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.secondary,
                      foregroundColor: cs.onSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _loading
                        ? CircularProgressIndicator(color: cs.onSecondary)
                        : const Text(
                            'Update Profile',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textWhite,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
