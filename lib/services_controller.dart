import 'package:get/get.dart';

class ServicesController extends GetxController {
  final isReady = false.obs;

  void markReady() {
    isReady.value = true;
  }
}
