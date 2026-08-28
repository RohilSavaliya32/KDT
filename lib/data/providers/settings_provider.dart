import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/settings/settings_model.dart';

class SettingsProvider {
  final Dio dio;

  SettingsProvider(this.dio);

  Future<SettingsModel> fetchSettings() async {
    try {
      final response = await dio.get('/settings/settings');

      final dynamic rawData = response.data;

      final Map<String, dynamic> jsonData = rawData is String
          ? Map<String, dynamic>.from(jsonDecode(rawData))
          : Map<String, dynamic>.from(rawData);

      final Map<String, dynamic> data =
      Map<String, dynamic>.from(jsonData['data'] ?? {});

      return SettingsModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? e.message ?? 'Settings fetch failed',
      );
    } catch (e) {
      throw Exception('Settings fetch failed: $e');
    }
  }
}