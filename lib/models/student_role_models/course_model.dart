class CourseModel {
  final String title;
  final String? thumbnail;
  final int totalModules;
  final int progress; // percentage (0–100)
  final int completedModules;

  CourseModel({
    required this.title,
    this.thumbnail,
    required this.totalModules,
    required this.progress,
    required this.completedModules,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final enrollment = json['enrollment'];

    final int progress = (enrollment != null && enrollment['progress'] is num)
        ? (enrollment['progress'] as num).toInt()
        : 0;

    final int completedLectures =
        (enrollment != null && enrollment['completedLectures'] is List)
        ? (enrollment['completedLectures'] as List).length
        : 0;

    return CourseModel(
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'],
      totalModules: json['totalModules'] ?? 0,
      progress: progress,
      completedModules: completedLectures,
    );
  }
}
