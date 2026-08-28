import 'package:dio/dio.dart';
import 'package:kdt/core/storage/api_constants.dart';

import '../../../core/storage/secure_storage.dart';

class AddressApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'x-language': 'en',
      },
    ),
  );

  Future<Map<String, dynamic>> getAddresses() async {
    final token = await SecureStorage.getToken();

    final response = await _dio.get(
      '/addresses',
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> createAddress(
      Map<String, dynamic> body) async {
    final token = await SecureStorage.getToken();

    final response = await _dio.post(
      '/addresses',
      data: body,
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> updateAddress(
      String id,
      Map<String, dynamic> body,
      ) async {
    final token = await SecureStorage.getToken();

    final response = await _dio.put(
      '/addresses/$id',
      data: body,
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return response.data;
  }

  Future<Map<String, dynamic>> deleteAddress(
      String id,
      ) async {
    final token = await SecureStorage.getToken();

    final response = await _dio.delete(
      '/addresses/$id',
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
        },
      ),
    );

    return response.data;
  }
}