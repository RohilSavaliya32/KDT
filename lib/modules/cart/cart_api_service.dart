import 'package:dio/dio.dart';
import 'package:kdt/core/storage/api_constants.dart';

import '../../core/storage/secure_storage.dart';

class CartApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "x-language": "en",
      },
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
    ),
  );

  Map<String, dynamic> _normalizeResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data);
    }
    return {
      "success": false,
      "message": "Unexpected response",
      "data": data,
    };
  }

  Future<Map<String, dynamic>> fetchCart() async {
    final token = await SecureStorage.getToken();

    if (token == null || token.isEmpty) {
      return {
        "success": true,
        "message": "Guest cart",
        "data": {"cart": []},
      };
    }

    final response = await _dio.get(
      ApiConstants.profile,
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return _normalizeResponse(response.data);
  }

  Future<Map<String, dynamic>> updateCart(
      List<Map<String, dynamic>> cart,
      ) async {
    final token = await SecureStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token not found");
    }

    final response = await _dio.put(
      ApiConstants.cart,
      data: {
        "cart": cart,
      },
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return _normalizeResponse(response.data);
  }
}