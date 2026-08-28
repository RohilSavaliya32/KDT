import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import '../controllers/payment_confirmation_controller.dart';

class PaymentConfirmationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentConfirmationController>(
          () => PaymentConfirmationController(),
    );
  }
}