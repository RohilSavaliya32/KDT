import 'package:get/get.dart';
import 'package:kdt/modules/Address/bindings/address_binding.dart';
import 'package:kdt/modules/Address/views/address_view.dart';
import 'package:kdt/modules/Checkout/bindings/checkout_binding.dart';
import 'package:kdt/modules/Checkout/views/checkout_view.dart';
import 'package:kdt/modules/Shipping%20Policy/views/shipping_policy_view.dart';
import 'package:kdt/modules/about/bindings/about_binding.dart';
import 'package:kdt/modules/about/views/about_view.dart';
import 'package:kdt/modules/dimonds/bindings/diamonds_binding.dart';
import 'package:kdt/modules/dimonds/views/diamonds_view.dart';
import 'package:kdt/modules/navigation/bindings/navigation_binding.dart';
import 'package:kdt/modules/navigation/views/navigation_view.dart';
import 'package:kdt/modules/profile/bindings/edit_profile_binding.dart';
import 'package:kdt/modules/wishlist/bindings/wishlist_binding.dart';
import 'package:kdt/modules/wishlist/views/wishlist_view.dart';
import '../modules/Diamonds_Details/bindings/DiamondDetailView_binding.dart';
import '../modules/Diamonds_Details/controllers/DiamondDetailView_controller.dart';
import '../modules/Diamonds_Details/views/diamond_detailView.dart';
import '../modules/FAQ/bindings/faq_binding.dart';
import '../modules/FAQ/views/faq_view.dart';
import '../modules/Notification/Test/Notification.dart';
import '../modules/Notification/Test/Notification_binding.dart';
import '../modules/Order/bindings/order_history_binding.dart';
import '../modules/Order/views/Order_history_view.dart';
import '../modules/Payment_Summary/bindings/payment_confirmation_bindings.dart';
import '../modules/Payment_Summary/views/payment_confirmation_view.dart';
import '../modules/Profile & Settings/Setting_Binding/currency_selection_binding.dart';
import '../modules/Profile & Settings/Setting_view/currency_selection_view.dart';
import '../modules/Register/bindings/register_binding.dart';
import '../modules/Register/views/register_screen.dart';
import '../modules/SizeGuide/bindings/Size_bindin.dart';
import '../modules/SizeGuide/views/SizeGuide.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/cart/views/cart_view.dart';
import '../modules/contact_us/bindings/contact_us_binding.dart';
import '../modules/contact_us/views/contact_us_view.dart';
import '../modules/daimond_card/bindings/daimond_card_binding.dart';
import '../modules/daimond_card/diamond_repository.dart';
import '../modules/daimond_card/views/daimond_card_view.dart';
import '../modules/diamond_education/bindings/diamond_education_binding.dart';
import '../modules/diamond_education/views/diamond_education_view.dart';
import '../modules/privacy_policy/bindings/privacy_policy_binding.dart';
import '../modules/privacy_policy/view/privacy_policy_view.dart';
import '../modules/profile/views/edit_profile_view.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/return_policy/bindings/return_policy_binding.dart';
import '../modules/return_policy/views/return_policy_view.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/terms_conditions/bindings/terms_conditions_bindings.dart';
import '../modules/terms_conditions/views/terms_conditions_view.dart';
import '../modules/login/views/login_view.dart';
import '../modules/login/bindings/login_binding.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final routes = [

    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),

    GetPage(
      name: AppRoutes.CART,
      page: () => const CartView(),
      binding: CartBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),

    GetPage(
      name: AppRoutes.SEARCH,
      page: () => const SearchView(),
      binding: SearchBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),

    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.EDIT_PROFILE,
      page: () => const EditProfilePage(),
      binding: EditProfileBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.navigation,
      page: () => NavigationView(),
      binding: NavigationBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),

    GetPage(
      name: AppRoutes.notificationPreferences,
      page: () => const NotificationPreferencesView(),
      binding: NotificationPreferencesBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.FAQ,
      page: () => const FaqView(),
      binding: FaqBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),

    GetPage(
      name: AppRoutes.CONTACT_US,
      page: () => const ContactView(),
      binding: ContactBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.ABOUT_US,
      page: () => const AboutView(),
      binding: AboutBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),

    GetPage(
      name: AppRoutes.PRIVACY_POLICY,
      page: () => const PrivacyPolicyView(),
      binding: PrivacyPolicyBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),

    GetPage(
      name: AppRoutes.TERMS_CONDITIONS,
      page: () => const TermsConditionsView(),
      binding: TermsConditionsBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),

    GetPage(
      name: AppRoutes.RETURN_POLICY,
      page: () => const ReturnsPolicyView(),
      binding: ReturnPolicyBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.SHIPPING_POLICY,
      page: () => const ShippingPolicyView(),
      binding: ReturnPolicyBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.DIAMONDS,
      page: () => const DiamondsView(),
      binding: DiamondsBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.DIAMONDS_CARD,
      page: () => const DiamondCardView(),
      binding: DiamondCardBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.DIAMONDS_DETAILS,
      page: () => const DiamondDetailView(),
      binding: DiamondDetailViewBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.ORDERS,
      page: () => const OrderHistoryView(),
      binding: OrderHistoryBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.CHECKOUT,
      page: () => const CheckoutView(),
      binding:  CheckoutBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.Payment_Summary,
      page: () => const PaymentConfirmationView(),
      binding: PaymentConfirmationBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginModalDialog(),
      binding: LoginBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.ADDRESS,
      page: () => const AddressView(),
      binding: AddressBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterDialog(),
      binding: RegisterBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.WISHLIST,
      page: () => WishlistView(),
      binding: WishlistBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.diamondEducation,
      page: () => const DiamondEducationView(),
      binding: DiamondEducationBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.currency_selection,
      page: () => const CurrencySelectionView(),
      binding: CurrencySelectionBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: AppRoutes.SIZE_GUIDE,
      page: () => const SizeGuideView(),
      binding: SizeGuideBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    ),
  ];
}