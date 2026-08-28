import 'package:get/get.dart';
import 'package:kdt/modules/Address/controllers/address_controller.dart';
import 'package:kdt/modules/Checkout/controllers/checkout_controller.dart';
import 'package:kdt/modules/Payment_Summary/controllers/payment_confirmation_controller.dart';
import 'package:kdt/modules/Shipping%20Policy/controllers/shipping_policy_controller.dart';
import 'package:kdt/modules/profile/controllers/edit_profile_controller.dart';
import 'package:kdt/modules/return_policy/controllers/return_policy_controller.dart';
import 'package:kdt/modules/wishlist/services/wishlist_api_service.dart';
import '../../../data/Setting_Cont.dart';
import '../../../data/providers/settings_provider.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../Address/address_api_service.dart';
import '../../Address/address_repository.dart';
import '../../Diamonds_Details/controllers/DiamondDetailView_controller.dart';
import '../../Notification/Test/Notification_Controller.dart';
import '../../Notification/Test/Notification_api_service.dart';
import '../../Review/Review_Controller/Review_Controller.dart';
import '../../SizeGuide/controllers/size_guide_controller.dart';
import '../../SizeGuide/providers/size_guide_api_provider.dart';
import '../../SizeGuide/repository/size_guide_repository.dart';
import '../../contact_us/controllers/contact_us_controller.dart';
import '../../daimond_card/controllers/daimond_card_controller.dart';
import '../../daimond_card/diamond_api_provider.dart';
import '../../daimond_card/diamond_repository.dart';
import '../../dimonds/controllers/diamonds_controller.dart';
import '../../FAQ/controllers/faq_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../search/controllers/search_controller.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../controllers/navigation_controller.dart';

class NavigationBinding extends Bindings {
  @override
  void dependencies() {
    // Core Navigation
    Get.lazyPut<NavigationController>(() => NavigationController(), fenix: true);

    // Settings & Data
    Get.lazyPut<SettingsProvider>(() => SettingsProvider(Get.find()), fenix: true);
    Get.lazyPut<SettingsDataRepository>(() => SettingsDataRepository(Get.find<SettingsProvider>()), fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController(Get.find<SettingsDataRepository>()), fenix: true);
    Get.lazyPut<SettingsDataController>(() => SettingsDataController(Get.find<SettingsDataRepository>()), fenix: true);

    // Home & Search
    Get.lazyPut<HomeController>(() => HomeController(Get.find<SettingsDataRepository>()), fenix: true);
    Get.lazyPut<SearchController>(() => SearchController(), fenix: true);
    Get.lazyPut<DiamondsController>(() => DiamondsController(), fenix: true);

    // Profile & Support
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<EditProfileController>(() => EditProfileController(), fenix: true);
    Get.lazyPut<ContactController>(() => ContactController(), fenix: true);
    Get.lazyPut<FaqController>(() => FaqController(), fenix: true);
    Get.lazyPut<ReviewController>(() => ReviewController(), fenix: true);

    // Wishlist
    Get.lazyPut<WishlistApiService>(() => WishlistApiService(), fenix: true);
    Get.lazyPut<WishlistController>(() => WishlistController(Get.find<WishlistApiService>()), fenix: true);

    // Address Module
    Get.lazyPut<AddressApiService>(() => AddressApiService(), fenix: true);
    Get.lazyPut<AddressRepository>(() => AddressRepository(Get.find<AddressApiService>()), fenix: true);
    Get.lazyPut<AddressController>(() => AddressController(Get.find<AddressRepository>()), fenix: true);

    // Diamond Module
    Get.lazyPut<DiamondApiProvider>(() => DiamondApiProvider(), fenix: true);
    Get.lazyPut<DiamondRepository>(() => DiamondRepository(Get.find<DiamondApiProvider>()), fenix: true);
    Get.lazyPut<DiamondCardController>(() => DiamondCardController(Get.find<DiamondRepository>()), fenix: true);
    Get.lazyPut<DiamondDetailViewController>(() => DiamondDetailViewController(Get.find<DiamondRepository>()), fenix: true);

    // Notification Module (Fixed: Removed authToken)
    Get.lazyPut<NotificationPreferencesService>(() => NotificationPreferencesService(), fenix: true);
    Get.lazyPut<NotificationPreferencesController>(() => NotificationPreferencesController(), fenix: true);

    // Checkout & Payment
    Get.lazyPut<CheckoutController>(() => CheckoutController(), fenix: true);
    Get.lazyPut<PaymentConfirmationController>(() => PaymentConfirmationController(), fenix: true);

    // Policies
    Get.lazyPut<ReturnsPolicyController>(() => ReturnsPolicyController(), fenix: true);
    Get.lazyPut<ShippingPolicyController>(() => ShippingPolicyController(), fenix: true);

    // Size Guide Module
    Get.lazyPut<SizeGuideApiProvider>(() => SizeGuideApiProvider(), fenix: true);
    Get.lazyPut<SizeGuideRepository>(() => SizeGuideRepository(Get.find<SizeGuideApiProvider>()), fenix: true);
    Get.lazyPut<SizeGuideController>(() => SizeGuideController(Get.find<SizeGuideRepository>()), fenix: true);
  }
}
