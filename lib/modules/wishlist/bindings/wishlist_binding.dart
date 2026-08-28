import 'package:get/get.dart';
import '../controllers/wishlist_controller.dart';
import '../local_wishlist_storage.dart';
import '../services/wishlist_api_service.dart';

class WishlistBinding extends Bindings {
  @override
  void dependencies() {
    // Register LocalWishlistStorage
    if (!Get.isRegistered<LocalWishlistStorage>()) {
      Get.put<LocalWishlistStorage>(
        LocalWishlistStorage(),
        permanent: true,
      );
    }

    // Register WishlistApiService
    if (!Get.isRegistered<WishlistApiService>()) {
      Get.put<WishlistApiService>(
        WishlistApiService(),
        permanent: true,
      );
    }

    // Register WishlistController
    if (!Get.isRegistered<WishlistController>()) {
      Get.put<WishlistController>(
        WishlistController(
          Get.find<WishlistApiService>(),
        ),
        permanent: true,
      );
    }
  }
}