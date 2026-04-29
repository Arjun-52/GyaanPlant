class PrepPack {
  final String id;
  final String title;
  final String description;
  final double price;

  PrepPack({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });

  factory PrepPack.fromJson(Map<String, dynamic> json) {
    return PrepPack(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? json['name'] ?? 'No Title',
      description: json['description'] ?? '',
      price: _parsePrice(json['price']),
    );
  }

  static double _parsePrice(dynamic price) {
    if (price is num) return price.toDouble();
    if (price is String) return double.tryParse(price) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'price': price,
    };
  }

  @override
  String toString() {
    return 'PrepPack(id: $id, title: $title, price: ₹$price)';
  }
}
