class TpoNotificationModel {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  TpoNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  /// Parse individual notification from JSON with high resilience
  factory TpoNotificationModel.fromJson(Map<String, dynamic> json) {
    // Parse isRead from either 'isRead' or 'read'
    final bool readStatus = json['isRead'] as bool? ?? json['read'] as bool? ?? false;
    
    // Parse message from 'message' or 'body'
    final String msgContent = json['message'] as String? ?? json['body'] as String? ?? '';

    // Parse createdAt or created_at safely
    DateTime parsedDate = DateTime.now();
    final rawDate = json['createdAt'] ?? json['created_at'];
    if (rawDate != null) {
      if (rawDate is String) {
        parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
      } else if (rawDate is int) {
        parsedDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
      }
    }

    return TpoNotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: msgContent,
      isRead: readStatus,
      createdAt: parsedDate,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class TpoNotificationResponse {
  final bool success;
  final List<TpoNotificationModel> notifications;
  final int total;
  final int page;

  TpoNotificationResponse({
    required this.success,
    required this.notifications,
    required this.total,
    required this.page,
  });

  /// Parse response container from JSON with high resilience
  /// Handles:
  /// 1. data as a Map containing notifications list (standard paginated structure)
  /// 2. data as a List of notifications directly (alternative direct list structure)
  /// 3. direct list structures
  factory TpoNotificationResponse.fromJson(Map<String, dynamic> json) {
    final success = json['success'] as bool? ?? false;
    final rawData = json['data'];
    
    Map<String, dynamic> dataMap = {};
    List<dynamic> list = [];

    if (rawData is Map<String, dynamic>) {
      dataMap = rawData;
      list = dataMap['notifications'] as List<dynamic>? ?? [];
    } else if (rawData is List<dynamic>) {
      list = rawData;
    } else if (json['notifications'] is List<dynamic>) {
      list = json['notifications'] as List<dynamic>;
    }

    return TpoNotificationResponse(
      success: success,
      notifications: list
          .map((e) {
            if (e is Map<String, dynamic>) {
              return TpoNotificationModel.fromJson(e);
            }
            return TpoNotificationModel(
              id: '',
              title: 'Unknown Alert',
              message: e?.toString() ?? '',
              isRead: true,
              createdAt: DateTime.now(),
            );
          })
          .toList(),
      total: dataMap['total'] is int 
          ? dataMap['total'] as int 
          : (json['total'] is int ? json['total'] as int : list.length),
      page: dataMap['page'] is int 
          ? dataMap['page'] as int 
          : (json['page'] is int ? json['page'] as int : 1),
    );
  }
}
