import 'package:get/get.dart';
import '../Translation_controllers/language_controller.dart';

class LanguageBinding extends Bindings {
  @override
  void dependencies() {
    // CHANGE: Use Get.put instead of Get.lazyPut
    // This ensures controller is created immediately
    Get.put<LanguageController>(LanguageController(), permanent: true);
  }
}