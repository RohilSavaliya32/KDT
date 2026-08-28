import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'Notification_Model.dart';
import 'Notification_api_service.dart';

class NotificationPreferencesController extends GetxController with WidgetsBindingObserver {
  // Service ab internally token handle karta hai
  final NotificationPreferencesService _service = NotificationPreferencesService();

  NotificationPreferencesController();

  /// Observable Data
  final Rxn<NotificationPreferences> preferences =
  Rxn<NotificationPreferences>();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchPreferences();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkSystemNotificationStatus();
    }
  }

  Future<void> fetchPreferences() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _service.fetchPreferences();

      preferences.value = result;
      await checkSystemNotificationStatus();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkSystemNotificationStatus() async {
    if (preferences.value == null) return;

    try {
      NotificationSettings settings = await FirebaseMessaging.instance.getNotificationSettings();
      
      bool isSystemEnabled = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (preferences.value!.isNotificationEnabled != isSystemEnabled) {
        _updateLocalMasterToggle(isSystemEnabled);
      }
    } catch (e) {
      debugPrint("Error checking notification status: $e");
    }
  }

  void _updateLocalMasterToggle(bool value) {
    final prefs = preferences.value;
    if (prefs != null) {
      preferences.value = prefs.copyWith(isNotificationEnabled: value);
      preferences.refresh();
    }
  }

  Future<void> toggleMaster(bool value) async {
    if (value) {
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      bool isSystemEnabled = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!isSystemEnabled) {
        _updateLocalMasterToggle(false);
        Get.snackbar(
          "Action Required",
          "Notifications are disabled in your phone settings. Please enable them to turn this on.",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        return;
      }
    }
    
    _update((p) => p.copyWith(isNotificationEnabled: value));
  }

  Future<void> savePreferences() async {
    final prefs = preferences.value;

    if (prefs == null) return;

    try {
      isSaving.value = true;

      final updated = await _service.updatePreferences(prefs);

      preferences.value = updated;

      Get.snackbar(
        "Success",
        "Notification preferences updated successfully.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to save preferences.",
        messageText: Text(e.toString()),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSaving.value = false;
    }
  }

  void _update(NotificationPreferences Function(NotificationPreferences) update) {
    final prefs = preferences.value;
    if (prefs == null) return;
    preferences.value = update(prefs);
  }

  void toggleOrderStatus(bool value) => _update((p) => p.copyWith(orderUpdates: value));

  void togglePayments(bool value) => _update((p) => p.copyWith(paymentUpdates: value));

  void toggleDeliveryUpdates(bool value) => _update((p) => p.copyWith(deliveryUpdates: value));

  void togglePromotions(bool value) => _update((p) => p.copyWith(promotions: value));

  void toggleProductAlerts(bool value) => _update((p) => p.copyWith(productAlerts: value));

  void toggleReviewRequests(bool value) => _update((p) => p.copyWith(reviews: value));

}
