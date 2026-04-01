class AccountData {
  String? fullName;
  String? email;
  String? phone;
  String? cnic;
  String? avatarUrl;
  String? address;
  String? city;
  String? stateProvince;
  String? country;

  AccountData({
    this.fullName = 'John Doe',
    this.email = 'john.doe@example.com',
    this.phone = '+92 300 1234567',
    this.cnic = '12345-6789012-3',
    this.avatarUrl,
    this.address = '123 Main Street',
    this.city = 'Karachi',
    this.stateProvince = 'Sindh',
    this.country = 'Pakistan',
  });

  // Create a copy with updated fields
  AccountData copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? cnic,
    String? avatarUrl,
    String? address,
    String? city,
    String? stateProvince,
    String? country,
  }) {
    return AccountData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      cnic: cnic ?? this.cnic,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      city: city ?? this.city,
      stateProvince: stateProvince ?? this.stateProvince,
      country: country ?? this.country,
    );
  }

  // Check if profile is complete
  bool get isProfileComplete {
    return fullName != null &&
           email != null &&
           phone != null &&
           cnic != null &&
           address != null &&
           city != null &&
           stateProvince != null &&
           country != null;
  }

  // Get display name (fallback to email username)
  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    if (email != null && email!.isNotEmpty) {
      return email!.split('@').first;
    }
    return 'User';
  }

  // Get initials for avatar fallback
  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final names = fullName!.trim().split(' ');
      if (names.length >= 2) {
        return '${names.first[0]}${names.last[0]}'.toUpperCase();
      }
      return names.first[0].toUpperCase();
    }
    return 'U';
  }

  @override
  String toString() {
    return 'AccountData(fullName: $fullName, email: $email, phone: $phone)';
  }
}
