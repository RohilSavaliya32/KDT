import 'package:get/get.dart';

import '../../../data/providers/settings_provider.dart';
import '../../../data/repositories/settings_repository.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {

    Get.lazyPut<SettingsProvider>(
          () => SettingsProvider(Get.find()),
      fenix: true,
    );

    Get.lazyPut<SettingsDataRepository>(
          () => SettingsDataRepository(Get.find<SettingsProvider>()),
      fenix: true,
    );

    Get.lazyPut<HomeController>(
          () => HomeController(
        Get.find<SettingsDataRepository>(),
      ),
      fenix: true,
    );
  }
}