class Diamond {
  final String id;
  final String name;
  final double carat;
  final String cut;
  final String color;
  final String clarity;
  final double price;
  final String imageUrl;
  final bool isLabGrown;
  final String certificate;
  final int stock;

  Diamond({
    required this.id,
    required this.name,
    required this.carat,
    required this.cut,
    required this.color,
    required this.clarity,
    required this.price,
    required this.imageUrl,
    this.isLabGrown = false,
    this.certificate = 'GIA',
    this.stock = 1,
  });

  factory Diamond.fromJson(Map<String, dynamic> json) {
    return Diamond(
      id: json['id'],
      name: json['name'],
      carat: json['carat'],
      cut: json['cut'],
      color: json['color'],
      clarity: json['clarity'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      isLabGrown: json['isLabGrown'] ?? false,
      certificate: json['certificate'] ?? 'GIA',
      stock: json['stock'] ?? 1,
    );
  }
}