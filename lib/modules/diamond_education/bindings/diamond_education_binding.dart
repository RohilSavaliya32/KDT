import 'package:get/get.dart';

import '../controllers/diamond_education_controller.dart';

class DiamondEducationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiamondEducationController>(() => DiamondEducationController());
  }
}
