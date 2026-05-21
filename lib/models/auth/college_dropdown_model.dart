/// Lightweight model used exclusively for the registration flow college dropdown.
///
/// Only [id], [name], and [city] are parsed from the API response.
/// All other fields returned by GET /api/v1/colleges are intentionally ignored.
class CollegeDropdownModel {
  final String id;
  final String name;
  final String city;

  const CollegeDropdownModel({
    required this.id,
    required this.name,
    required this.city,
  });

  factory CollegeDropdownModel.fromJson(Map<String, dynamic> json) {
    return CollegeDropdownModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
    );
  }

  /// Display label shown in the dropdown.
  String get label => '$name ($city)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollegeDropdownModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
