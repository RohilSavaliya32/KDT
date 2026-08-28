import 'package:get/get.dart';

import '../../../data/Setting_Cont.dart';

class ShippingPolicyController extends GetxController {
  final SettingsDataController settingsController =
  Get.find<SettingsDataController>();

  String get shippingHtml =>
      settingsController.getLocalizedShippingPolicy();

  bool get isLoading => settingsController.isLoading.value;
}