import 'package:get/get.dart';

import '../../login/auth_api_service.dart';
import '../../login/views/auth_repository.dart';
import '../controllers/register_controller.dart';


class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthApiService>(
          () => AuthApiService(),
    );

    Get.lazyPut<AuthRepository>(
          () => AuthRepository(
        Get.find<AuthApiService>(),
      ),
    );

    Get.lazyPut<RegisterController>(
          () => RegisterController(
        Get.find<AuthRepository>(),
      ),
    );
  }
}