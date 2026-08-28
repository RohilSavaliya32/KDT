import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../models/size_guide_model.dart';
import '../repository/size_guide_repository.dart';

class SizeGuideController extends GetxController {

  final SizeGuideRepository repository;

  SizeGuideController(this.repository);

  final isLoading = false.obs;

  final selectedShape = ''.obs;

  final shapes = <String>[].obs;

  final data = <String, List<SizeGuideItem>>{}.obs;

  List<SizeGuideItem> get currentData =>
      data[selectedShape.value] ?? [];

  @override
  void onInit() {
    super.onInit();
    fetchSizeGuide();
  }

  Future<void> fetchSizeGuide() async {

    try {

      isLoading.value = true;

      final response = await repository.fetchSizeGuide();

      data.assignAll(response.shapes);

      shapes.assignAll(response.shapes.keys);

      if (shapes.isNotEmpty) {
        selectedShape.value = shapes.first;
      }

    } finally {

      isLoading.value = false;

    }
  }

  void onShapeChanged(String value) {
    selectedShape.value = value;
  }
}