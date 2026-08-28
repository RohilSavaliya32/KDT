import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import 'Notification_Controller.dart';

class NotificationPreferencesView
    extends GetView<NotificationPreferencesController> {
  const NotificationPreferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: AppColors.foreground,
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: AppColors.foreground,
          ),
          tooltip: 'Back',
        ),
        title: Text(
          'Notification Preferences',
          style: AppTextStyles.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.foreground,
          ),
        ),
      ),

      // ================= BODY =================
      body: Obx(() {
        // ================= LOADING =================
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.accent,
            ),
          );
        }

        // ================= ERROR =================
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Something went wrong:\n"
                        "${controller.errorMessage.value}",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.poppins(
                      fontSize: 14,
                      color: AppColors.error,
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: controller.fetchPreferences,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Retry",
                      style: AppTextStyles.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ================= DATA =================
        final prefs = controller.preferences.value;

        if (prefs == null) {
          return const SizedBox.shrink();
        }

        final bool isMasterEnabled = prefs.isNotificationEnabled;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMasterToggle(
                isMasterEnabled,
              ),

              Divider(
                height: 32,
                color: AppColors.divider,
              ),

              Text(
                "CATEGORIES",
                style: AppTextStyles.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mutedForeground,
                  letterSpacing: 1.1,
                ),
              ),

              const SizedBox(height: 8),

              _buildToggleTile(
                title: "Order Status",
                subtitle: "Confirmations, packings, and delays",
                value: isMasterEnabled && prefs.orderUpdates,
                onChanged: isMasterEnabled
                    ? controller.toggleOrderStatus
                    : null,
                enabled: isMasterEnabled,
              ),

              _buildToggleTile(
                title: "Payments",
                subtitle: "Receipt reviews and confirmations",
                value: isMasterEnabled && prefs.paymentUpdates,
                onChanged:
                isMasterEnabled ? controller.togglePayments : null,
                enabled: isMasterEnabled,
              ),

              _buildToggleTile(
                title: "Delivery Updates",
                subtitle: "Shipping progress and tracking details",
                value: isMasterEnabled && prefs.deliveryUpdates,
                onChanged: isMasterEnabled
                    ? controller.toggleDeliveryUpdates
                    : null,
                enabled: isMasterEnabled,
              ),

              _buildToggleTile(
                title: "Promotions & Offers",
                subtitle: "Campaigns and exclusive discounts",
                value: isMasterEnabled && prefs.promotions,
                onChanged:
                isMasterEnabled ? controller.togglePromotions : null,
                enabled: isMasterEnabled,
              ),

              _buildToggleTile(
                title: "Product Alerts",
                subtitle: "Wishlist price drops and restock alerts",
                value: isMasterEnabled && prefs.productAlerts,
                onChanged: isMasterEnabled
                    ? controller.toggleProductAlerts
                    : null,
                enabled: isMasterEnabled,
              ),

              _buildToggleTile(
                title: "Review Requests",
                subtitle: "Help others by rating your purchases",
                value: isMasterEnabled && prefs.reviews,
                onChanged: isMasterEnabled
                    ? controller.toggleReviewRequests
                    : null,
                enabled: isMasterEnabled,
              ),

              // Bottom button ke liye extra space
              const SizedBox(height: 20),
            ],
          ),
        );
      }),

      // ============================================================
      // FIXED SAVE BUTTON
      // ============================================================
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value ||
            controller.errorMessage.value.isNotEmpty ||
            controller.preferences.value == null) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              16,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.foreground,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor:
                  AppColors.accentDisabled,
                  disabledForegroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: controller.isSaving.value
                    ? null
                    : controller.savePreferences,
                child: controller.isSaving.value
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
                    : Text(
                  "Save Settings",
                  style: AppTextStyles.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ============================================================
  // MASTER TOGGLE
  // ============================================================

  Widget _buildMasterToggle(bool value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notifications",
                style: AppTextStyles.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "Receive push notifications for your orders and updates.",
                style: AppTextStyles.poppins(
                  fontSize: 13,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),

        Switch(
          value: value,
          activeColor: AppColors.white,
          activeTrackColor: AppColors.foreground,
          inactiveThumbColor: AppColors.disabledGray,
          inactiveTrackColor: AppColors.borderGray,
          onChanged: controller.toggleMaster,
        ),
      ],
    );
  }

  // ============================================================
  // TOGGLE TILE
  // ============================================================

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    style: AppTextStyles.poppins(
                      fontSize: 12,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),

            Switch(
              value: value,
              activeColor: AppColors.white,
              activeTrackColor: AppColors.foreground,
              inactiveThumbColor: AppColors.disabledGray,
              inactiveTrackColor: AppColors.borderGray,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}