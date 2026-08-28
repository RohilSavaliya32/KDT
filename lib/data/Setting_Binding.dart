import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:kdt/data/providers/settings_provider.dart';
import 'package:kdt/data/repositories/settings_repository.dart';
import '../modules/settings/controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsProvider>(
          () => SettingsProvider(Get.find<Dio>()),
      fenix: true,
    );

    Get.lazyPut<SettingsDataRepository>(
          () => SettingsDataRepository(Get.find<SettingsProvider>()),
      fenix: true,
    );

    Get.put<SettingsController>(
      SettingsController(Get.find<SettingsDataRepository>()),
      permanent: true,
    );
  }
}