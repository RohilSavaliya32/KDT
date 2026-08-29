import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:kdt/core/storage/api_constants.dart';
import 'package:path/path.dart' as p;

import '../../../core/storage/secure_storage.dart';

class PaymentConfirmationApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        "Accept": "application/json",
        "x-language": "en",
      },
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
    ),
  );

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) return Map<String, dynamic>.from(jsonDecode(data));
    throw Exception("Invalid response format");
  }

  Future<Options> _authOptions({String? contentType}) async {
    final token = await SecureStorage.getToken();

    return Options(
      contentType: contentType,
      headers: {
        if (token != null && token.isNotEmpty)
          "Authorization": "Bearer $token",
      },
    );
  }

  /// ===========================
  /// PLACE ORDER + PAYMENT PROOF
  /// ===========================
  Future<Map<String, dynamic>> placeOrder({
    required Map<String, dynamic> payload,
    required String screenshotPath,
    required String utrNumber,
    required String bankName,
    required String amount,
    required String transferDate,
  }) async {
    try {
      final formData = FormData.fromMap({
        "customerName": payload["customerName"],
        "customerEmail": payload["customerEmail"],
        "customerPhone": payload["customerPhone"],

        "shippingAddress": jsonEncode(payload["shippingAddress"]),
        "subtotal": payload["subtotal"],

        "items": jsonEncode(payload["items"]),

        "total": payload["total"],
        "couponCode": payload["couponCode"] ?? "",
        "discountAmount": payload["discountAmount"] ?? 0,

        "displayCurrency": payload["displayCurrency"],
        "exchangeRate": payload["exchangeRate"],
        "pricingLocale": payload["pricingLocale"],
        "pricingCountry": payload["pricingCountry"],

        "paymentMethod": payload["paymentMethod"],

        "utrNumber": utrNumber,
        "bankName": bankName,
        "amount": amount,
        "transferDate": transferDate,

        "screenshot": await MultipartFile.fromFile(
          screenshotPath,
          filename: p.basename(screenshotPath),
        ),
      });

      debugPrint("========== ORDER REQUEST ==========");
      debugPrint("URL => /orders");

      for (final field in formData.fields) {
        debugPrint("${field.key} => ${field.value}");
      }

      debugPrint("Screenshot => $screenshotPath");

      final response = await _dio.post(
        "/orders",
        data: formData,
        options: await _authOptions(
          contentType: Headers.multipartFormDataContentType,
        ),
      );

      debugPrint("========== ORDER RESPONSE ==========");
      debugPrint("${response.statusCode}");
      debugPrint(response.data.toString());

      return _toMap(response.data);
    } on DioException catch (e) {
      debugPrint("========== ORDER ERROR ==========");
      debugPrint("STATUS => ${e.response?.statusCode}");
      debugPrint("DATA => ${e.response?.data}");

      final data = e.response?.data;

      if (data is Map && data["message"] != null) {
        throw Exception(data["message"]);
      }

      throw Exception(e.message ?? "Order place failed");
    } catch (e) {
      throw Exception("Order place failed: $e");
    }
  }

  /// ===========================
  /// SUBMIT PAYMENT PROOF ONLY
  /// ===========================
  Future<Map<String, dynamic>> submitPaymentProof({
    required String orderId,
    required String screenshotPath,
    required String utrNumber,
    required String bankName,
    required String amount,
    required String transferDate,
  }) async {
    try {
      final formData = FormData.fromMap({
        "utrNumber": utrNumber,
        "bankName": bankName,
        "amount": amount,
        "transferDate": transferDate,
        "screenshot": await MultipartFile.fromFile(
          screenshotPath,
          filename: p.basename(screenshotPath),
        ),
      });

      final response = await _dio.post(
        ApiConstants.uploadPaymentProof(orderId),
        data: formData,
        options: await _authOptions(
          contentType: Headers.multipartFormDataContentType,
        ),
      );

      return _toMap(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data["message"] != null) {
        throw Exception(data["message"]);
      }
      throw Exception(e.message ?? "Payment proof upload failed");
    } catch (e) {
      throw Exception("Payment proof upload failed: $e");
    }
  }

  /// ===========================
  /// ORDER DETAILS
  /// ===========================
  Future<Map<String, dynamic>> getOrderDetails(
      String orderId,
      ) async {
    try {
      final response = await _dio.get(
        "/orders/$orderId",
        options: await _authOptions(),
      );

      return _toMap(response.data);
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map && data["message"] != null) {
        throw Exception(data["message"]);
      }

      throw Exception(e.message ?? "Order details fetch failed");
    } catch (e) {
      throw Exception("Order details fetch failed: $e");
    }
  }
}