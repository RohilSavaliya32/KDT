import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:kdt/modules/wishlist/wishlist_model.dart';
import '../../../core/storage/secure_storage.dart';

class LocalWishlistStorage {
  // Save wishlist locally
  Future<void> saveWishlist(List<WishlistItem> items) async {
    try {
      final jsonList = items.map((item) => item.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await SecureStorage.saveWishlistData(jsonString);
      // Also save IDs for quick checks
      final ids = items.map((e) => e.id).toList();
      await SecureStorage.saveWishlistIds(ids);
    } catch (e) {
      debugPrint('Error saving local wishlist: $e');
      // Don't rethrow - storage errors shouldn't break the app
    }
  }

  // Load wishlist from local storage
  Future<List<WishlistItem>> loadWishlist() async {
    try {
      final jsonString = await SecureStorage.getWishlistData();
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((item) => WishlistItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      debugPrint('Error loading local wishlist: $e');
      return [];
    }
  }

  // Load wishlist IDs for quick lookup
  Future<List<String>> loadWishlistIds() async {
    try {
      final ids = await SecureStorage.getWishlistIds();
      if (ids == null || ids.isEmpty) {
        return [];
      }
      return ids;
    } catch (e) {
      debugPrint('Error loading wishlist IDs: $e');
      return [];
    }
  }

  // Check if an item exists in local wishlist
  Future<bool> isInWishlist(String diamondId) async {
    try {
      final ids = await loadWishlistIds();
      return ids.contains(diamondId);
    } catch (e) {
      return false;
    }
  }

  // Add item to local wishlist
  Future<void> addItem(WishlistItem item) async {
    try {
      final items = await loadWishlist();
      // Check if already exists
      if (items.any((i) => i.id == item.id)) return;
      items.add(item);
      await saveWishlist(items);
    } catch (e) {
      debugPrint('Error adding item to local wishlist: $e');
    }
  }

  // Remove item from local wishlist
  Future<void> removeItem(String diamondId) async {
    try {
      final items = await loadWishlist();
      items.removeWhere((item) => item.id == diamondId);
      await saveWishlist(items);
    } catch (e) {
      debugPrint('Error removing item from local wishlist: $e');
    }
  }

  // Clear local wishlist
  Future<void> clearWishlist() async {
    try {
      await SecureStorage.clearWishlist();
      await SecureStorage.clearWishlistIds();
    } catch (e) {
      debugPrint('Error clearing local wishlist: $e');
    }
  }

  // Check if wishlist exists locally
  Future<bool> hasLocalWishlist() async {
    try {
      final data = await SecureStorage.getWishlistData();
      return data != null && data.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get wishlist count
  Future<int> getWishlistCount() async {
    try {
      final items = await loadWishlist();
      return items.length;
    } catch (e) {
      return 0;
    }
  }

  // Get wishlist items
  Future<List<WishlistItem>> getWishlistItems() async {
    return await loadWishlist();
  }
}