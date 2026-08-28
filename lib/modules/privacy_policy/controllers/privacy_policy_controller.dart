import 'package:get/get.dart';

import '../../../data/Setting_Cont.dart';

class PrivacyPolicyController extends GetxController {
  final SettingsDataController settingsController =
  Get.find<SettingsDataController>();

  String get privacyHtml => settingsController.getLocalizedPolicy();

  bool get isLoading => settingsController.isLoading.value;
}