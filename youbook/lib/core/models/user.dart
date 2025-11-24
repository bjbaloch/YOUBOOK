import 'package:uuid/uuid.dart';

class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role;
  final String? managerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    String? id,
    required this.email,
    this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.role = 'passenger',
    this.managerId,
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
      role: json['role']?.toString() ?? 'passenger',
      managerId: json['manager_id']?.toString(),
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
      'role': role,
      'manager_id': managerId,
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
    String? role,
    String? managerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      managerId: managerId ?? this.managerId,
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
