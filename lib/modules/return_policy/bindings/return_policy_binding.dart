import 'package:get/get.dart';
import '../../Shipping Policy/controllers/shipping_policy_controller.dart';
import '../controllers/return_policy_controller.dart';

class ReturnPolicyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReturnsPolicyController>(
          () => ReturnsPolicyController(),
    );
  }
}