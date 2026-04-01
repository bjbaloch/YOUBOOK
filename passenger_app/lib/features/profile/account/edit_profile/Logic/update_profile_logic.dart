import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/services/file_upload_service.dart';
import '../../../../../core/services/profile_storage_service.dart';
import '../../../../../core/models/user.dart';
import '../../account_page/Data/account_page_data.dart';
import '../Data/update_profile_data.dart';

class EditProfileLogic {
  final EditProfileData data = EditProfileData();
  final ImagePicker _picker = ImagePicker();
  final RegExp _cnicRegex = RegExp(r'^\d{5}-\d{7}-\d$');

  // Initialize with existing account data
  void initializeWithAccountData(dynamic accountData) {
    data.fullName = accountData?.fullName;
    data.phone = accountData?.phone;
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
  Future<bool> updateProfile(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      String? avatarUrl = currentUser.avatarUrl;

      // Upload avatar if a new image was picked
      if (data.pickedImage != null) {
        print('EditProfileLogic: Uploading avatar...');
        try {
          avatarUrl = await FileUploadService.uploadFile(
            data.imageFile!,
            'avatars',
            folder: 'user_avatars',
          );

          if (avatarUrl == null) {
            throw Exception('Upload returned null URL');
          }
          print('EditProfileLogic: Avatar uploaded successfully: $avatarUrl');
        } catch (e) {
          print('EditProfileLogic: Avatar upload failed: $e');
          // Re-throw with the specific error message
          throw Exception('Unable to upload profile picture: ${e.toString()}');
        }
      }

      // Create updated user model with new data
      final updatedUser = currentUser.copyWith(
        fullName: data.fullName,
        phoneNumber:
            data.phone, // Note: this field doesn't exist in EditProfileData
        avatarUrl: avatarUrl,
        cnic: data.cnic,
        address: data.address,
        city: data.city,
        stateProvince: data.stateProvince,
        country: data.country,
      );

      // Update profile in database
      final authService = AuthService();
      final success = await authService.updateProfile(updatedUser);

      if (success) {
        // Update local storage
        await ProfileStorageService.saveAccountData(
          AccountData(
            fullName: data.fullName,
            email: currentUser.email,
            phone: data.phone,
            cnic: data.cnic,
            avatarUrl: avatarUrl,
            address: data.address,
            city: data.city,
            stateProvince: data.stateProvince,
            country: data.country,
          ),
        );

        // Update auth provider
        await authProvider.updateProfile(updatedUser);
      }

      return success;
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
