class Pagination {
  final int total;
  final int page;
  final int pages;

  const Pagination({required this.total, required this.page, required this.pages});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        total: json['total'] as int? ?? 0,
        page: json['page'] as int? ?? 1,
        pages: (json['pages'] ?? json['totalPages']) as int? ?? 0,
      );
}

class DriveModel {
  final String id;
  final String title;
  final String? company;
  final String? description;
  final String? location;
  final String? type;
  final String? status;
  final String? applicationDeadline;
  final String createdAt;
  final String updatedAt;

  const DriveModel({
    required this.id,
    required this.title,
    this.company,
    this.description,
    this.location,
    this.type,
    this.status,
    this.applicationDeadline,
    required this.createdAt,
    required this.updatedAt,
  });

  // View compatibility aliases
  String get role => title;
  String get companyName => company ?? '';

  factory DriveModel.fromJson(Map<String, dynamic> json) => DriveModel(
        id: json['_id'] as String,
        title: json['title'] as String,
        company: json['company'] as String?,
        description: json['description'] as String?,
        location: json['location'] as String?,
        type: json['type'] as String?,
        status: json['status'] as String?,
        applicationDeadline: json['applicationDeadline'] as String?,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
      );
}

class DriveListResponse {
  final List<DriveModel> drives;
  final Pagination pagination;

  const DriveListResponse({required this.drives, required this.pagination});
}
