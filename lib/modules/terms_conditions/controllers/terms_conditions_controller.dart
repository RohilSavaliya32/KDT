import 'package:get/get.dart';
import '../../../data/Setting_Cont.dart';

class TermsConditionsController extends GetxController {

  final SettingsDataController settingsController =
  Get.find<SettingsDataController>();

  String get termsHtml => settingsController.getLocalizedTerms();

  bool get isLoading => settingsController.isLoading.value;
}