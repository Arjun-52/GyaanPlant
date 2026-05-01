class MentorModel {
  final String id;
  final String name;
  final String email;
  final String designation;
  final String company;
  final int rate;
  final bool isAvailable;
  final double rating;

  MentorModel({
    required this.id,
    required this.name,
    required this.email,
    required this.designation,
    required this.company,
    required this.rate,
    required this.isAvailable,
    required this.rating,
  });

  factory MentorModel.fromJson(Map<String, dynamic> json) {
    return MentorModel(
      id: json['_id'] ?? '',
      name: json['user']?['name'] ?? 'Unknown',
      email: json['user']?['email'] ?? '',
      designation: json['designation'] ?? '',
      company: json['company'] ?? '',
      rate: json['rate'] ?? 0,
      isAvailable: json['isAvailable'] ?? false,
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}
