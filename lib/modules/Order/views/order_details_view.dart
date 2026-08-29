import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/modules/fade_slide_in.dart';
import 'package:kdt/utils/app_colors.dart';

import '../../../core/storage/api_constants.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../utils/app_text_style.dart';
import '../../translations/Translation_key/translation_keys.dart';
import '../../Profile & Settings/currency_price_text.dart';
import '../cancel_order_dialog.dart';
import '../controllers/order_history_controller.dart';
import '../OrderModel.dart';
import '../order_cancellation_card.dart';
import '../order_item_card.dart';
import '../order_payment_required_card.dart';
import '../order_section_title.dart';
import '../order_summary_card.dart';
import '../order_summary_row.dart';
import '../order_timeline_item.dart';

// ============================================================
// SKELETON LOADER
// ============================================================

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 180,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: AppColors.lightGray,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: const Alignment(-1.0, 0.0),
                  end: const Alignment(1.0, 0.0),
                  colors: const [
                    AppColors.lightGray,
                    AppColors.background,
                    AppColors.lightGray,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  transform: const GradientRotation(0.5),
                ),
              ),
            ),
          ),
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 40, color: AppColors.darkGray),
                SizedBox(height: 8),
                CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ORDER DETAILS
// ============================================================

class OrderDetailsView extends StatelessWidget {
  final OrderModel order;
  final void Function(OrderItemModel item)? onViewDiamond;

  const OrderDetailsView({
    super.key,
    required this.order,
    this.onViewDiamond,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.find<OrderHistoryController>();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
        boldText: false,
      ),
      child: Obx(() {
        final currentOrder = c.selectedOrder.value?.id == order.id ? c.selectedOrder.value! : order;
        final status = (currentOrder.status ?? '').trim().toLowerCase();
        final isAwaitingPayment = status == 'awaiting payment';
        final showCancelButton = status == 'processing' || status == 'payment processing';

        final double summaryTotal = (currentOrder.total ?? 0).toDouble();
        final double discount = (currentOrder.discount ?? 0).toDouble();
        final double summarySubtotal = currentOrder.subtotalUsd?.toDouble() ?? (summaryTotal + discount);

        final isCancelled = status.contains('cancelled');

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: AppColors.background,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.foreground, size: 20),
              onPressed: Get.back,
            ),
            title: Text(
              "Order Details",
              style: AppTextStyles.lora(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.foreground),
            ),
          ),
          body: FadeSlideIn(
            duration: const Duration(milliseconds: 500),
            slideOffset: 15,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrderSectionTitle(
                    title: '${TranslationKeys.orderHash.tr} ${c.shortOrderNumber(currentOrder.id)}',
                    subtitle: '${TranslationKeys.placedOn.tr} ${c.formatDate(currentOrder.createdAt)}',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order Status",
                          style: AppTextStyles.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              c.statusIcon(currentOrder.status),
                              color: c.statusColor(currentOrder.status),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              (currentOrder.status ?? '-').toUpperCase(),
                              style: AppTextStyles.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.foreground,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  OrderSummaryCard(
                    title: TranslationKeys.orderSummary.tr,
                    children: [
                      OrderSummaryRow(
                        label: TranslationKeys.subtotal.tr,
                        valueWidget: CurrencyPriceText(
                          usdAmount: summarySubtotal,
                          style: AppTextStyles.poppins(fontSize: 16, color: AppColors.foreground),
                        ),
                      ),
                      if (currentOrder.discount != null && currentOrder.discount! > 0)
                        OrderSummaryRow(
                          label: "${TranslationKeys.discount.tr}${currentOrder.couponCode != null ? ' (${currentOrder.couponCode})' : ''}",
                          valueWidget: CurrencyPriceText(
                            usdAmount: discount,
                            prefix: '-',
                            style: AppTextStyles.poppins(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w500),
                          ),
                        ),
                      OrderSummaryRow(label: TranslationKeys.shipping.tr, value: TranslationKeys.free.tr),
                      const Divider(height: 24, color: AppColors.divider),
                      OrderSummaryRow(
                        label: TranslationKeys.total.tr,
                        valueWidget: CurrencyPriceText(
                          usdAmount: summaryTotal,
                          style: AppTextStyles.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF0F5B45)),
                        ),
                        labelStyle: AppTextStyles.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.foreground),
                      ),
                      if (showCancelButton) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.cancel_outlined, size: 20, color: AppColors.white),
                            label: Text(TranslationKeys.cancelOrder.tr, style: AppTextStyles.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => _handleCancel(context, c, currentOrder),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isCancelled) ...[
                    OrderCancellationCard(
                      reason: currentOrder.cancellationReason ?? '-',
                      date: c.formatDate(currentOrder.cancelledAt),
                      cancelledBy: _cancelledByText(currentOrder.cancelledBy),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (isAwaitingPayment) ...[
                    OrderPaymentRequiredCard(
                      orderId: currentOrder.id,
                      formattedAmount: c.formatCurrency(summaryTotal),
                      amountValue: (summaryTotal ?? 0).toDouble(),
                      currency: 'USD',
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildInfoSection(TranslationKeys.customerInfo.tr, [
                    _infoRow(Icons.person_outline, currentOrder.customerName ?? '-'),
                    _infoRow(Icons.email_outlined, currentOrder.customerEmail ?? '-'),
                    _infoRow(Icons.phone_outlined, currentOrder.customerPhone ?? '-'),
                  ]),
                  const SizedBox(height: 16),
                  _buildInfoSection(TranslationKeys.shippingAddress.tr, [
                    _infoRow(Icons.location_on_outlined, currentOrder.shippingAddress?.fullAddress ?? '-'),
                  ]),
                  const SizedBox(height: 16),

                  // ==================================================
                  // PAYMENT PROOF SECTION
                  // ==================================================
                  if (currentOrder.paymentImage != null && currentOrder.paymentImage!.isNotEmpty)
                    _buildPaymentProofSection(currentOrder),

                  const SizedBox(height: 16),
                  OrderSummaryCard(
                    title: TranslationKeys.trackingHistory.tr,
                    children: [
                      if (currentOrder.trackingLogs.isEmpty)
                        Text(
                          TranslationKeys.noTrackingHistoryAvailable.tr,
                          style: AppTextStyles.poppins(color: AppColors.mutedForeground),
                        )
                      else
                        ...() {
                          final reversedLogs = currentOrder.trackingLogs.reversed.toList();
                          return reversedLogs.asMap().entries.map((entry) {
                            final index = entry.key;
                            final log = entry.value;
                            return OrderTimelineItem(
                              isLast: index == reversedLogs.length - 1,
                              status: log.status ?? '-',
                              message: log.message ?? '',
                              date: c.formatDate(log.date),
                              color: c.statusColor(log.status),
                              icon: c.statusIcon(log.status),
                            );
                          });
                        }(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OrderSummaryCard(
                    title: TranslationKeys.itemsOrdered.tr,
                    children: currentOrder.items.map((item) => OrderItemCard(
                      item: item,
                      onViewDiamond: onViewDiamond == null ? null : () => onViewDiamond!(item),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return OrderSummaryCard(
      title: title,
      children: [
        ...children.expand((widget) => [widget, const SizedBox(height: 10)]).toList()..removeLast(),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTextStyles.poppins(fontSize: 14, color: AppColors.textSecondary))),
      ],
    );
  }

  Widget _buildPaymentProofSection(OrderModel currentOrder) {
    return OrderSummaryCard(
      title: "Payment Proof",
      children: [
        FutureBuilder<String?>(
          future: SecureStorage.getToken(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SkeletonLoader(height: 200);
            final token = snapshot.data!;
            final imageUrl = "${ApiConstants.baseUrl}/orders/${currentOrder.id}/payment-proof-file?token=$token";

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _showFullImage(context, imageUrl, token),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.network(
                        imageUrl,
                        headers: {"Authorization": "Bearer $token"},
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) => progress == null ? child : const SkeletonLoader(height: 200),
                        errorBuilder: (_, __, ___) => _imageErrorWidget(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    "Tap to enlarge payment receipt",
                    style: AppTextStyles.poppins(fontSize: 12, color: AppColors.mutedForeground, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showFullImage(BuildContext context, String imageUrl, String token) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: Get.back,
              child: Container(color: Colors.black54),
            ),
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                headers: {"Authorization": "Bearer $token"},
                fit: BoxFit.contain,
                loadingBuilder: (_, child, progress) => progress == null ? child : const CircularProgressIndicator(color: Colors.white),
                errorBuilder: (_, __, ___) => _imageErrorWidget(isDark: true),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: Get.back,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageErrorWidget({bool isDark = false}) {
    return Container(
      height: 200,
      width: double.infinity,
      color: isDark ? Colors.grey[900] : AppColors.lightGray,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, size: 48, color: isDark ? Colors.white54 : AppColors.darkGray),
          const SizedBox(height: 8),
          Text(
            "Unable to load payment receipt",
            style: AppTextStyles.poppins(fontSize: 12, color: isDark ? Colors.white70 : AppColors.darkGray),
          ),
        ],
      ),
    );
  }

  void _handleCancel(BuildContext context, OrderHistoryController c, OrderModel currentOrder) {
    Get.dialog(
      CancelOrderDialog(
        onConfirm: (reason) async {
          final success = await c.cancelOrder(orderId: currentOrder.id, reason: reason);
          if (success) {
            Get.back();
            Get.snackbar('Order Cancelled', 'Your order has been successfully cancelled.', snackPosition: SnackPosition.TOP, backgroundColor: Colors.green, colorText: Colors.white);
          }
          return success;
        },
      ),
    );
  }

  String _cancelledByText(String? value) {
    if (value == null || value.isEmpty) return '-';
    switch (value.toUpperCase()) {
      case 'USER':
        return TranslationKeys.you.tr;
      case 'ADMIN':
        return TranslationKeys.admin.tr;
      default:
        return value;
    }
  }
}
