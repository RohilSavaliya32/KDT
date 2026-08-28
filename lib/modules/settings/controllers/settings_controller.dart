import 'package:get/get.dart';

import '../../../data/models/settings/settings_model.dart';
import '../../../data/repositories/settings_repository.dart';

class SettingsController extends GetxController {
  final SettingsDataRepository repository;

  SettingsController(this.repository);

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<SettingsModel> settings = Rxn<SettingsModel>();

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await repository.getSettings();
      settings.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}