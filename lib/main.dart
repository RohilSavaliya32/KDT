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
      // Get initial link if app was closed
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint("🔗 Initial Deep Link Found: $initialUri");
        _pendingDeepLink = initialUri;
        // Wait for first frame to be rendered
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _consumePendingDeepLink();
        });
      }

      // Listen for links when app is in background/foreground
      _appLinks.uriLinkStream.listen(
            (uri) {
          debugPrint("🔗 Stream Deep Link: $uri");
          _handleDeepLink(uri);
        },
        onError: (error) {
          debugPrint("❌ Deep Link Error: $error");
        },
      );
    } catch (e) {
      debugPrint("❌ Deep Link Init Error: $e");
    }
  }

  void _consumePendingDeepLink() {
    if (_pendingDeepLink == null) return;
    final uri = _pendingDeepLink!;
    _pendingDeepLink = null;
    _handleDeepLink(uri, isInitial: true);
  }

  Future<void> _handleDeepLink(Uri uri, {bool isInitial = false}) async {
    debugPrint("========== HANDLING DEEP LINK ==========");
    debugPrint("URI: ${uri.toString()}");
    
    if (uri.pathSegments.isEmpty) return;

    if (_isNavigatingDeepLink) {
      debugPrint("⚠️ Deep link navigation already in progress");
      return;
    }
    _isNavigatingDeepLink = true;

    final slug = uri.pathSegments.first.trim();
    if (slug.isEmpty || slug == '/') {
      _isNavigatingDeepLink = false;
      return;
    }

    try {
      // Navigator ready hone ka intezar (Max 5 seconds)
      int attempts = 0;
      while (Get.key.currentState == null && attempts < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }

      if (Get.key.currentState == null) {
        debugPrint("❌ Navigator not ready, aborting");
        _isNavigatingDeepLink = false;
        return;
      }

      // Agar app fresh open hui hai, toh thoda aur delay taake bindings load ho jayein
      if (isInitial) {
        await Future.delayed(const Duration(milliseconds: 800));
      } else {
        await Future.delayed(const Duration(milliseconds: 200));
      }

      debugPrint("🚀 Navigating to Diamond Details: $slug");
      
      // Cold start per AppNavigator.to (with dialog) crash kar sakta hai
      // Is liye hum directly Get.toNamed use karenge
      Get.toNamed(
        AppRoutes.DIAMONDS_DETAILS,
        arguments: {"slug": slug},
      );
      
    } catch (e) {
      debugPrint("❌ Deep link navigation error: $e");
    } finally {
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
