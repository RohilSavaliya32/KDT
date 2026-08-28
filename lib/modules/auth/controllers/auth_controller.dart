//     import 'dart:convert';
//     import 'package:flutter/foundation.dart';
//     import 'package:get/get.dart';
//     import 'package:get_storage/get_storage.dart';
//     import '../../cart/controllers/cart_controller.dart';
//     import '../../firebase/controllers/firebase_controller.dart';
// import '../../login/auth_api_service.dart';
//   import '../../wishlist/controllers/wishlist_controller.dart';
//     import '../../wishlist/local_wishlist_storage.dart';
//     import '../../../core/storage/secure_storage.dart';
//
//     class AuthController extends GetxController {
//       final box = GetStorage();
//       final LocalWishlistStorage _localWishlistStorage = LocalWishlistStorage();
//
//       // ADD THIS - API Service instance
//       final AuthApiService _apiService = AuthApiService();
//
//       final RxBool isLoggedIn = false.obs;
//       final RxBool authReady = false.obs;
//
//       WishlistController get _wishlistController => Get.find<WishlistController>();
//       CartController get _cartController => Get.find<CartController>();
//
//       @override
//       void onInit() {
//         super.onInit();
//         Future.microtask(() async {
//           await checkLogin();
//           if (kDebugMode) {
//             debugPrint("AUTH READY => ${authReady.value}");
//             debugPrint("IS LOGIN => ${isLoggedIn.value}");
//           }
//         });
//       }
//
//       Future<void> checkLogin() async {
//         try {
//           final token = await SecureStorage.getToken();
//           isLoggedIn.value = token != null && token.isNotEmpty;
//
//           // If logged in, check for pending sync
//           if (isLoggedIn.value) {
//             final syncPending = await SecureStorage.getWishlistSyncPending();
//             if (syncPending && kDebugMode) {
//               debugPrint("WISHLIST SYNC PENDING - Will sync on connectivity");
//             }
//           }
//         } catch (e) {
//           if (kDebugMode) debugPrint("CHECK LOGIN ERROR => $e");
//           isLoggedIn.value = false;
//         } finally {
//           authReady.value = true;
//         }
//       }
//
//       Future<void> login(
//           String token, {
//             Map<String, dynamic>? userData,
//           }) async {
//         try {
//           if (kDebugMode) {
//             debugPrint("TOKEN RECEIVED => $token");
//             debugPrint("USER DATA => $userData");
//           }
//
//           await SecureStorage.saveToken(token);
//
// // 👇 Login ke baad latest Bearer Token ke saath FCM Token backend me update karo
//           await Get.find<FirebaseController>().sendTokenToBackend();
//
//           if (userData != null) {
//             await box.write('user_data', jsonEncode(userData));
//             await SecureStorage.saveUserData(userData);
//           }
//
//           isLoggedIn.value = true;
//           authReady.value = true;
//
//           // Sync guest cart
//           await _syncGuestCart();
//
//           // Sync wishlist after login
//           await _syncWishlistAfterLogin();
//
//           if (kDebugMode) debugPrint("Login completed successfully");
//         } catch (e) {
//           if (kDebugMode) debugPrint("Login error: $e");
//           isLoggedIn.value = false;
//         }
//       }
//
//       Future<void> _syncGuestCart() async {
//         try {
//           final guestCart = box.read('guest_cart');
//           if (guestCart == null || guestCart is! List || guestCart.isEmpty) {
//             if (kDebugMode) debugPrint("No guest cart to sync");
//             return;
//           }
//
//           if (kDebugMode) {
//             debugPrint("Syncing guest cart with ${guestCart.length} items");
//           }
//
//           _cartController.loadGuestCart();
//           await _cartController.syncCartWithServer();
//           await box.remove('guest_cart');
//
//           if (kDebugMode) debugPrint("Guest Cart Synced Successfully");
//         } catch (e) {
//           if (kDebugMode) debugPrint("Guest Cart Sync Error => $e");
//         }
//       }
//
//       Future<void> _syncWishlistAfterLogin() async {
//         try {
//           // Load local wishlist
//           final localItems = await _localWishlistStorage.loadWishlist();
//
//           if (kDebugMode) {
//             debugPrint("================ SYNCING WISHLIST AFTER LOGIN ================");
//             debugPrint("Local Items: ${localItems.length}");
//           }
//
//           // If there are local items, sync them
//           if (localItems.isNotEmpty) {
//             await _wishlistController.syncWishlistAfterLogin();
//           } else {
//             // No local items, just load from server
//             await _wishlistController.loadWishlist();
//           }
//
//           // Clear sync pending flag on successful sync
//           await SecureStorage.setWishlistSyncPending(false);
//
//           if (kDebugMode) debugPrint("Wishlist synced successfully after login");
//         } catch (e) {
//           if (kDebugMode) debugPrint("Wishlist sync after login error: $e");
//           // Set sync pending flag
//           await SecureStorage.setWishlistSyncPending(true);
//         }
//       }
//
//       Future<void> logout() async {
//         try {
//           debugPrint("========== LOGOUT START ==========");
//
//           // 1. Sync wishlist
//           debugPrint("STEP 1 : Sync Wishlist");
//           await _wishlistController.syncWishlistAfterLogout();
//
//           // 2. Clear Secure Storage
//           debugPrint("STEP 2 : Remove Token");
//           await SecureStorage.removeToken();
//
//           debugPrint("STEP 3 : Remove UserData");
//           await SecureStorage.removeUserData();
//
//           // 3. Clear GetStorage
//           debugPrint("STEP 4 : Remove Local Storage");
//           await box.remove('user_data');
//           await box.remove('guest_cart');
//
//           // 4. Update Login State
//           debugPrint("STEP 5 : Update Auth State");
//           isLoggedIn.value = false;
//           authReady.value = true;
//
//           // 5. Clear Cart
//           debugPrint("STEP 6 : Clear Cart");
//           _cartController.clearCart();
//
//           // 6. Reset Wishlist Controller
//           debugPrint("STEP 7 : Reset Wishlist");
//           if (Get.isRegistered<WishlistController>()) {
//             Get.find<WishlistController>().wishlistIds.clear();
//             Get.find<WishlistController>().wishlistItems.clear();
//           }
//
//           debugPrint("STEP 8 : Navigate");
//
//           Get.offAllNamed("/navigation");
//
//           debugPrint("========== LOGOUT SUCCESS ==========");
//         } catch (e, s) {
//           debugPrint("========== LOGOUT ERROR ==========");
//           debugPrint(e.toString());
//           debugPrint(s.toString());
//         }
//       }
//       // ============ LOGIN WITH CREDENTIALS ============
//       Future<void> loginWithCredentials({
//         required String email,
//         required String password,
//       }) async {
//         try {
//           final response = await _apiService.login(
//             email: email,
//             password: password,
//           );
//
//           await login(
//             response.data.accessToken,
//             userData: {
//               'id': response.data.id,
//               'name': response.data.name,
//               'email': response.data.email,
//               'mobile': response.data.mobile,
//               'role': response.data.role,
//             },
//           );
//         } catch (e) {
//           throw Exception('Login failed: $e');
//         }
//       }
//
//       // ============ GETTERS ============
//       Future<String?> get token async => await SecureStorage.getToken();
//
//       Map<String, dynamic>? get userData {
//         final raw = box.read('user_data');
//         if (raw == null) return null;
//         try {
//           return jsonDecode(raw) as Map<String, dynamic>;
//         } catch (_) {
//           return null;
//         }
//       }
//
//       String? get userId => userData?['id']?.toString();
//       String? get userName => userData?['name']?.toString();
//       String? get userEmail => userData?['email']?.toString();
//       String? get userMobile => userData?['mobile']?.toString();
//       String? get userRole => userData?['role']?.toString();
//
//       // ============ CHECK SYNC STATUS ============
//       Future<bool> isWishlistSyncPending() async {
//         return await SecureStorage.getWishlistSyncPending();
//       }
//
//       // ============ FORCE SYNC WISHLIST ============
//       Future<void> forceSyncWishlist() async {
//         if (isLoggedIn.value) {
//           await _syncWishlistAfterLogin();
//         }
//       }
//     }






import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../core/storage/secure_storage.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../firebase/controllers/firebase_controller.dart';
import '../../login/auth_api_service.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../../wishlist/local_wishlist_storage.dart';

class AuthController extends GetxController {
  final GetStorage box = GetStorage();

  final AuthApiService _apiService = AuthApiService();
  final LocalWishlistStorage _localWishlistStorage = LocalWishlistStorage();

  final RxBool isLoggedIn = false.obs;
  final RxBool authReady = false.obs;

  WishlistController get _wishlistController => Get.find<WishlistController>();

  CartController get _cartController => Get.find<CartController>();

  @override
  void onInit() {
    super.onInit();

    Future.microtask(() async {
      await checkLogin();

      if (kDebugMode) {
        debugPrint("AUTH READY : ${authReady.value}");
        debugPrint("IS LOGGED IN : ${isLoggedIn.value}");
      }
    });
  }

  // ===================== CHECK LOGIN =====================

  Future<void> checkLogin() async {
    try {
      final token = await SecureStorage.getToken();

      isLoggedIn.value = token != null && token.isNotEmpty;

      if (isLoggedIn.value) {
        final syncPending =
        await SecureStorage.getWishlistSyncPending();

        if (syncPending && kDebugMode) {
          debugPrint("Wishlist sync pending.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Check Login Error : $e");
      }

      isLoggedIn.value = false;
    } finally {
      authReady.value = true;
    }
  }

  // ===================== LOGIN =====================

  Future<void> login(
      String token, {
        Map<String, dynamic>? userData,
      }) async {
    try {
      if (kDebugMode) {
        debugPrint("TOKEN : $token");
        debugPrint("USER DATA : $userData");
      }

      await SecureStorage.saveToken(token);

      await Get.find<FirebaseController>().sendTokenToBackend();

      if (userData != null) {
        await box.write(
          'user_data',
          jsonEncode(userData),
        );

        await SecureStorage.saveUserData(userData);
      }

      isLoggedIn.value = true;
      authReady.value = true;

      await _syncGuestCart();
      await _syncWishlistAfterLogin();

      if (kDebugMode) {
        debugPrint("Login Success");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Login Error : $e");
      }

      isLoggedIn.value = false;
    }
  }

  // ===================== LOGIN WITH EMAIL =====================

  Future<void> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      await login(
        response.data.accessToken,
        userData: {
          'id': response.data.id,
          'name': response.data.name,
          'email': response.data.email,
          'mobile': response.data.mobile,
          'role': response.data.role,
        },
      );
    } catch (e) {
      throw Exception("Login failed : $e");
    }
  }

  // ===================== GUEST CART SYNC =====================

  Future<void> _syncGuestCart() async {
    try {
      final guestCart = box.read('guest_cart');

      if (guestCart == null ||
          guestCart is! List ||
          guestCart.isEmpty) {
        if (kDebugMode) {
          debugPrint("No Guest Cart");
        }
        return;
      }

      if (kDebugMode) {
        debugPrint(
          "Sync Guest Cart : ${guestCart.length} items",
        );
      }

      _cartController.loadGuestCart();

      await _cartController.syncCartWithServer();

      await box.remove('guest_cart');

      if (kDebugMode) {
        debugPrint("Guest Cart Synced");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Guest Cart Sync Error : $e");
      }
    }
  }

  // ===================== WISHLIST SYNC =====================

  Future<void> _syncWishlistAfterLogin() async {
    try {
      final localItems =
      await _localWishlistStorage.loadWishlist();

      if (kDebugMode) {
        debugPrint("Local Wishlist : ${localItems.length}");
      }

      if (localItems.isNotEmpty) {
        await _wishlistController.syncWishlistAfterLogin();
      } else {
        await _wishlistController.loadWishlist();
      }

      await SecureStorage.setWishlistSyncPending(false);

      if (kDebugMode) {
        debugPrint("Wishlist Synced");
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Wishlist Sync Error : $e");
      }

      await SecureStorage.setWishlistSyncPending(true);
    }
  }

  // ===================== LOGOUT =====================

  Future<void> logout() async {
    try {
      if (kDebugMode) {
        debugPrint("========== LOGOUT ==========");
      }

      await _wishlistController.syncWishlistAfterLogout();

      await SecureStorage.removeToken();
      await SecureStorage.removeUserData();

      await box.remove('user_data');
      await box.remove('guest_cart');

      isLoggedIn.value = false;
      authReady.value = true;

      _cartController.clearCart();

      if (Get.isRegistered<WishlistController>()) {
        final wishlistController =
        Get.find<WishlistController>();

        wishlistController.wishlistIds.clear();
        wishlistController.wishlistItems.clear();
      }

      Get.offAllNamed("/navigation");

      if (kDebugMode) {
        debugPrint("Logout Success");
      }
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint("Logout Error : $e");
        debugPrint("$s");
      }
    }
  }

  // ===================== GETTERS =====================

  Future<String?> get token async =>
      SecureStorage.getToken();

  Map<String, dynamic>? get userData {
    final raw = box.read('user_data');

    if (raw == null) return null;

    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  String? get userId => userData?['id']?.toString();
  String? get userName => userData?['name']?.toString();
  String? get userEmail => userData?['email']?.toString();
  String? get userMobile => userData?['mobile']?.toString();
  String? get userRole => userData?['role']?.toString();

  // ===================== WISHLIST =====================

  Future<bool> isWishlistSyncPending() {
    return SecureStorage.getWishlistSyncPending();
  }

  Future<void> forceSyncWishlist() async {
    if (!isLoggedIn.value) return;
    await _syncWishlistAfterLogin();
  }
}