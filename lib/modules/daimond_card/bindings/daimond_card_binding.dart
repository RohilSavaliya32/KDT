import 'package:get/get.dart';
import '../controllers/daimond_card_controller.dart';
import '../diamond_api_provider.dart';
import '../diamond_repository.dart';

class DiamondCardBinding extends Bindings {
  @override
  void dependencies() {
    // Provider
    Get.lazyPut<DiamondApiProvider>(
          () => DiamondApiProvider(),
    );

    // Repository
    Get.lazyPut<DiamondRepository>(
          () => DiamondRepository(
        Get.find<DiamondApiProvider>(),
      ),
    );

    // Controller
    Get.lazyPut<DiamondCardController>(
          () => DiamondCardController(
        Get.find<DiamondRepository>(),
      ),
    );
  }
}