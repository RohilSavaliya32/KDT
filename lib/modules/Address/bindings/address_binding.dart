import 'package:get/get.dart';
import '../address_api_service.dart';
import '../address_repository.dart';
import '../controllers/address_controller.dart';
class AddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
          () => AddressApiService(),
    );

    Get.lazyPut(
          () => AddressRepository(
        Get.find<AddressApiService>(),
      ),
    );

    Get.lazyPut(
          () => AddressController(
        Get.find<AddressRepository>(),
      ),
    );
  }
}