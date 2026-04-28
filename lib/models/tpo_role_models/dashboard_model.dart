/// TPO Dashboard Model for API response
/// Handles GET /api/v1/dashboard/tpo response structure
class TpoDashboardModel {
  final bool success;
  final DashboardData data;

  TpoDashboardModel({required this.success, required this.data});

  /// Create model from JSON response
  factory TpoDashboardModel.fromJson(Map<String, dynamic> json) {
    return TpoDashboardModel(
      success: json['success'] ?? false,
      data: DashboardData.fromJson(json['data'] ?? {}),
    );
  }

  /// Convert model to JSON (if needed for API requests)
  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

/// Dashboard data container
class DashboardData {
  final DashboardSummary summary;
  final List<UpcomingDrive> upcomingDrives;
  final List<DepartmentPlacement> departmentPlacement;

  DashboardData({
    required this.summary,
    required this.upcomingDrives,
    required this.departmentPlacement,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      summary: DashboardSummary.fromJson(json['summary'] ?? {}),
      upcomingDrives:
          (json['upcomingDrives'] as List<dynamic>?)
              ?.map(
                (item) => UpcomingDrive.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      departmentPlacement:
          (json['departmentPlacement'] as List<dynamic>?)
              ?.map(
                (item) =>
                    DepartmentPlacement.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'upcomingDrives': upcomingDrives.map((drive) => drive.toJson()).toList(),
      'departmentPlacement': departmentPlacement
          .map((dept) => dept.toJson())
          .toList(),
    };
  }
}

/// Dashboard summary statistics
class DashboardSummary {
  final int activeDrives;
  final int closingSoon;
  final int totalStudents;
  final int profileCompletion;
  final int offersExtended;
  final int weeklyOffers;
  final int studentsPlaced;
  final double placementRate;

  DashboardSummary({
    required this.activeDrives,
    required this.closingSoon,
    required this.totalStudents,
    required this.profileCompletion,
    required this.offersExtended,
    required this.weeklyOffers,
    required this.studentsPlaced,
    required this.placementRate,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      activeDrives: json['activeDrives'] ?? 0,
      closingSoon: json['closingSoon'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      profileCompletion: json['profileCompletion'] ?? 0,
      offersExtended: json['offersExtended'] ?? 0,
      weeklyOffers: json['weeklyOffers'] ?? 0,
      studentsPlaced: json['studentsPlaced'] ?? 0,
      placementRate: (json['placementRate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeDrives': activeDrives,
      'closingSoon': closingSoon,
      'totalStudents': totalStudents,
      'profileCompletion': profileCompletion,
      'offersExtended': offersExtended,
      'weeklyOffers': weeklyOffers,
      'studentsPlaced': studentsPlaced,
      'placementRate': placementRate,
    };
  }
}

/// Upcoming drive information
class UpcomingDrive {
  final String? id;
  final String? company;
  final String? role;
  final String? driveDate;
  final int? eligibleCount;

  UpcomingDrive({
    this.id,
    this.company,
    this.role,
    this.driveDate,
    this.eligibleCount,
  });

  factory UpcomingDrive.fromJson(Map<String, dynamic> json) {
    return UpcomingDrive(
      id: json['_id']?.toString(), // FIXED
      company: json['company']?.toString(),
      role: json['role']?.toString(),
      driveDate: json['driveDate']?.toString(), // FIXED
      eligibleCount: json['eligibleCount'] as int?, // FIXED
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'company': company,
      'role': role,
      'driveDate': driveDate,
      'eligibleCount': eligibleCount,
    };
  }
}

/// Department placement data
class DepartmentPlacement {
  final String? branch;
  final double? percentage;

  DepartmentPlacement({this.branch, this.percentage});

  factory DepartmentPlacement.fromJson(Map<String, dynamic> json) {
    return DepartmentPlacement(
      branch: json['branch']?.toString(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'branch': branch, 'percentage': percentage};
  }
}
