// wishlist_model.dart
import 'dart:convert';

class WishlistResponse {
  final bool success;
  final String message;
  final List<WishlistItem> data;
  final Map<String, dynamic> meta;

  WishlistResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory WishlistResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    List<dynamic> items = [];
    if (rawData is List) {
      items = rawData;
    } else if (rawData is Map<String, dynamic>) {
      final wishlist = rawData['wishlist'];
      if (wishlist is List) {
        items = wishlist;
      } else if (rawData['data'] is List) {
        items = rawData['data'];
      }
    }

    return WishlistResponse(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: items
          .whereType<dynamic>()
          .map((item) => WishlistItem.fromJson(_asMap(item)))
          .toList(),
      meta: _asMap(json['meta']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
      'meta': meta,
    };
  }
}

class WishlistItem {
  final String id;
  final String cut;
  final String sku;
  final String slug;
  final int carat;
  final String color;
  final String image;
  final int price;
  final String shape;
  final String title;
  final List<String> images;
  final String polish;
  final String clarity;
  final int buyCount;
  final int quantity;
  final String? seoTitle;
  final String symmetry;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String certNumber;
  final bool isLabGrown;
  final int ratingCount;
  final int reviewCount;
  final String? seoKeywords;
  final int depthPercent;
  final String fluorescence;
  final Measurements measurements;
  final int tablePercent;
  final int averageRating;
  final String certification;
  final int originalPrice;
  final String? seoDescription;
  final String? certificateFile;
  final int discountPercent;
  final LocalizedContent localizedContent;

  WishlistItem({
    required this.id,
    required this.cut,
    required this.sku,
    required this.slug,
    required this.carat,
    required this.color,
    required this.image,
    required this.price,
    required this.shape,
    required this.title,
    required this.images,
    required this.polish,
    required this.clarity,
    required this.buyCount,
    required this.quantity,
    this.seoTitle,
    required this.symmetry,
    required this.createdAt,
    required this.updatedAt,
    required this.certNumber,
    required this.isLabGrown,
    required this.ratingCount,
    required this.reviewCount,
    this.seoKeywords,
    required this.depthPercent,
    required this.fluorescence,
    required this.measurements,
    required this.tablePercent,
    required this.averageRating,
    required this.certification,
    required this.originalPrice,
    this.seoDescription,
    this.certificateFile,
    required this.discountPercent,
    required this.localizedContent,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: _asString(json['id']),
      cut: _asString(json['cut']),
      sku: _asString(json['sku']),
      slug: _asString(json['slug']),
      carat: _asInt(json['carat']),
      color: _asString(json['color']),
      image: _asString(json['image']),
      price: _asInt(json['price']),
      shape: _asString(json['shape']),
      title: _asString(json['title']),
      images: _asStringList(json['images']),
      polish: _asString(json['polish']),
      clarity: _asString(json['clarity']),
      buyCount: _asInt(json['buyCount']),
      quantity: _asInt(json['quantity']),
      seoTitle: _asNullableString(json['seoTitle']),
      symmetry: _asString(json['symmetry']),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
      certNumber: _asString(json['certNumber']),
      isLabGrown: json['isLabGrown'] == true,
      ratingCount: _asInt(json['ratingCount']),
      reviewCount: _asInt(json['reviewCount']),
      seoKeywords: _asNullableString(json['seoKeywords']),
      depthPercent: _asInt(json['depthPercent']),
      fluorescence: _asString(json['fluorescence']),
      measurements: Measurements.fromJson(_asMap(json['measurements'])),
      tablePercent: _asInt(json['tablePercent']),
      averageRating: _asInt(json['averageRating']),
      certification: _asString(json['certification']),
      originalPrice: _asInt(json['originalPrice']),
      seoDescription: _asNullableString(json['seoDescription']),
      certificateFile: _asNullableString(json['certificateFile']),
      discountPercent: _asInt(json['discountPercent']),
      localizedContent:
      LocalizedContent.fromJson(_asMap(json['localizedContent'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cut': cut,
      'sku': sku,
      'slug': slug,
      'carat': carat,
      'color': color,
      'image': image,
      'price': price,
      'shape': shape,
      'title': title,
      'images': images,
      'polish': polish,
      'clarity': clarity,
      'buyCount': buyCount,
      'quantity': quantity,
      'seoTitle': seoTitle,
      'symmetry': symmetry,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'certNumber': certNumber,
      'isLabGrown': isLabGrown,
      'ratingCount': ratingCount,
      'reviewCount': reviewCount,
      'seoKeywords': seoKeywords,
      'depthPercent': depthPercent,
      'fluorescence': fluorescence,
      'measurements': measurements.toJson(),
      'tablePercent': tablePercent,
      'averageRating': averageRating,
      'certification': certification,
      'originalPrice': originalPrice,
      'seoDescription': seoDescription,
      'certificateFile': certificateFile,
      'discountPercent': discountPercent,
      'localizedContent': localizedContent.toJson(),
    };
  }

  int get discountPrice => price - originalPrice;
  int get availableQuantity => quantity;
  bool get isOutOfStock => quantity <= 0;
  bool get isInStock => quantity > 0;
  double get ratingAverage => averageRating.toDouble();
}

class Measurements {
  final int depth;
  final int width;
  final int length;

  Measurements({
    required this.depth,
    required this.width,
    required this.length,
  });

  factory Measurements.fromJson(Map<String, dynamic> json) {
    return Measurements(
      depth: _asInt(json['depth']),
      width: _asInt(json['width']),
      length: _asInt(json['length']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'depth': depth,
      'width': width,
      'length': length,
    };
  }

  String get displayString => '$length x $width x $depth mm';
}

class LocalizedContent {
  final String? name;
  final String? seoTitle;
  final String? shapeName;
  final String? cutDetails;
  final String? description;
  final String? seoKeywords;
  final String? seoDescription;
  final String? specifications;
  final String? marketingContent;
  final String? certificationInfo;

  LocalizedContent({
    this.name,
    this.seoTitle,
    this.shapeName,
    this.cutDetails,
    this.description,
    this.seoKeywords,
    this.seoDescription,
    this.specifications,
    this.marketingContent,
    this.certificationInfo,
  });

  factory LocalizedContent.fromJson(Map<String, dynamic> json) {
    return LocalizedContent(
      name: _asNullableString(json['name']),
      seoTitle: _asNullableString(json['seoTitle']),
      shapeName: _asNullableString(json['shapeName']),
      cutDetails: _asNullableString(json['cutDetails']),
      description: _asNullableString(json['description']),
      seoKeywords: _asNullableString(json['seoKeywords']),
      seoDescription: _asNullableString(json['seoDescription']),
      specifications: _asNullableString(json['specifications']),
      marketingContent: _asNullableString(json['marketingContent']),
      certificationInfo: _asNullableString(json['certificationInfo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'seoTitle': seoTitle,
      'shapeName': shapeName,
      'cutDetails': cutDetails,
      'description': description,
      'seoKeywords': seoKeywords,
      'seoDescription': seoDescription,
      'specifications': specifications,
      'marketingContent': marketingContent,
      'certificationInfo': certificationInfo,
    };
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

String _asString(dynamic value) => value?.toString() ?? '';

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final s = value.toString();
  return s.isEmpty ? null : s;
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime _asDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value == null) return DateTime.now();
  return DateTime.tryParse(value.toString()) ?? DateTime.now();
}

List<String> _asStringList(dynamic value) {
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  if (value is String && value.isNotEmpty) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}
  }
  return <String>[];
}