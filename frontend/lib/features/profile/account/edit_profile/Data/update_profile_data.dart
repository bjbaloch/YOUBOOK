import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfileData {
  String? fullName;
  String? cnic;
  String? address;
  String? city;
  String? stateProvince;
  String? country;
  XFile? pickedImage;

  EditProfileData({
    this.fullName,
    this.cnic,
    this.address,
    this.city,
    this.stateProvince,
    this.country,
    this.pickedImage,
  });

  // Initialize with existing data
  factory EditProfileData.fromAccountData(dynamic accountData) {
    return EditProfileData(
      fullName: accountData?.fullName,
      cnic: accountData?.cnic,
      address: accountData?.address,
      city: accountData?.city,
      stateProvince: accountData?.stateProvince,
      country: accountData?.country,
    );
  }

  File? get imageFile => pickedImage != null ? File(pickedImage!.path) : null;

  // Check if any field has been modified
  bool get hasChanges {
    return fullName != null ||
           cnic != null ||
           address != null ||
           city != null ||
           stateProvince != null ||
           country != null ||
           pickedImage != null;
  }

  // Convert to map for API calls
  Map<String, dynamic> toMap() {
    return {
      if (fullName != null) 'full_name': fullName,
      if (cnic != null) 'cnic': cnic,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (stateProvince != null) 'state_province': stateProvince,
      if (country != null) 'country': country,
    };
  }

  // Clear picked image
  void clearImage() {
    pickedImage = null;
  }
}
