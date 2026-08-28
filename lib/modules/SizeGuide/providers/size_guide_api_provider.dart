// import 'package:get/get.dart';
//
// class SizeGuideApiProvider extends GetConnect {
//
//   @override
//   void onInit() {
//     httpClient.baseUrl = "http://193.46.198.103/api/v1";
//     super.onInit();
//   }
//
//   Future<Response> getSizeGuide() {
//     return get("/settings/size-guide");
//   }
// }


import 'package:dio/dio.dart';
import 'package:kdt/core/storage/api_constants.dart';

class SizeGuideApiProvider {
  static const String baseUrl = ApiConstants.baseUrl;
  static const String sizeGuideEndpoint = "/settings/size-guide";

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    ),
  );

  Future<Response> getSizeGuide() async {
    return await _dio.get(sizeGuideEndpoint);
  }
}