  import 'dart:convert';
  import 'dart:io';

  import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
  import 'package:flutter/foundation.dart';
  import 'package:flutter_local_notifications/flutter_local_notifications.dart';
  import 'package:http/http.dart' as http;
  import 'package:path_provider/path_provider.dart';

import '../../../core/storage/secure_storage.dart';
  class FirebaseMessagingService {
    FirebaseMessagingService._();

    static final FirebaseMessagingService instance =
    FirebaseMessagingService._();

    final FirebaseMessaging _messaging = FirebaseMessaging.instance;

    final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

    static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
      'kdt_push_channel',
      'High Importance Notifications',
      description: 'Order, payment and delivery notifications',
      importance: Importance.max,
    );
    Future<String?> _downloadAndSaveFile(
        String url,
        String fileName,
        ) async {
      try {
        final directory = await getTemporaryDirectory();

        final filePath =
            '${directory.path}/$fileName';

        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) {
          return null;
        }

        final file = File(filePath);

        await file.writeAsBytes(
          response.bodyBytes,
        );

        return filePath;
      } catch (e) {
        debugPrint(e.toString());
        return null;
      }
    }

    String? _getImageUrl(RemoteMessage message) {
      if (message.notification?.android?.imageUrl != null) {
        return message.notification!.android!.imageUrl;
      }

      if (message.notification?.apple?.imageUrl != null) {
        return message.notification!.apple!.imageUrl;
      }

      if (message.data["image"] != null) {
        return message.data["image"];
      }

      if (message.data["imageUrl"] != null) {
        return message.data["imageUrl"];
      }

      return null;
    }

    /// Ask Notification Permission
    Future<void> requestPermission() async {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint("Notification Permission : ${settings.authorizationStatus}");
    }

    /// Initialize Local Notifications
    Future<void> initLocalNotifications() async {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse:
            (NotificationResponse details) {

          debugPrint(
            "Payload : ${details.payload}",
          );

          if (details.payload != null) {
            final data = jsonDecode(
              details.payload!,
            );

            debugPrint(data.toString());
          }
        },
      );
    }

    /// Get FCM Token
    Future<String?> getToken() async {
      if (Platform.isIOS) {
        await _messaging.getAPNSToken();
      }

      final token = await _messaging.getToken();

      debugPrint("================================");
      debugPrint("FCM TOKEN");
      debugPrint(token);
      debugPrint("================================");

      return token;
    }

    /// Listen Token Refresh
    void tokenRefreshListener({
      required Function(String token) onRefresh,
    }) {
      _messaging.onTokenRefresh.listen((token) {
        debugPrint("New FCM Token : $token");
        onRefresh(token);
      });
    }


    /// Foreground Notification
    /// Foreground Notification
    void foregroundListener() {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        debugPrint("========== FOREGROUND ==========");
        debugPrint("Title : ${message.notification?.title}");
        debugPrint("Body  : ${message.notification?.body}");
        debugPrint("Data  : ${message.data}");
        debugPrint("Image : ${_getImageUrl(message)}");

        final notification = message.notification;

        if (notification == null) return;

        final imageUrl = _getImageUrl(message);

        AndroidNotificationDetails androidDetails;

        if (imageUrl != null && imageUrl.isNotEmpty) {
          final imagePath = await _downloadAndSaveFile(
            imageUrl,
            "notification_${DateTime.now().millisecondsSinceEpoch}.jpg",
          );

          if (imagePath != null) {
            androidDetails = AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              styleInformation: BigPictureStyleInformation(
                FilePathAndroidBitmap(imagePath),
                hideExpandedLargeIcon: true,
                contentTitle: notification.title,
                summaryText: notification.body,
              ),
            );
          } else {
            androidDetails = AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            );
          }
        } else {
          androidDetails = AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          );
        }

        await _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: androidDetails,
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      });
    }
    /// App Open From Notification
    void openAppListener({
      required Function(RemoteMessage message) onOpen,
    }) {
      FirebaseMessaging.onMessageOpenedApp.listen(onOpen);
    }

    /// App Killed
    Future<void> checkInitialMessage({
      required Function(RemoteMessage message) onOpen,
    }) async {
      final RemoteMessage? message = await _messaging.getInitialMessage();

      if (message != null) {
        onOpen(message);
      }
    }

    /// Initialize
    Future<void> initialize({
      required Function(String token) onToken,
      required Function(RemoteMessage message) onNotificationTap,
    }) async {
      await requestPermission();
      await initLocalNotifications();

      final token = await getToken();

      if (token != null) {
        onToken(token);
      }

      tokenRefreshListener(onRefresh: onToken);
      foregroundListener();
      openAppListener(onOpen: onNotificationTap);
      await checkInitialMessage(onOpen: onNotificationTap);
    }

    /// Dispose and clean up
    void dispose() {
      // Clean up any subscriptions if needed
      // Note: FirebaseMessaging.onMessage and onMessageOpenedApp are streams
      // that don't need manual disposal in most cases
    }
  }