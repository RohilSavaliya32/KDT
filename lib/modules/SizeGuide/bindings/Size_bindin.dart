import 'package:get/get.dart';

import '../controllers/size_guide_controller.dart';
import '../providers/size_guide_api_provider.dart';
import '../repository/size_guide_repository.dart';

class SizeGuideBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SizeGuideApiProvider>(
          () => SizeGuideApiProvider(),
    );

    Get.lazyPut<SizeGuideRepository>(
          () => SizeGuideRepository(Get.find()),
    );

    Get.lazyPut<SizeGuideController>(
          () => SizeGuideController(Get.find()),
    );
  }
}