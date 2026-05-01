class College {
  final String? id;
  final String? name;

  College({this.id, this.name});

  factory College.fromJson(Map<String, dynamic> json) {
    return College(
      id: json['_id']?.toString(),
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
      };
}
