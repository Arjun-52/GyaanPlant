/// Notification model for handling notification data
class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String category;
  final bool read;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? icon;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.category,
    required this.read,
    required this.createdAt,
    this.readAt,
    this.icon,
  });

  /// Create NotificationModel from JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationModel(
        id: json['_id'] as String? ?? json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        message: json['message'] as String? ?? json['body'] as String? ?? '',
        type: json['type'] as String? ?? 'info',
        category: json['category'] as String? ?? 'general',
        read: json['read'] as bool? ?? false,
        createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
        readAt: json['readAt'] != null ? _parseDateTime(json['readAt']) : null,
        icon: json['icon'] as String?,
      );
    } catch (e) {
      print("❌ Error parsing NotificationModel from JSON: $e");
      print("📦 JSON data: $json");
      rethrow;
    }
  }

  /// Convert NotificationModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'message': message,
      'type': type,
      'category': category,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'icon': icon,
    };
  }

  /// Parse DateTime from various formats
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) {
      return DateTime.now();
    }
    
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        print("⚠️ Error parsing date string: $dateValue");
        return DateTime.now();
      }
    }
    
    if (dateValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(dateValue);
    }
    
    return DateTime.now();
  }

  /// Get formatted date string (e.g., "APR 27, 2026")
  String get formattedDate {
    final months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
  }

  /// Get formatted time string (e.g., "2:30 PM")
  String get formattedTime {
    final hour = createdAt.hour;
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    
    return '$displayHour:$minute $period';
  }

  /// Get read status text
  String get readStatusText => read ? 'ACKNOWLEDGED' : 'PENDING';

  /// Create a copy with updated values
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? category,
    bool? read,
    DateTime? createdAt,
    DateTime? readAt,
    String? icon,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      category: category ?? this.category,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      icon: icon ?? this.icon,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, read: $read, formattedDate: $formattedDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
