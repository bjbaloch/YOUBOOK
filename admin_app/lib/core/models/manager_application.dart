class ManagerApplication {
  final String id;
  final String userId;
  final String companyName;
  final String credentialDetails;
  final String status; // 'pending', 'approved', 'rejected'
  final String? reviewNotes;
  final String? reviewedBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Related user data
  final String? userEmail;
  final String? userFullName;

  ManagerApplication({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.credentialDetails,
    required this.status,
    this.reviewNotes,
    this.reviewedBy,
    required this.createdAt,
    this.updatedAt,
    this.userEmail,
    this.userFullName,
  });

  factory ManagerApplication.fromJson(Map<String, dynamic> json) {
    return ManagerApplication(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      companyName: json['company_name'] ?? '',
      credentialDetails: json['credential_details'] ?? '',
      status: json['status'] ?? 'pending',
      reviewNotes: json['review_notes'],
      reviewedBy: json['reviewed_by'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      userEmail: json['profiles']?['email'],
      userFullName: json['profiles']?['full_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'company_name': companyName,
      'credential_details': credentialDetails,
      'status': status,
      'review_notes': reviewNotes,
      'reviewed_by': reviewedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}