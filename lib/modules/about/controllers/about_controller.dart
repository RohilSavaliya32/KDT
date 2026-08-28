import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../data/Setting_Cont.dart';

class AboutController extends GetxController {
  final sectionIndex = 0.obs;

  final SettingsDataController settingsController =
  Get.find<SettingsDataController>();

  void scrollToSection(int index) {
    sectionIndex.value = index;
  }

  String get koreaAddress => settingsController.getAddress1();
  String get indiaAddress => settingsController.getAddress2();

  String get koreaPhone => settingsController.getPhone1();
  String get indiaPhone => settingsController.getPhone2();
  String get gstNo => settingsController.getGstNo();
  String get regNo => settingsController.getRegNo();

  String get email => settingsController.getFooterEmail();


  @override
  void onInit() {
    super.onInit();
    
    // Ensure settings are fetched when About page is opened
    if (settingsController.settings.value == null) {
      settingsController.fetchSettings();
    }

    ever(settingsController.settings, (_) {
      debugPrint("========== ABOUT DATA ==========");
      debugPrint("Address1 : $koreaAddress");
      debugPrint("Address2 : $indiaAddress");
      debugPrint("Phone1   : $koreaPhone");
      debugPrint("Phone2   : $indiaPhone");
      debugPrint("Email    : $email");
      debugPrint("===============================");
    });
  }


  // ========== HERO SECTION ==========
  final String heroTitle = 'About KDT Diamond';
  final String heroSubtitle = 'Bridging excellence from Seoul to Surat, delivering the world\'s finest diamonds with transparency and trust.';
  // ========== STORY SECTION ==========
  final String storyText = 'Founded with a vision to revolutionize the diamond industry, KDT Diamond has grown from a small family business to an international leader in certified loose diamonds. Our journey began in the diamond districts of Surat, India, where generations of expertise in diamond cutting and polishing have been passed down.\n\nToday, with our headquarters in Seoul, South Korea, we bridge the gap between traditional craftsmanship and modern luxury retail. We handpick each diamond, ensuring only the finest stones reach our discerning customers.\n\nOur commitment to transparency, quality, and customer satisfaction has made us a trusted name among jewelers, collectors, and individuals seeking the perfect diamond for life\'s most precious moments.';
  // ========== STATS DATA ==========
  final List<Map<String, String>> stats = const [
    {'value': '25+', 'label': 'Years of Excellence'},
    {'value': '50K+', 'label': 'Diamonds Sold'},
    {'value': '100+', 'label': 'Countries Served'},
    {'value': '99%', 'label': 'Customer Satisfaction'},
  ];
  // ========== SECTION TITLES ==========
  final String storySectionTitle = 'Our Story';
  final String valuesSectionTitle = 'Our Values';
  final String timelineSectionTitle = 'About KDT';
  final String visionSectionTitle = 'Our Vision';
  final String partnersSectionTitle = 'PARTNERS';
  final String officesSectionTitle = 'Our Offices';
  // ========== SECTION SUBTITLES ==========
  final String visionSubtitle = 'The most trusted diamond supplier combining technology and art.';
  final String partnersSubtitle = 'Various institutions are investing in us, recognized for our unique domestic lab-grown diamond production and polishing technology.';
// ========== VALUES DATA ==========
  final List<Map<String, String>> values = const [
    {
      'icon': 'verified_outlined',
      'title': 'Quality First',
      'text': 'Every diamond is hand-selected and certified to meet our exacting standards.'
    },
    {
      'icon': 'groups_outlined',
      'title': 'Customer Focus',
      'text': 'Our satisfaction is our priority, from selection to delivery and beyond.'
    },
    {
      'icon': 'public_outlined',
      'title': 'Global Reach',
      'text': 'Serving customers worldwide with reliable shipping and local support.'
    },
    {
      'icon': 'favorite_border',
      'title': 'Integrity',
      'text': 'Transparent pricing and honest representation in everything we do.'
    },
  ];

  // ========== TIMELINE DATA ==========
  final List<Map<String, dynamic>> timelineData = const [
    {
      'year': '2012',
      'events': ['KDT DIAMOND Establishment.']
    },
    {
      'year': '2021',
      'events': ['Successful production of Korea\'s first CVD lab-grown diamonds.']
    },
    {
      'year': '2023',
      'events': [
        'Patent obtained for microwave plasma CVD device for diamond synthesis and diamond synthesis method by plasma CVD.',
        'ALOD Brand Launch.'
      ]
    },
    {
      'year': '2024',
      'events': ['KDT DIAMOND INDIA Incorporation, India Factory Construction Begins.']
    },
    {
      'year': '2025',
      'events': [
        'KDT DIAMOND INDIA India Factory Completion.',
        'Introduction of New CVD Reactor Advanced Polishing Equipment.'
      ]
    },
  ];
  // ========== VISION IMAGES DATA ==========
  final List<Map<String, String>> visionImages = const [
    {
      'path': 'assets/web/aboutus/img1.jpg',
      'label': 'KDT DIAMOND'
    },
    {
      'path': 'assets/web/aboutus/img2.jpg',
      'label': 'KDT DIAMOND INDIA'
    },
  ];
  // ========== PARTNERS DATA ==========
  final List<Map<String, String>> partners = const [
    {'image': 'assets/web/aboutus/partners/partner1.jpg'},
    {'image': 'assets/web/aboutus/partners/partner2.jpg'},
    {'image': 'assets/web/aboutus/partners/partner3.jpg'},
    {'image': 'assets/web/aboutus/partners/partner4.jpg'},
    {'image': 'assets/web/aboutus/partners/partner5.jpg'},
  ];
}