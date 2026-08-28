import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/storage/api_constants.dart';
import '../../../core/storage/secure_storage.dart';
import 'Notification_Model.dart';

class NotificationPreferencesService {
  final String _url = "${ApiConstants.baseUrl}${ApiConstants.Notification}";

  NotificationPreferencesService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await SecureStorage.getToken();
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  /// GET current notification preferences
  Future<NotificationPreferences> fetchPreferences() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(_url), headers: headers);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return NotificationPreferences.fromJson(body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? "Failed to load preferences (${response.statusCode})");
      }
    } catch (e) {
      rethrow;
    }
  }

  /// PUT updated notification preferences
  Future<NotificationPreferences> updatePreferences(
      NotificationPreferences preferences) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(_url),
        headers: headers,
        body: jsonEncode(preferences.toJson()),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return NotificationPreferences.fromJson(body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? "Failed to update preferences (${response.statusCode})");
      }
    } catch (e) {
      rethrow;
    }
  }
}
