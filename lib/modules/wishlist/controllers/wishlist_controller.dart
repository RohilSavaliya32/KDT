
  import 'dart:convert';
  import 'package:flutter/foundation.dart';
  import 'package:get/get.dart';
  import '../local_wishlist_storage.dart';
  import '../services/wishlist_api_service.dart';
  import '../../../core/storage/secure_storage.dart';
  import '../../daimond_card/diamond_model.dart';
  import '../wishlist_model.dart' as wishlist;
  import 'package:connectivity_plus/connectivity_plus.dart';

  class WishlistController extends GetxController {
    WishlistController(this._apiService);

    final WishlistApiService _apiService;
    final LocalWishlistStorage _localStorage = LocalWishlistStorage();
    final Connectivity _connectivity = Connectivity();

    final RxBool isLoading = false.obs;
    final RxBool isSyncing = false.obs;
    final RxString errorMessage = ''.obs;
    final RxBool isLoggedIn = false.obs;

    final RxList<wishlist.WishlistItem> wishlistItems =
        <wishlist.WishlistItem>[].obs;
    final RxList<String> wishlistIds = <String>[].obs;

    @override
    void onInit() {
      super.onInit();
      _checkLoginStatusAndLoadWishlist();
      _setupListeners();
    }

    @override
    void onClose() {
      wishlistItems.clear();
      wishlistIds.clear();
      super.onClose();
    }

    List<wishlist.WishlistItem> get wishlistedDiamonds => wishlistItems;

    // ============ SETUP LISTENERS ============
    void _setupListeners() {
      // Listen to connectivity changes
      _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
        final isConnected = results.any((result) => result != ConnectivityResult.none);
        if (isConnected) {
          _handleConnectivityRestored();
        }
      });
    }

    // ============ CHECK LOGIN & LOAD ============
    Future<void> _checkLoginStatusAndLoadWishlist() async {
      final token = await SecureStorage.getToken();
      isLoggedIn.value = token != null && token.isNotEmpty;

      // Always load local wishlist first (guest mode)
      await _loadLocalWishlist();

      if (isLoggedIn.value) {
        // If logged in, sync with server
        await _syncWishlistOnLogin();
      }
    }

    // ============ LOAD LOCAL WISHLIST ============
    Future<void> _loadLocalWishlist() async {
      try {
        final items = await _localStorage.loadWishlist();
        if (items.isNotEmpty) {
          wishlistItems.assignAll(items);
          wishlistIds.assignAll(items.map((e) => e.id).toSet().toList());
          if (kDebugMode) {
            debugPrint('================ LOADED LOCAL WISHLIST ================');
            debugPrint('Total Items: ${items.length}');
          }
        }
      } catch (e) {
        debugPrint('Error loading local wishlist: $e');
      }
    }

    // ============ LOAD FROM SERVER ============
    Future<void> loadWishlist() async {
      try {
        isLoading.value = true;
        errorMessage.value = '';

        final profile = await _apiService.getMyProfile();
        final rawWishlist = _extractWishlistList(profile);

        final items = <wishlist.WishlistItem>[];

        for (final item in rawWishlist) {
          if (item is Map) {
            items.add(
              wishlist.WishlistItem.fromJson(Map<String, dynamic>.from(item)),
            );
          } else if (item is String && item.isNotEmpty) {
            try {
              final decoded = jsonDecode(item);
              if (decoded is Map) {
                items.add(
                  wishlist.WishlistItem.fromJson(
                    Map<String, dynamic>.from(decoded),
                  ),
                );
              }
            } catch (_) {}
          }
        }

        wishlistItems.assignAll(items);
        wishlistIds.assignAll(items.map((e) => e.id).toSet().toList());

        // Save to local storage
        await _localStorage.saveWishlist(items);

        if (kDebugMode) {
          debugPrint('================ LOADED SERVER WISHLIST ================');
          debugPrint('Total Items: ${items.length}');
        }
      } catch (e) {
        errorMessage.value = _getErrorMessage(e);
      } finally {
        isLoading.value = false;
      }
    }

    // ============ SYNC ON LOGIN ============
    Future<void> _syncWishlistOnLogin() async {
      try {
        isSyncing.value = true;
        errorMessage.value = '';

        // Load local wishlist
        final localItems = await _localStorage.loadWishlist();

        // Fetch server wishlist
        final profile = await _apiService.getMyProfile();
        final rawWishlist = _extractWishlistList(profile);

        final serverItems = <wishlist.WishlistItem>[];

        for (final item in rawWishlist) {
          if (item is Map) {
            serverItems.add(
              wishlist.WishlistItem.fromJson(Map<String, dynamic>.from(item)),
            );
          } else if (item is String && item.isNotEmpty) {
            try {
              final decoded = jsonDecode(item);
              if (decoded is Map) {
                serverItems.add(
                  wishlist.WishlistItem.fromJson(
                    Map<String, dynamic>.from(decoded),
                  ),
                );
              }
            } catch (_) {}
          }
        }

        // Merge local and server items (remove duplicates by ID)
        final mergedItems = _mergeWishlistItems(localItems, serverItems);

        if (mergedItems.isNotEmpty) {
          // Upload merged wishlist to server
          final payload = mergedItems.map((e) => e.toJson()).toList();
          await _apiService.updateWishlist(payload);
        }

        // Reload latest wishlist from server
        await loadWishlist();

        // Clear sync pending flag
        await SecureStorage.setWishlistSyncPending(false);

        if (kDebugMode) {
          debugPrint('================ WISHLIST SYNC SUCCESSFUL ================');
          debugPrint('Merged Items: ${mergedItems.length}');
        }
      } catch (e) {
        // Sync failed - keep local data
        errorMessage.value = 'Sync failed: ${_getErrorMessage(e)}';
        await SecureStorage.setWishlistSyncPending(true);
        if (kDebugMode) {
          debugPrint('================ WISHLIST SYNC FAILED ================');
          debugPrint('Error: $e');
        }
      } finally {
        isSyncing.value = false;
      }
    }

    // ============ MERGE WISHLIST ITEMS ============
    List<wishlist.WishlistItem> _mergeWishlistItems(
        List<wishlist.WishlistItem> first,
        List<wishlist.WishlistItem> second,
        ) {
      final Map<String, wishlist.WishlistItem> mergedMap = {};

      // Add all items from first list
      for (final item in first) {
        mergedMap[item.id] = item;
      }

      // Add items from second list (overwriting duplicates)
      for (final item in second) {
        mergedMap[item.id] = item;
      }

      return mergedMap.values.toList();
    }

    // ============ HANDLE CONNECTIVITY RESTORED ============
    Future<void> _handleConnectivityRestored() async {
      final syncPending = await SecureStorage.getWishlistSyncPending();
      final token = await SecureStorage.getToken();
      final loggedIn = token != null && token.isNotEmpty;

      if (loggedIn && syncPending) {
        await _syncWishlistOnLogin();
      }
    }

    // ============ TOGGLE BY ITEM ============
    Future<bool> toggleWishlistByItem(wishlist.WishlistItem item) async {
      final oldItems = List<wishlist.WishlistItem>.from(wishlistItems);
      final id = item.id.toString();

      final existingIndex = wishlistItems.indexWhere((e) => e.id == id);
      final exists = existingIndex != -1;

      if (exists) {
        wishlistItems.removeAt(existingIndex);
      } else {
        wishlistItems.add(item);
      }

      wishlistIds.assignAll(wishlistItems.map((e) => e.id).toSet().toList());

      // Save to local storage immediately (optimistic update)
      await _localStorage.saveWishlist(wishlistItems);

      try {
        final token = await SecureStorage.getToken();
        final isLoggedIn = token != null && token.isNotEmpty;

        if (isLoggedIn) {
          final payload = wishlistItems.map((e) => e.toJson()).toList();
          await _apiService.updateWishlist(payload);
          // await loadWishlist();
        }

        return true;
      } catch (e) {
        // Revert on error
        wishlistItems.assignAll(oldItems);
        wishlistIds.assignAll(oldItems.map((e) => e.id).toSet().toList());
        await _localStorage.saveWishlist(oldItems);
        errorMessage.value = _getErrorMessage(e);
        return false;
      }
    }

    // ============ SYNC AFTER LOGIN ============
    Future<void> syncWishlistAfterLogin() async {
      isLoggedIn.value = true;
      await _syncWishlistOnLogin();
    }

    // ============ SYNC AFTER LOGOUT ============
    Future<void> syncWishlistAfterLogout() async {
      isLoggedIn.value = false;
      // Clear runtime wishlist only, keep local guest wishlist
      wishlistItems.clear();
      wishlistIds.clear();
      // Reload guest wishlist from local storage
      await _loadLocalWishlist();
    }

    // ============ EXTRACT WISHLIST FROM API RESPONSE ============
    List<dynamic> _extractWishlistList(Map<String, dynamic> profile) {
      final data = profile['data'];

      if (data is List) {
        return data;
      }

      if (data is Map<String, dynamic>) {
        final wishlistData = data['wishlist'];
        if (wishlistData is List) return wishlistData;

        final nestedData = data['data'];
        if (nestedData is List) return nestedData;
        if (nestedData is Map && nestedData['wishlist'] is List) {
          return nestedData['wishlist'] as List;
        }
      }

      if (profile['wishlist'] is List) {
        return profile['wishlist'] as List;
      }

      return <dynamic>[];
    }

    // ============ CHECK IF IN WISHLIST ============
    bool isInWishlist(String productId) {
      return wishlistIds.contains(productId);
    }

    // ============ TOGGLE WISHLIST - MAIN METHOD ============
    Future<bool> toggleWishlist(DiamondModel diamond) async {
      final diamondId = diamond.id.toString();

      try {
        // Check if already in wishlist
        final existingIndex = wishlistItems.indexWhere((e) => e.id == diamondId);
        final exists = existingIndex != -1;

        // Save old state for rollback
        final oldItems = List<wishlist.WishlistItem>.from(wishlistItems);

        // Update local state immediately (optimistic update)
        if (exists) {
          wishlistItems.removeAt(existingIndex);
        } else {
          final wishlistItem = _diamondToWishlistItem(diamond);
          wishlistItems.add(wishlistItem);
        }

        wishlistIds.assignAll(wishlistItems.map((e) => e.id).toSet().toList());

        // Save to local storage
        await _localStorage.saveWishlist(wishlistItems);

        // Check if user is logged in
        final token = await SecureStorage.getToken();
        final isLoggedIn = token != null && token.isNotEmpty;

        if (isLoggedIn) {
          try {
            // Update on server
            final payload = wishlistItems.map((e) => e.toJson()).toList();
            await _apiService.updateWishlist(payload);
            // Reload from server to get latest
            await loadWishlist();
            return true;
          } catch (e) {
            // Server update failed - revert local changes
            wishlistItems.assignAll(oldItems);
            wishlistIds.assignAll(oldItems.map((e) => e.id).toSet().toList());
            await _localStorage.saveWishlist(oldItems);
            errorMessage.value = _getErrorMessage(e);
            return false;
          }
        } else {
          // Guest mode - already saved locally
          return true;
        }
      } catch (e) {
        errorMessage.value = _getErrorMessage(e);
        return false;
      }
    }

    // ============ REMOVE FROM WISHLIST ============
    Future<bool> removeFromWishlist(String id) async {
      final oldItems = List<wishlist.WishlistItem>.from(wishlistItems);

      wishlistItems.removeWhere((e) => e.id == id);
      wishlistIds.assignAll(wishlistItems.map((e) => e.id).toSet().toList());

      // Save to local storage
      await _localStorage.saveWishlist(wishlistItems);

      try {
        final token = await SecureStorage.getToken();
        final isLoggedIn = token != null && token.isNotEmpty;

        if (isLoggedIn) {
          final payload = wishlistItems.map((e) => e.toJson()).toList();
          await _apiService.updateWishlist(payload);
          await loadWishlist();
        }

        return true;
      } catch (e) {
        // Revert on error
        wishlistItems.assignAll(oldItems);
        wishlistIds.assignAll(oldItems.map((e) => e.id).toSet().toList());
        await _localStorage.saveWishlist(oldItems);
        errorMessage.value = _getErrorMessage(e);
        return false;
      }
    }

    // ============ HELPER METHODS ============
    void clearWishlist() {
      wishlistItems.clear();
      wishlistIds.clear();
      wishlistItems.refresh();
      wishlistIds.refresh();
    }

    bool get hasItems => wishlistItems.isNotEmpty;
    int get wishlistCount => wishlistItems.length;

    Future<void> refreshWishlist() async {
      if (isLoggedIn.value) {
        await loadWishlist();
      } else {
        await _loadLocalWishlist();
      }
    }

    // ============ CONVERT DIAMOND TO WISHLIST ITEM ============
    wishlist.WishlistItem _diamondToWishlistItem(DiamondModel diamond) {
      final id = diamond.id.toString();

      return wishlist.WishlistItem(
        id: id,
        cut: diamond.cut,
        sku: diamond.sku,
        slug: diamond.slug,
        carat: diamond.carat.toInt(),
        color: diamond.color,
        image: diamond.image,
        price: diamond.price.toInt(),
        shape: diamond.shape,
        title: diamond.title,
        images: diamond.images,
        polish: diamond.polish,
        clarity: diamond.clarity,
        buyCount: diamond.buyCount,
        quantity: diamond.quantity,
        seoTitle: diamond.seoTitle.isNotEmpty ? diamond.seoTitle : null,
        symmetry: diamond.symmetry,
        createdAt: diamond.createdAt,
        updatedAt: diamond.updatedAt,
        certNumber: diamond.certNumber,
        isLabGrown: diamond.isLabGrown,
        ratingCount: diamond.ratingCount,
        reviewCount: diamond.reviewCount,
        seoKeywords: diamond.seoKeywords,
        depthPercent: diamond.depthPercent.toInt(),
        fluorescence: diamond.fluorescence,
        measurements: wishlist.Measurements(
          depth: diamond.measurements.depth.toInt(),
          width: diamond.measurements.width.toInt(),
          length: diamond.measurements.length.toInt(),
        ),
        tablePercent: diamond.tablePercent.toInt(),
        averageRating: diamond.averageRating.toInt(),
        certification: diamond.certification,
        originalPrice: diamond.originalPrice.toInt(),
        seoDescription:
        diamond.seoDescription.isNotEmpty ? diamond.seoDescription : null,
        certificateFile: diamond.certificateFile.isNotEmpty
            ? diamond.certificateFile
            : null,
        discountPercent: diamond.discountPercent,
        localizedContent: wishlist.LocalizedContent(
          name: diamond.localizedContent.name,
          description: diamond.localizedContent.description,
          shapeName: diamond.localizedContent.shapeName,
          cutDetails: diamond.localizedContent.cutDetails,
          certificationInfo: diamond.localizedContent.certificationInfo,
          specifications: diamond.localizedContent.specifications,
          marketingContent: diamond.localizedContent.marketingContent,
          seoTitle: diamond.localizedContent.seoTitle,
          seoDescription: diamond.localizedContent.seoDescription,
          seoKeywords: diamond.localizedContent.seoKeywords,
        ),
      );
    }

    String _getErrorMessage(dynamic error) {
      if (error is String) return error;
      return error.toString();
    }
  }