import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:kdt/core/storage/api_constants.dart';

import '../../../core/storage/secure_storage.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../services/firebase_messaging_service.dart';

class FirebaseController extends GetxController {
  final FirebaseMessagingService _fcmService = FirebaseMessagingService.instance;

  final RxString fcmToken = ''.obs;
  final Rxn<String> pendingDeepLink = Rxn<String>();
  Map<String, dynamic> pendingArgs = {};

  @override
  void onInit() {
    super.onInit();
    _initPush();
  }

  Future<void> _initPush() async {
    await _fcmService.initialize(
      onToken: (token) {
        fcmToken.value = token;
        sendTokenToBackend(token);
      },
      onNotificationTap: (RemoteMessage message) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleDeepLink(message.data);
        });
      },
    );
  }

  Future<void> sendTokenToBackend([String? token]) async {
    try {
      token ??= fcmToken.value;

      if (token.isEmpty) {
        token = await FirebaseMessaging.instance.getToken();
      }

      if (token == null || token.isEmpty) {
        debugPrint("⚠ No FCM Token Found");
        return;
      }
      final loginToken = await SecureStorage.getToken();

      if (loginToken == null || loginToken.isEmpty) {
        debugPrint("⚠ User not logged in. Skipping FCM token upload.");
        return;
      }

      final Dio dio = Get.find<Dio>();

      final response = await dio.post(
        ApiConstants.fcmToken,
        data: {
          "token": token,
          "platform": GetPlatform.isIOS ? "ios" : "android",
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $loginToken",
          },
        ),
      );

      debugPrint("================================");
      debugPrint("✅ FCM Token sent successfully");
      debugPrint("Status Code : ${response.statusCode}");
      debugPrint("Response    : ${response.data}");
      debugPrint("================================");
    } on DioException catch (e) {
      debugPrint("================================");
      debugPrint("❌ FCM Token API Error");
      debugPrint("Status Code : ${e.response?.statusCode}");
      debugPrint("Response    : ${e.response?.data}");
      debugPrint("Message     : ${e.message}");
      debugPrint("================================");
    } catch (e) {
      debugPrint("❌ Failed to send FCM Token: $e");
    }
  }

  void _handleDeepLink(Map<String, dynamic> data) {
    final deepLink = data['deepLink'] as String?;
    if (deepLink == null || deepLink.isEmpty) return;

    if (Get.currentRoute.isNotEmpty) {
      AppNavigator.to(deepLink, arguments: data);
    } else {
      pendingDeepLink.value = deepLink;
      pendingArgs = data;
    }
  }

  /// Ise apni pehli/home screen ke onReady() me call karo
  void consumePendingDeepLink() {
    if (pendingDeepLink.value != null) {
      AppNavigator.to(pendingDeepLink.value!, arguments: pendingArgs);
      pendingDeepLink.value = null;
      pendingArgs = {};
    }
  }
}
