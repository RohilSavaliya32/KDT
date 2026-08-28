import 'package:flutter/foundation.dart';

@immutable
class ReviewUser {
  final String id;
  final String name;
  final String? image;

  const ReviewUser({
    required this.id,
    required this.name,
    this.image,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ??
          json['fullName']?.toString() ??
          json['userName']?.toString() ??
          '',
      image: json['image']?.toString() ?? json['profile_image']?.toString(),
    );
  }
}

@immutable
class ReviewModel {
  final String id;
  final String userId;
  final String diamondId;
  final double rating;
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ReviewUser? user;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.diamondId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return ReviewModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      diamondId: json['diamondId']?.toString() ?? json['diamond_id']?.toString() ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      comment: json['comment']?.toString() ?? '',
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: parseDate(json['updatedAt'] ?? json['updated_at']),
      user: json['user'] is Map<String, dynamic>
          ? ReviewUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ReviewListResponse {
  final bool success;
  final String message;
  final List<ReviewModel> data;

  ReviewListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ReviewListResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    final list = <dynamic>[
      if (rawData is List) ...rawData,
      if (rawData is Map<String, dynamic> && rawData['reviews'] is List)
        ...rawData['reviews'] as List,
      if (rawData is Map<String, dynamic> && rawData['items'] is List)
        ...rawData['items'] as List,
    ]
        .whereType<Map<String, dynamic>>()
        .map((e) => ReviewModel.fromJson(e))
        .toList();

    return ReviewListResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: list,
    );
  }
}

class ReviewSingleResponse {
  final bool success;
  final String message;
  final ReviewModel? data;

  ReviewSingleResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ReviewSingleResponse.fromJson(Map<String, dynamic> json) {
    return ReviewSingleResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? ReviewModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}