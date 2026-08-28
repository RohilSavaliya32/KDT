import 'package:get/get.dart';

import '../auth_api_service.dart';
import '../views/auth_repository.dart';
import '../controllers/login_controller.dart';
import '../../Register/controllers/register_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthApiService>(
          () => AuthApiService(),
      fenix: true,
    );

    Get.lazyPut<AuthRepository>(
          () => AuthRepository(
        Get.find<AuthApiService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<RegisterController>(
          () => RegisterController(
        Get.find<AuthRepository>(),
      ),
      fenix: true,
    );

    Get.put<LoginController>(
      LoginController(),
      permanent: true,
    );
  }
}