import 'package:get/get.dart';
import 'package:kdt/data/repositories/settings_repository.dart';
import '../modules/translations/Translation_key/translation_keys.dart';
import 'models/settings/bank_settings_model.dart';
import 'models/settings/contact_settings_model.dart';
import 'models/settings/firebase_settings_model.dart';
import 'models/settings/home_settings_model.dart';
import 'models/settings/policy_model.dart';
import 'models/settings/retunrn_policy.dart';
import 'models/settings/settings_model.dart';
import 'models/settings/shipping_policy.dart';
import 'models/settings/terms_model.dart';

class SettingsDataController extends GetxController{
SettingsDataController(this.repository);

  final SettingsDataRepository repository;

  final Rxn<SettingsModel> settings = Rxn<SettingsModel>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    if (isLoading.value) return; // Prevent multiple simultaneous fetches

    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await repository.getSettings();
      settings.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  SettingsModel? get data => settings.value;

  HomeSettingsModel? get home => settings.value?.home;
  BankSettingsModel? get bank => settings.value?.bank;
  ContactSettingsModel? get contact => settings.value?.contact;
  FirebaseSettingsModel? get firebase => settings.value?.firebase;
  PolicyModel? get privacyPolicy => settings.value?.privacyPolicy;
  TermsModel? get termsOfService => settings.value?.termsOfService;
  ShippingPolicyModel? get shippingPolicy => settings.value?.shippingPolicy;
  ReturnsPolicyModel? get returnsPolicy => settings.value?.returnsPolicy;
  String getLogoText() => home?.logoText ?? '';
  String getHeaderLogo() => home?.headerLogo ?? '';
  String getFooterLogo() => home?.footerLogo ?? '';
  String getHeroTitle() => home?.heroTitle ?? TranslationKeys.discoverTrueBrilliance.tr;
  String getHeroSubtitle() => home?.heroSubtitle ?? TranslationKeys.bannerDescription.tr;
  String getFooterDescription() => home?.footerDescription ?? '';
  String getGstNo() => home?.gstNo ?? '';
  String getRegNo() => home?.regNo ?? '';
  String getPhone1() => home?.phone1 ?? '';
  String getPhone2() => home?.phone2 ?? '';
  String getAddress1() => home?.address1 ?? '';
  String getAddress2() => home?.address2 ?? '';
  String getFooterEmail() => home?.footerEmail ?? '';
  String getheroButtonText() => home?.heroButtonText ?? TranslationKeys.shopDiamonds.tr;
  String getWhatsappNumber() => contact?.whatsappNumber ?? '';
  String getKakaoId() => contact?.kakaoId ?? '';
  String getWechatId() => contact?.wechatId ?? '';
  String getPhoneKorea() => contact?.phoneKorea ?? '';
  String getPhoneIndia() => contact?.phoneIndia ?? '';
  String getCalendlyKorea() => contact?.calendlyKorea ?? '';
  String getCalendlyIndia() => contact?.calendlyIndia ?? '';

  String getBankName() => bank?.bankName ?? '';
  String getAccountName() => bank?.accountName ?? '';
  String getAccountNumber() => bank?.accountNumber ?? '';
  String getRoutingNumber() => bank?.routingNumber ?? '';
  String getSwiftCode() => bank?.swiftCode ?? '';

  String getLocalizedPolicy() {
    final lang = Get.locale?.languageCode ?? 'en';
    final p = privacyPolicy;
    if (p == null) return '';

    switch (lang) {
      case 'ko':
        return p.ko ?? p.en ?? '';
      case 'zh':
        return p.zh ?? p.en ?? '';
      default:
        return p.en ?? p.ko ?? p.zh ?? '';
    }
  }

  String getLocalizedTerms() {
    final lang = Get.locale?.languageCode ?? 'en';
    final t = termsOfService;
    if (t == null) return '';

    switch (lang) {
      case 'ko':
        return t.ko ?? t.en ?? '';
      case 'zh':
        return t.zh ?? t.en ?? '';
      default:
        return t.en ?? t.ko ?? t.zh ?? '';
    }
  }
String getLocalizedShippingPolicy() {
  final lang = Get.locale?.languageCode ?? 'en';
  final s = shippingPolicy;
  if (s == null) return '';

  switch (lang) {
    case 'ko':
      return s.ko ?? s.en ?? '';
    case 'zh':
      return s.zh ?? s.en ?? '';
    default:
      return s.en ?? s.ko ?? s.zh ?? '';
  }
}
String getLocalizedReturnsPolicy() {
  final lang = Get.locale?.languageCode ?? 'en';
  final r = returnsPolicy;
  if (r == null) return '';

  switch (lang) {
    case 'ko':
      return r.ko ?? r.en ?? '';
    case 'zh':
      return r.zh ?? r.en ?? '';
    default:
      return r.en ?? r.ko ?? r.zh ?? '';
  }
}
}