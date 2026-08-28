import 'package:get/get.dart';

import '../controllers/firebase_controller.dart';
import '../repositories/firebase_repository.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_messaging_service.dart';
import '../services/firebase_otp_service.dart';
import '../services/firebase_service.dart';

class FirebaseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FirebaseService(), fenix: true);

    Get.lazyPut(() => FirebaseAuthService(), fenix: true);

    Get.lazyPut(() => FirebaseOtpService(), fenix: true);

    Get.lazyPut(
          () => FirebaseRepository(
        Get.find<FirebaseOtpService>(),
      ),
      fenix: true,
    );

    Get.lazyPut(
          () => FirebaseMessagingService.instance,
      fenix: true,
    );

    Get.lazyPut(
          () => FirebaseController(),
      fenix: true,
    );
  }
}