// import 'package:dio/dio.dart';
//
// class EditProfileRepository {
//   final Dio dio;
//
//   EditProfileRepository(this.dio);
//
//   Future<String> updateProfile({
//     required String firstName,
//     required String lastName,
//     required String email,
//     required String mobile,
//   }) async {
//     try {
//       final response = await dio.put(
//         '/auth/profile',
//         data: {
//           'first_name': firstName,
//           'last_name': lastName,
//           'email': email,
//           'mobile': mobile,
//         },
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return 'Profile updated successfully';
//       }
//
//       throw Exception('Profile update failed');
//     } on DioException catch (e) {
//       final message =
//           e.response?.data?['message']?.toString() ??
//               e.message ??
//               'Profile update failed';
//       throw Exception(message);
//     }
//   }
// }


import 'dart:io';

import 'package:dio/dio.dart';
import 'package:kdt/core/storage/api_constants.dart';

class EditProfileRepository {
  final Dio dio;

  EditProfileRepository(this.dio);

  Future<String> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    File? imageFile,
  }) async {
    try {
      dynamic data;

      if (imageFile != null) {
        data = FormData.fromMap({
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'mobile': mobile,
          'profileImage': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
        });
      } else {
        data = {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'mobile': mobile,
        };
      }

      final response = await dio.put(
        ApiConstants.profile,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['message']?.toString() ??
            'Profile updated successfully';
      }

      throw Exception('Profile update failed');
    } on DioException catch (e) {
      final message =
          e.response?.data?['message']?.toString() ??
              e.message ??
              'Profile update failed';

      throw Exception(message);
    }
  }
}