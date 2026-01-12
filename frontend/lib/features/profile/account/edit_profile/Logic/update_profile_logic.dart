import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../Data/update_profile_data.dart';

class EditProfileLogic {
  final EditProfileData data = EditProfileData();
  final ImagePicker _picker = ImagePicker();
  final RegExp _cnicRegex = RegExp(r'^\d{5}-\d{7}-\d$');

  // Initialize with existing account data
  void initializeWithAccountData(dynamic accountData) {
    data.fullName = accountData?.fullName;
    data.cnic = accountData?.cnic;
    data.address = accountData?.address;
    data.city = accountData?.city;
    data.stateProvince = accountData?.stateProvince;
    data.country = accountData?.country;
  }

  void setupCnicAutoDash(TextEditingController controller) {
    controller.addListener(() {
      final raw = controller.text;
      String digits = raw.replaceAll(RegExp(r'\D'), '');
      if (digits.length > 13) digits = digits.substring(0, 13);

      String formatted;
      if (digits.length <= 5) {
        formatted = digits;
      } else if (digits.length <= 12) {
        formatted = '${digits.substring(0, 5)}-${digits.substring(5)}';
      } else {
        formatted =
            '${digits.substring(0, 5)}-${digits.substring(5, 12)}-${digits.substring(12, 13)}';
      }

      if (formatted != raw) {
        controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    });
  }

  Future<void> pickFromGallery() async {
    try {
      final img = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (img != null) {
        data.pickedImage = img;
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
    }
  }

  String? validateCnic(String? val) {
    final value = val?.trim() ?? '';
    if (value.isEmpty) return 'Enter CNIC';
    if (value.length != 15 || !_cnicRegex.hasMatch(value)) {
      return 'Invalid CNIC format (xxxxx-xxxxxxx-x)';
    }
    return null;
  }

  bool validateRequired(String? val) {
    return val != null && val.trim().isNotEmpty;
  }

  String? validateRequiredField(String? val, String fieldName) {
    if (!validateRequired(val)) {
      return 'Please enter your $fieldName';
    }
    return null;
  }

  // Update profile data
  Future<bool> updateProfile() async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, this would make an API call with data.toMap()
      // For now, just return success
      debugPrint('Profile updated: ${data.toMap()}');
      return true;
    } catch (e) {
      debugPrint('Profile update error: $e');
      return false;
    }
  }

  // Check if form has changes
  bool hasChanges() {
    return data.hasChanges;
  }

  // Clear picked image
  void clearImage() {
    data.clearImage();
  }

  // Validate entire form
  bool validateForm({
    required String? name,
    required String? cnic,
    required String? country,
    required String? state,
    required String? city,
    required String? address,
  }) {
    return validateRequired(name) &&
           validateRequired(country) &&
           validateRequired(state) &&
           validateRequired(city) &&
           validateRequired(address) &&
           (cnic == null || cnic.isEmpty || _cnicRegex.hasMatch(cnic));
  }
}
