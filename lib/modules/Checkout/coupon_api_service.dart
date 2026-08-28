import 'package:dio/dio.dart';
import 'package:kdt/core/storage/api_constants.dart';

class CouponApiService {
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

  Future<Map<String, dynamic>> fetchAvailableCoupons() async {
    final response = await _dio.get("/coupons/available");
    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw Exception("Invalid coupon response");
  }
}