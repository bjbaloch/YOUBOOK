import 'package:uuid/uuid.dart';

class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? cnic;
  final String role;
  final String? companyName;
  final String? credentialDetails;
  final String? managerId;
  final String? address;
  final String? city;
  final String? stateProvince;
  final String? country;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    String? id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.cnic,
    this.role = 'passenger',
    this.companyName,
    this.credentialDetails,
    this.managerId,
    this.address,
    this.city,
    this.stateProvince,
    this.country,
    this.createdAt,
    this.updatedAt,
  }) : id = id ?? const Uuid().v4();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
      cnic: json['cnic']?.toString(),
      role: json['role']?.toString() ?? 'passenger',
      companyName: json['company_name']?.toString(),
      credentialDetails: json['credential_details']?.toString(),
      managerId: json['manager_id']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      stateProvince: json['state_province']?.toString(),
      country: json['country']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'cnic': cnic,
      'role': role,
      'company_name': companyName,
      'credential_details': credentialDetails,
      'manager_id': managerId,
      'address': address,
      'city': city,
      'state_province': stateProvince,
      'country': country,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? cnic,
    String? role,
    String? companyName,
    String? credentialDetails,
    String? managerId,
    String? address,
    String? city,
    String? stateProvince,
    String? country,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      cnic: cnic ?? this.cnic,
      role: role ?? this.role,
      companyName: companyName ?? this.companyName,
      credentialDetails: credentialDetails ?? this.credentialDetails,
      managerId: managerId ?? this.managerId,
      address: address ?? this.address,
      city: city ?? this.city,
      stateProvince: stateProvince ?? this.stateProvince,
      country: country ?? this.country,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPassenger => role == 'passenger';
  bool get isManager => role == 'manager';
  bool get isDriver => role == 'driver';

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.role == role;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode ^ fullName.hashCode ^ role.hashCode;
  }
}
