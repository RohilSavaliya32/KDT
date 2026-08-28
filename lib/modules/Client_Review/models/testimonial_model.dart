class Testimonial {
  final dynamic id;
  final String name;
  final String location;
  final String diamond;
  final double rating;
  final String text;
  final String? image;
  final String? profileImage;
  final DateTime? date;
  final bool verified;

  Testimonial({
    required this.id,
    required this.name,
    required this.location,
    required this.diamond,
    required this.rating,
    required this.text,
    this.image,
    this.profileImage,
    this.date,
    this.verified = false,
  });

  factory Testimonial.fromJson(Map<String, dynamic> json) {
    return Testimonial(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name']?.toString() ?? json['clientName']?.toString() ?? json['fullName']?.toString() ?? '',
      location: json['location']?.toString() ?? json['city']?.toString() ?? json['place']?.toString() ?? '',
      diamond: json['purchase']?.toString() ??
          json['diamond']?.toString() ??
          json['stone']?.toString() ??
          json['product']?.toString() ??
          '',
      rating: (json['rating'] ?? json['stars'] ?? 0).toDouble(),
      text: json['text']?.toString() ?? json['review']?.toString() ?? json['comment']?.toString() ?? json['message']?.toString() ?? '',
      image: json['image']?.toString() ?? json['avatar']?.toString() ?? json['photo']?.toString(),
      profileImage: json['profileImage']?.toString() ??
          json['profile_image']?.toString() ??
          json['userImage']?.toString() ??
          json['user_image']?.toString(),
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      verified: json['verified'] ?? json['isVerified'] ?? false,
    );
  }

  static List<Testimonial> fromJsonList(dynamic data) {
    if (data == null) return [];

    if (data is List) {
      return data.map((item) {
        if (item is Map<String, dynamic>) {
          return Testimonial.fromJson(item);
        }
        return Testimonial.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    } else if (data is Map) {
      // Handle different response structures
      if (data['data'] is List) {
        return (data['data'] as List).map((item) {
          if (item is Map<String, dynamic>) {
            return Testimonial.fromJson(item);
          }
          return Testimonial.fromJson(Map<String, dynamic>.from(item));
        }).toList();
      } else if (data['testimonials'] is List) {
        return (data['testimonials'] as List).map((item) {
          if (item is Map<String, dynamic>) {
            return Testimonial.fromJson(item);
          }
          return Testimonial.fromJson(Map<String, dynamic>.from(item));
        }).toList();
      } else if (data['results'] is List) {
        return (data['results'] as List).map((item) {
          if (item is Map<String, dynamic>) {
            return Testimonial.fromJson(item);
          }
          return Testimonial.fromJson(Map<String, dynamic>.from(item));
        }).toList();
      } else if (data['id'] != null || data['_id'] != null) {
        // Convert Map<dynamic, dynamic> to Map<String, dynamic>
        Map<String, dynamic> convertedMap = {};
        data.forEach((key, value) {
          convertedMap[key.toString()] = value;
        });
        return [Testimonial.fromJson(convertedMap)];
      }
    }
    return [];
  }
}