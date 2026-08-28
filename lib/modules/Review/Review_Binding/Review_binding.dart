import 'package:get/get.dart';

import '../Review_Controller/Review_Controller.dart';

class ReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewController>(
          () => ReviewController(),
      fenix: true,
    );
  }
}