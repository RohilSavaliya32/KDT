// import 'dart:convert';
//
// import 'package:http/http.dart' as http;
//
// import 'contact_model.dart';
//
// class ContactApiService {
//   static const String baseUrl =
//       "http://193.46.198.103/api/v1/contact";
//
//   Future<ContactResponseModel> submitContact({
//     required String name,
//     required String email,
//     required String phone,
//     required String subject,
//     required String message,
//   }) async {
//     try {
//       final response = await http.post(
//         Uri.parse(baseUrl),
//         headers: {
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode({
//           "name": name,
//           "email": email,
//           "phone": phone,
//           "subject": subject,
//           "message": message,
//         }),
//       );
//
//       final data = jsonDecode(response.body);
//
//       if (response.statusCode == 200 ||
//           response.statusCode == 201) {
//         return ContactResponseModel.fromJson(data);
//       }
//
//       throw Exception(data["message"] ?? "Something went wrong");
//     } catch (e) {
//       throw Exception(e.toString());
//     }
//   }
// }




import 'package:dio/dio.dart';
import 'package:kdt/core/storage/api_constants.dart';

import 'contact_model.dart';

class ContactApiService {
  static const String baseUrl = ApiConstants.baseUrl;
  static const String contactEndpoint = "/contact";

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  );

  Future<ContactResponseModel> submitContact({
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        contactEndpoint,
        data: {
          "name": name,
          "email": email,
          "phone": phone,
          "subject": subject,
          "message": message,
        },
      );

      return ContactResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ??
            e.message ??
            "Something went wrong",
      );
    }
  }
}