class CourseModel {
  final String title;
  final String? thumbnail;
  final int totalModules;

  CourseModel({
    required this.title,
    this.thumbnail,
    required this.totalModules,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'],
      totalModules: json['totalModules'] ?? 0,
    );
  }
}
