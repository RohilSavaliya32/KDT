import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:app_links/app_links.dart';
import 'package:kdt/core/storage/api_constants.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/modules/navigation/controllers/navigation_controller.dart';
import 'data/Setting_Binding.dart';
import 'internet_check_wrapper.dart';
import 'modules/Loader/Helper/Loader_helper.dart';
import 'modules/Profile & Settings/Setting_Controller/Currency_Controller.dart';
import 'modules/auth/controllers/auth_controller.dart';
import 'modules/cart/controllers/cart_controller.dart';
import 'modules/firebase/controllers/firebase_controller.dart';
import 'modules/login/controllers/login_controller.dart';
import 'modules/translations/Translation_bindings/language_binding.dart';
import 'modules/translations/Translation_controllers/language_controller.dart';
import 'modules/translations/Translation_key/app_translations.dart';
import 'modules/wishlist/bindings/wishlist_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'modules/firebase/bindings/firebase_binding.dart';
import 'services_controller.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-register status controller (Synchronous, so no white flash)
  Get.put(ServicesController(), permanent: true);

  runApp(const MyApp());

  // Background initialization
  _initServices();
}

Future<void> _initServices() async {
  try {
    final servicesController = Get.find<ServicesController>();
    
    // Essential setup
    await GetStorage.init();
    LanguageBinding().dependencies();
    
    // Background services
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseBinding().dependencies();
    
    Get.put<Dio>(
      Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ),
      permanent: true,
    );

    SettingsBinding().dependencies();
    WishlistBinding().dependencies();

    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<LoginController>(LoginController(), permanent: true);
    Get.put<CartController>(CartController(), permanent: true);
    Get.put<CurrencyController>(CurrencyController(), permanent: true);

    // Notify app that everything is ready
    servicesController.markReady();
  } catch (e) {
    debugPrint("❌ SERVICE INIT ERROR: $e");
    // Even on error, mark ready to prevent getting stuck on Splash
    Get.find<ServicesController>().markReady();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();
  bool _isInitialLinkHandled = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null && !_isInitialLinkHandled) {
        _isInitialLinkHandled = true;
        _saveLinkForNavigation(initialUri);
      }

      _appLinks.uriLinkStream.listen((uri) {
        _saveLinkForNavigation(uri);
      }, onError: (e) => debugPrint("❌ Link Error: $e"));
    } catch (e) {
      debugPrint("❌ Init Link Error: $e");
    }
  }

  void _saveLinkForNavigation(Uri uri) {
    // 1. Basic host check
    if (!uri.host.contains('kdtdiamond.com')) return;

    // 2. Ignore Firebase Auth/reCAPTCHA and other auth paths
    final path = uri.path.toLowerCase();
    if (path.contains('auth') || 
        path.contains('__/auth') || 
        path.contains('firebase') || 
        path.contains('google') ||
        path.contains('facebook')) {
      debugPrint("🚫 Ignoring Auth/System Link: $path");
      return;
    }

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return;
    
    final slug = segments.last.trim();
    
    // 3. Ignore generic/navigation keywords
    // "link" is often used in Firebase Auth redirects (e.g. /__/auth/handler?link=...)
    if (slug == 'navigation' || 
        slug == 'home' || 
        slug == 'link' || 
        slug == 'handler' ||
        slug == 'callback') {
      debugPrint("🚫 Ignoring Generic Link Segment: $slug");
      return;
    }

    debugPrint("📥 Saving Potential Diamond Slug: $slug");
    Get.put<String>(slug, tag: 'pending_deeplink', permanent: true);
    
    try {
      if (Get.isRegistered<NavigationController>()) {
        Get.find<NavigationController>().handlePendingDeepLink();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KDT DIAMONDS',
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,

      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),

      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),

      theme: ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        primaryColor: AppColors.foreground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.foreground,
          primary: AppColors.foreground,
        ),
      ),

      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,

      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
