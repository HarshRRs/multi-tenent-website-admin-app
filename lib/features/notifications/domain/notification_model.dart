enum NotificationType {
  order,
  system,
  promotion,
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool,
      type: _parseType(json['type'] as String),
    );
  }

  static NotificationType _parseType(String type) {
    switch (type) {
      case 'order':
        return NotificationType.order;
      case 'promotion':
        return NotificationType.promotion;
      default:
        return NotificationType.system;
    }
  }
}
