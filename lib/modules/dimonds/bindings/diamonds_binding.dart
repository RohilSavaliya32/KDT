import 'package:get/get.dart';
import '../controllers/diamonds_controller.dart';

class DiamondsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiamondsController>(
          () => DiamondsController(),
    );
  }
}