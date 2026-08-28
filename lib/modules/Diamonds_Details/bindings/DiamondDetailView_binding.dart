import 'package:get/get.dart';
import '../../Review/Review_Controller/Review_Controller.dart';
import '../../daimond_card/diamond_api_provider.dart';
import '../../daimond_card/diamond_repository.dart';
import '../controllers/DiamondDetailView_controller.dart';

class DiamondDetailViewBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure Repository and Provider are available (needed for deep links)
    if (!Get.isRegistered<DiamondApiProvider>()) {
      Get.lazyPut<DiamondApiProvider>(() => DiamondApiProvider());
    }
    
    if (!Get.isRegistered<DiamondRepository>()) {
      Get.lazyPut<DiamondRepository>(
        () => DiamondRepository(Get.find<DiamondApiProvider>()),
      );
    }

    Get.lazyPut<DiamondDetailViewController>(
      () => DiamondDetailViewController(
        Get.find<DiamondRepository>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ReviewController>(
      () => ReviewController(),
      fenix: true,
    );
  }
}
