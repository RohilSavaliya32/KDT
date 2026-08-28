import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kdt/core/storage/api_constants.dart';

import '../../../data/providers/settings_provider.dart';
import '../../../data/repositories/settings_repository.dart';
import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Dio>(
          () => Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      ),
    );

    Get.lazyPut<SettingsProvider>(() => SettingsProvider(Get.find()));
    Get.lazyPut<SettingsDataRepository>(() => SettingsDataRepository(Get.find()));
    Get.lazyPut<SettingsController>(() => SettingsController(Get.find()));
  }
}