import 'package:get/get.dart';

import '../Contact_api_service.dart';
import '../controllers/contact_us_controller.dart';

class ContactBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ContactApiService>(
          () => ContactApiService(),
    );

    Get.lazyPut<ContactController>(
          () => ContactController(),
    );
  }
}