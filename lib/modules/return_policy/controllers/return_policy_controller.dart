import 'package:get/get.dart';

import '../../../data/Setting_Cont.dart';

class ReturnsPolicyController extends GetxController {
  final SettingsDataController settingsController =
  Get.find<SettingsDataController>();

  String get returnsHtml =>
      settingsController.getLocalizedReturnsPolicy();

  bool get isLoading => settingsController.isLoading.value;
}