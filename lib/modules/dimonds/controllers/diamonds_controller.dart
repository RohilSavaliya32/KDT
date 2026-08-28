import 'package:get/get.dart';

class DiamondsController extends GetxController {
  RxInt selectedCategory = 0.obs;
  RxInt selectedShape = 0.obs;
  final selectedShapeIndexes = <int>[].obs;
  final categories = [
    'All Diamonds',
    'Certified',
    'Non-Certified',
    'Melee',
  ];
  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args != null &&
        args["selectedShapeIndex"] != null) {
      selectedShapeIndexes.add(
        args["selectedShapeIndex"],
      );
    }
  }

  final shapes = [
    'Round',
    'Princess',
    'Emerald',
    'Marquise',
    'Oval',
    'Pear',
    'Heart',
    'Asscher',
  ];


}