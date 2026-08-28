import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/storage/api_constants.dart';
import '../Setting_Model/currency_context_model.dart';

class CurrencyApiService {
  static const String baseUrl = ApiConstants.baseUrl;
  static const String currencyContextEndpoint = "/currency/context";

  final Dio _dio;

  CurrencyApiService({Dio? dio})
      : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        ),
      );

  Future<CurrencyContextModel> fetchCurrencyContext({
    String locale = 'en-US',
  }) async {
    try {
      debugPrint("🌍 Fetching Currency Context...");
      debugPrint("Locale: $locale");

      final response = await _dio.get(
        currencyContextEndpoint,
        queryParameters: {
          "locale": locale,
        },
      );

      debugPrint("✅ Currency Context Loaded");
      debugPrint(response.data.toString());

      return CurrencyContextModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      debugPrint("❌ Dio Error: ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("❌ Currency API Error: $e");
      rethrow;
    }
  }
}