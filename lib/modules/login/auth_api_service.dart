import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kdt/core/storage/api_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../Register/register_response_model.dart';
import 'check_user_response_model.dart';
import 'login_response_model.dart';

class AuthApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      headers: {
        'Content-Type': 'application/json',
        'x-language': 'en',
      },
    ),
  );

  String _extractErrorMessage(DioException e, String fallback) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['message'] is String && data['message'].toString().isNotEmpty) {
        return data['message'];
      }

      final error = data['error'];
      if (error is Map<String, dynamic>) {
        if (error['message'] is String &&
            error['message'].toString().isNotEmpty) {
          return error['message'];
        }

        final details = error['details'];
        if (details is Map<String, dynamic>) {
          if (details['message'] is String &&
              details['message'].toString().isNotEmpty) {
            return details['message'];
          }
        }
      }
    }

    return fallback;
  }

  Future<CheckUserResponse> checkUser(String identifier) async {
    try {
      final response = await _dio.post(
        ApiConstants.checkUser,
        data: {'identifier': identifier},
      );
      return CheckUserResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Check user failed'));
    }
  }

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Login failed'));
    }
  }

  Future<RegisterResponseModel> register({
    required String name,
    required String email,
    required String mobile,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'mobile': mobile,
          'password': password,
        },
      );
      return RegisterResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Register failed'));
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await _dio.post(
        ApiConstants.checkUser,
        data: {'identifier': email},
      );

      final result = CheckUserResponse.fromJson(response.data);
      return result.data.exists;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Email check failed'));
    }
  }
// 🆕 Add this method to your existing AuthApiService class
  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      final token = await SecureStorage.getToken();

      print("========== PROFILE IMAGE UPLOAD ==========");
      print("BASE URL : ${_dio.options.baseUrl}");
      print("BASE URL : ${_dio.options.baseUrl}");
      print("URL      : ${_dio.options.baseUrl}/auth/profile/image");
      print("TOKEN    : $token");
      print("PATH     : ${imageFile.path}");
      print("SIZE     : ${await imageFile.length()} bytes");

      final formData = FormData.fromMap({
        'profileImage': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        ApiConstants.profileImage,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            // ❌ Content-Type mat do
          },
        ),
      );

      print("STATUS   : ${response.statusCode}");
      print("RESPONSE : ${response.data}");
      print("=========================================");

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      print("========== IMAGE UPLOAD ERROR ==========");
      print("STATUS   : ${e.response?.statusCode}");
      print("DATA     : ${e.response?.data}");
      print("MESSAGE  : ${e.message}");
      print("========================================");

      throw Exception(
        e.response?.data?['message']?.toString() ??
            e.message ??
            'Image upload failed',
      );
    }
  }

  Future<bool> checkMobileExists(String mobile) async {
    try {
      final response = await _dio.post(
        ApiConstants.checkUser,
        data: {'identifier': mobile},
      );

      final result = CheckUserResponse.fromJson(response.data);
      return result.data.exists;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Mobile check failed'));
    }
  }

  Future<bool> logout() async {
    try {
      final token = await SecureStorage.getToken();

      final response = await _dio.post(
        ApiConstants.logout,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data['success'] == true;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Logout failed'));
    }
  }

  // Future<LoginResponse> firebaseLogin({
  //   required String idToken,
  // }) async {
  //   try {
  //     final response = await _dio.post(
  //       '/auth/firebase',
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $idToken',
  //         },
  //       ),
  //     );
  //     return LoginResponse.fromJson(response.data);
  //   } on DioException catch (e) {
  //     throw Exception(_extractErrorMessage(e, 'Firebase Login failed'));
  //   }
  // }

  Future<LoginResponse> firebaseLogin({
    required String idToken,
  }) async {
    try {
      print("======================================");
      print("FIREBASE LOGIN API");
      print("======================================");
      print("URL : ${_dio.options.baseUrl}/auth/firebase");
      print("TOKEN : ${idToken.substring(0, 40)}...");
      print("======================================");

      final response = await _dio.post(
        ApiConstants.firebaseLogin,
        options: Options(
          headers: {
            "Authorization": "Bearer $idToken",
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        ),
      );

      print("======================================");
      print("STATUS : ${response.statusCode}");
      print("RESPONSE :");
      print(response.data);
      print("======================================");

      return LoginResponse.fromJson(response.data);

    } on DioException catch (e) {

      print("======================================");
      print("FIREBASE LOGIN API ERROR");
      print("STATUS : ${e.response?.statusCode}");
      print("DATA : ${e.response?.data}");
      print("MESSAGE : ${e.message}");
      print("======================================");

      throw Exception(
        _extractErrorMessage(
          e,
          "Firebase Login failed",
        ),
      );
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await SecureStorage.getToken();

      final response = await _dio.get(
        ApiConstants.profile,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      print("BASE URL => ${_dio.options.baseUrl}");
      return response.data;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Get profile failed'));
    }
  }

  Future<void> resetPassword({
    required String newPassword,
    String? firebaseIdToken,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/reset-password',
        data: {
          "newPassword": newPassword,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            if (firebaseIdToken != null && firebaseIdToken.isNotEmpty)
              "Authorization": "Bearer $firebaseIdToken",
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Password reset failed");
      }
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Password reset failed'));
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
  }) async {
    try {
      final fullName = '$firstName $lastName'.trim();

      final token = await SecureStorage.getToken();

      final response = await _dio.put(
        ApiConstants.profile,
        data: {
          'name': fullName,
          'email': email,
          'mobile': mobile,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message']?.toString() ??
            e.message ??
            'Profile update failed',
      );
    }
  }
}