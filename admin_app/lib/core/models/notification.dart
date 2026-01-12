class NotificationModel {
  final String? id;
  final String? userId;
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? data;
  final bool? isRead;
  final DateTime? createdAt;

  NotificationModel({
    this.id,
    this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      data: json['data'],
      isRead: json['is_read'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'data': data ?? {},
    };
  }
}

class NotificationCreate {
  final String title;
  final String message;
  final String type;

  NotificationCreate({
    required this.title,
    required this.message,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'type': type,
    };
  }
}