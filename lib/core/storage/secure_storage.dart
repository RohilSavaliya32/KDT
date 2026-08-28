import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // ================= TOKEN =================

  static Future<void> saveToken(String token) async {
    await _storage.write(
      key: 'access_token',
      value: token,
    );

    if (kDebugMode) {
      debugPrint("TOKEN SAVED");
    }
  }

  static Future<String?> getToken() async {
    return await _storage.read(
      key: 'access_token',
    );
  }

  static Future<void> removeToken() async {
    await _storage.delete(
      key: 'access_token',
    );
  }

  // ================= USER DATA =================

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final jsonString = jsonEncode(userData);
      await _storage.write(
        key: 'user_data',
        value: jsonString,
      );
      if (kDebugMode) {
        debugPrint("USER DATA SAVED");
      }
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final data = await _storage.read(key: 'user_data');
      if (data == null || data.isEmpty) return null;
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  static Future<void> removeUserData() async {
    await _storage.delete(key: 'user_data');
  }

  // ================= LOGIN TYPE =================

  static const String _loginTypeKey = "login_type";

  static Future<void> saveLoginType(String type) async {
    await _storage.write(
      key: _loginTypeKey,
      value: type,
    );
  }

  static Future<String?> getLoginType() async {
    return await _storage.read(
      key: _loginTypeKey,
    );
  }

  static Future<void> removeLoginType() async {
    await _storage.delete(
      key: _loginTypeKey,
    );
  }


  // ================= WISHLIST DATA =================

  static Future<void> saveWishlistData(String data) async {
    try {
      await _storage.write(
        key: 'wishlist_data',
        value: data,
      );
    } catch (e) {
      debugPrint('Error saving wishlist data: $e');
    }
  }

  static Future<String?> getWishlistData() async {
    try {
      return await _storage.read(key: 'wishlist_data');
    } catch (e) {
      debugPrint('Error getting wishlist data: $e');
      return null;
    }
  }

  static Future<void> clearWishlist() async {
    try {
      await _storage.delete(key: 'wishlist_data');
    } catch (e) {
      debugPrint('Error clearing wishlist: $e');
    }
  }

  // ================= WISHLIST IDS =================

  static Future<void> saveWishlistIds(List<String> ids) async {
    try {
      final jsonString = jsonEncode(ids);
      await _storage.write(
        key: 'wishlist_ids',
        value: jsonString,
      );
    } catch (e) {
      debugPrint('Error saving wishlist IDs: $e');
    }
  }

  static Future<List<String>?> getWishlistIds() async {
    try {
      final data = await _storage.read(key: 'wishlist_ids');
      if (data == null || data.isEmpty) return null;
      final List<dynamic> decoded = jsonDecode(data);
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      debugPrint('Error getting wishlist IDs: $e');
      return null;
    }
  }

  static Future<void> clearWishlistIds() async {
    try {
      await _storage.delete(key: 'wishlist_ids');
    } catch (e) {
      debugPrint('Error clearing wishlist IDs: $e');
    }
  }

  // ================= WISHLIST SYNC PENDING =================

  static Future<void> setWishlistSyncPending(bool pending) async {
    try {
      await _storage.write(
        key: 'wishlist_sync_pending',
        value: pending.toString(),
      );
    } catch (e) {
      debugPrint('Error setting wishlist sync pending: $e');
    }
  }

  static Future<bool> getWishlistSyncPending() async {
    try {
      final value = await _storage.read(key: 'wishlist_sync_pending');
      return value == 'true';
    } catch (e) {
      debugPrint('Error getting wishlist sync pending: $e');
      return false;
    }
  }

  static Future<void> clearWishlistSyncPending() async {
    try {
      await _storage.delete(key: 'wishlist_sync_pending');
    } catch (e) {
      debugPrint('Error clearing wishlist sync pending: $e');
    }
  }

  // ================= AUTH STATUS =================

  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ================= CLEAR ALL =================

  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      if (kDebugMode) {
        debugPrint("ALL STORAGE CLEARED");
      }
    } catch (e) {
      debugPrint('Error clearing all storage: $e');
    }
  }

  // ================= USER LOGIN STATUS =================

  static Future<Map<String, dynamic>?> getLoginUserData() async {
    try {
      final data = await _storage.read(key: 'user_data');
      if (data == null || data.isEmpty) return null;
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error getting login user data: $e');
      return null;
    }
  }

  static Future<String?> getLoginToken() async {
    return await getToken();
  }

  // ======================= FCM Token ===============================
  static const String _fcmTokenKey = "fcm_token";

  static Future<void> saveFcmToken(String token) async {
    await _storage.write(
      key: _fcmTokenKey,
      value: token,
    );
  }

  static Future<String?> getFcmToken() async {
    return await _storage.read(
      key: _fcmTokenKey,
    );
  }

  static Future<void> deleteFcmToken() async {
    await _storage.delete(
      key: _fcmTokenKey,
    );
  }


}