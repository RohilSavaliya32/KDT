// import '../models/size_guide_model.dart';
// import '../providers/size_guide_api_provider.dart';
//
// class SizeGuideRepository {
//   final SizeGuideApiProvider apiProvider;
//
//   SizeGuideRepository(this.apiProvider);
//
//   Future<SizeGuideResponse> fetchSizeGuide() async {
//     final response = await apiProvider.getSizeGuide();
//
//     if (response.statusCode == 200) {
//       return SizeGuideResponse.fromJson(response.body);
//     }
//
//     throw Exception(response.statusText);
//   }
// }



import 'package:dio/dio.dart';

import '../models/size_guide_model.dart';
import '../providers/size_guide_api_provider.dart';

class SizeGuideRepository {
  final SizeGuideApiProvider apiProvider;

  SizeGuideRepository(this.apiProvider);

  Future<SizeGuideResponse> fetchSizeGuide() async {
    try {
      final Response response = await apiProvider.getSizeGuide();

      if (response.statusCode == 200) {
        return SizeGuideResponse.fromJson(response.data);
      }

      throw Exception("Failed to load Size Guide");
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?["message"] ??
            e.message ??
            "Failed to load Size Guide",
      );
    }
  }
}