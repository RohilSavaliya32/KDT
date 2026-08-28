import 'package:get/get.dart';

import '../Setting_Api/Currency_api.dart';
import '../Setting_Controller/Currency_Controller.dart';
import '../Setting_Controller/currency_selection_controller.dart';

class CurrencySelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CurrencyApiService>(
          () => CurrencyApiService(),
    );

    Get.lazyPut<CurrencySelectionController>(
          () => CurrencySelectionController(
        currencyController: Get.find<CurrencyController>(),
        apiService: Get.find<CurrencyApiService>(),
      ),
    );
  }
}