import 'package:dio/dio.dart';
import 'package:kdt/core/storage/api_constants.dart';

import '../../../core/storage/secure_storage.dart';
import '../Model/Review_Model.dart';

class ReviewApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'x-language': 'en',
      },
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
    ),
  );

  Future<Map<String, String>> _authHeaders() async {
    final token = await SecureStorage.getToken();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<ReviewModel>> getReviews(String diamondId) async {
    try {
      print('===== GET REVIEWS API =====');
      print('Diamond ID: $diamondId');

      final response = await _dio.get('/reviews/$diamondId');

      print('Status Code: ${response.statusCode}');
      print('Raw Response Type: ${response.data.runtimeType}');
      print('Raw Response Data: ${response.data}');

      final data = ReviewListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      print('Parsed Reviews Count: ${data.data.length}');
      for (int i = 0; i < data.data.length; i++) {
        final review = data.data[i];
        print('--- Review #$i ---');
        print('id: ${review.id}');
        print('userId: ${review.userId}');
        print('userName: ${review.user?.name}');
        print('rating: ${review.rating}');
        print('comment: ${review.comment}');
        print('createdAt: ${review.createdAt}');
      }

      return data.data;
    } catch (e) {
      print('GET REVIEWS ERROR => $e');
      rethrow;
    }
  }

  Future<ReviewModel?> submitOrUpdateReview({
    required String diamondId,
    required double rating,
    required String comment,
    String? reviewId,
  }) async {
    final headers = await _authHeaders();

    final payload = <String, dynamic>{
      'diamondId': diamondId,
      'rating': rating,
      'comment': comment,
    };

    final id = reviewId?.trim();
    if (id != null && id.isNotEmpty) {
      payload['reviewId'] = id;
      payload['id'] = id;
    }

    try {
      print('===== POST REVIEW API =====');
      print('URL => /reviews');
      print('Payload => $payload');

      final response = await _dio.post(
        '/reviews',
        data: payload,
        options: Options(headers: headers),
      );

      print('Status Code => ${response.statusCode}');
      print('Response Data => ${response.data}');

      if (response.data == null) {
        print('Error: Response data is null');
        return null;
      }

      final result = ReviewSingleResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      
      if (!result.success) {
        print('API Error Message: ${result.message}');
      }
      
      return result.data;
    } on DioException catch (e) {
      print('SUBMIT/UPDATE REVIEW API DIO ERROR => ${e.type}');
      print('Error Response => ${e.response?.data}');
      print('Error Status => ${e.response?.statusCode}');
      rethrow;
    } catch (e) {
      print('SUBMIT/UPDATE REVIEW API UNKNOWN ERROR => $e');
      rethrow;
    }
  }
}