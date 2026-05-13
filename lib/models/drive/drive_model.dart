import 'package:gyaanplant/core/utils/app_logger.dart';

class Pagination {
  final int total;
  final int page;
  final int pages;

  const Pagination({
    required this.total,
    required this.page,
    required this.pages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json['total'] as int? ?? 0,
    page: json['page'] as int? ?? 1,
    pages: (json['pages'] ?? json['totalPages']) as int? ?? 0,
  );
}

class DriveModel {
  final String id;
  final String? companyName;
  final String? role;
  final String? location;
  final String? salary;
  final int? matchPercentage;
  final List<String>? skills;
  final bool? isNew;
  final String? description;
  final String? type;
  final String? status;
  final String? applicationDeadline;
  final String createdAt;
  final String updatedAt;

  const DriveModel({
    required this.id,
    this.companyName,
    this.role,
    this.location,
    this.salary,
    this.matchPercentage,
    this.skills,
    this.isNew,
    this.description,
    this.type,
    this.status,
    this.applicationDeadline,
    required this.createdAt,
    required this.updatedAt,
  });

  // View compatibility aliases
  String get title => role ?? 'No Role';
  String get company => companyName ?? 'Unknown Company';
  String get match => matchPercentage != null ? '$matchPercentage%' : '0%';

  factory DriveModel.fromJson(Map<String, dynamic> json) {
    try {
      return DriveModel(
        id: json['_id'] as String? ?? '',
        companyName: json['companyName'] as String?,
        role: json['role'] as String?,
        location: json['location'] as String?,
        salary: json['salary'] as String?,
        matchPercentage: json['matchPercentage'] as int?,
        skills: (json['skills'] as List<dynamic>?)?.cast<String>(),
        isNew: json['isNew'] as bool?,
        description: json['description'] as String?,
        type: json['type'] as String?,
        status: json['status'] as String?,
        applicationDeadline: json['applicationDeadline'] as String?,
        createdAt:
            json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
        updatedAt:
            json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      );
    } catch (e) {
      AppLogger.warning('DriveModel', 'fromJson error on ${json['_id']}: $e');
      return DriveModel(
        id: json['_id'] as String? ?? '',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
    }
  }
}

class DriveListResponse {
  final List<DriveModel> drives;
  final Pagination pagination;

  const DriveListResponse({required this.drives, required this.pagination});
}
