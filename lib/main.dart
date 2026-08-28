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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  debugPrint("========== BACKGROUND ==========");
  debugPrint("Message ID : ${message.messageId}");
  debugPrint("Title      : ${message.notification?.title}");
  debugPrint("Body       : ${message.notification?.body}");
  debugPrint("Data       : ${message.data}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint("❌ FLUTTER BUILD ERROR: ${details.exceptionAsString()}");
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint("❌ UNCAUGHT PLATFORM ERROR: $error");
    return true; // handled — don't crash the isolate
  };

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    if (kDebugMode) {
      debugPrint("🔥 FIREBASE CONNECTED");
      debugPrint("🔥 Firebase Apps: ${Firebase.apps}");
    }
  } catch (e) {
    if (kDebugMode) debugPrint("❌ FIREBASE ERROR: $e");
  }

  await GetStorage.init();

  // Initialize Dependencies
  LanguageBinding().dependencies();
  FirebaseBinding().dependencies();
  Get.find<FirebaseController>();

  // Initialize Dio
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

  // Initialize Controllers
  SettingsBinding().dependencies();
  WishlistBinding().dependencies();

  Get.put<AuthController>(AuthController(), permanent: true);
  Get.put<LoginController>(LoginController(), permanent: true);
  Get.put<CartController>(CartController(), permanent: true);
  Get.put<CurrencyController>(CurrencyController(), permanent: true);

  runApp(const MyApp());
}

void _handleNotificationTap(RemoteMessage message) {
  final type = message.data['type'];
  final id = message.data['id'];

  debugPrint("Notification Type : $type");
  debugPrint("Notification Id   : $id");

  switch (type) {
    case 'order':
      AppNavigator.to(
        AppRoutes.ORDERS,
        arguments: {"id": id},
      );
      break;

    case 'payment':
      AppNavigator.to(
        AppRoutes.PAYMENT,
        arguments: {"id": id},
      );
      break;

    case 'diamond':
      AppNavigator.to(
        AppRoutes.DIAMONDS_DETAILS,
        arguments: {"id": id},
      );
      break;

    case 'notification':
      AppNavigator.to(
        AppRoutes.NOTIFICATIONS,
      );
      break;

    default:
      AppNavigator.to(AppRoutes.navigation);
      break;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();
  Uri? _pendingDeepLink;
  bool _isNavigatingDeepLink = false;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint("🔗 Initial Deep Link: $initialUri");
        _handleDeepLink(initialUri, isInitial: true);
      }

      _appLinks.uriLinkStream.listen((uri) {
        debugPrint("🔗 Stream Deep Link: $uri");
        _handleDeepLink(uri);
      }, onError: (e) => debugPrint("❌ Link Error: $e"));
    } catch (e) {
      debugPrint("❌ Init Link Error: $e");
    }
  }

  Future<void> _handleDeepLink(Uri uri, {bool isInitial = false}) async {
    final slug = uri.pathSegments.isNotEmpty ? uri.pathSegments.last.trim() : "";
    if (slug.isEmpty || slug == 'navigation' || slug == 'home') return;

    if (_isNavigatingDeepLink) return;
    _isNavigatingDeepLink = true;

    try {
      // For Cold Start, we just need to wait long enough for GetX and the Navigator to settle.
      if (isInitial) {
        await Future.delayed(const Duration(milliseconds: 3000));
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Final check: ensure we are not trying to navigate while the build is happening.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.context != null) {
          debugPrint("🚀 Navigating to Diamond: $slug");
          Get.toNamed(
            AppRoutes.DIAMONDS_DETAILS,
            arguments: {"slug": slug},
            preventDuplicates: true,
          );
        }
      });
    } catch (e) {
      debugPrint("❌ Deep Link Navigation Error: $e");
    } finally {
      await Future.delayed(const Duration(milliseconds: 1000));
      _isNavigatingDeepLink = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController = Get.find<LanguageController>();

    return GetMaterialApp(
      title: 'KDT DIAMONDS',
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key, // Ensure Get.key is set

      translations: AppTranslations(),
      locale: languageController.getCurrentLocale(),
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

      initialRoute: AppRoutes.navigation,
      getPages: AppPages.routes,

      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();
        return InternetCheckWrapper(child: child);
      },
    );
  }
}
