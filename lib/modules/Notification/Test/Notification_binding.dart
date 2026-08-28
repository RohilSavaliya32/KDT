import 'package:get/get.dart';
import 'Notification_Controller.dart';

class NotificationPreferencesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationPreferencesController>(
      () => NotificationPreferencesController(),
    );
  }
}
