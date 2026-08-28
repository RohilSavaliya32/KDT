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
    this.borderRadius =
    const BorderRadius.all(
      Radius.circular(8),
    ),
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
          // Shimmer effect
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
                  stops: [
                    0.0,
                    0.5,
                    1.0,
                  ],
                  transform:
                  const GradientRotation(0.5),
                ),
              ),
            ),
          ),

          // Center icon
          Center(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image_outlined,
                  size: 40,
                  color: AppColors.darkGray,
                ),
                const SizedBox(height: 8),
                Text(
                  'Loading image...',
                  style: AppTextStyles.poppins(
                    fontSize: 12,
                    color: AppColors.darkGray,
                  ),
                ),
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
  final void Function(OrderItemModel item)?
  onViewDiamond;

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
        textScaler:
        const TextScaler.linear(1.0),
        boldText: false,
      ),
      child: Obx(() {
        final currentOrder = c.selectedOrder.value?.id == order.id ? c.selectedOrder.value! : order;

        print("Payment Image => ""${currentOrder.paymentImage}",);

        final isCancelled = (currentOrder.status ?? '').toLowerCase().contains('cancel');

        final status = (currentOrder.status ?? '').trim().toLowerCase();

        final showCancelButton = status == 'processing';

        final summaryTotal = currentOrder.displayTotal ?? currentOrder.displaySubtotal ?? currentOrder.total;

        final summarySubtotal = currentOrder.displaySubtotal ?? currentOrder.subtotalUsd ?? currentOrder.total;

        final shippingAddressText = currentOrder.shippingAddress?.fullAddress ?? '-';

        final isAwaitingPayment =
            (currentOrder.status ?? '')
                .trim()
                .toLowerCase() ==
                'awaiting payment';

        return Scaffold(
          backgroundColor:
          AppColors.background,

          appBar: AppBar(
            backgroundColor:
            AppColors.background,
            surfaceTintColor:
            AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(
              color: AppColors.foreground,
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.foreground,
                size: 20,
              ),
              onPressed: Get.back,
            ),
            title: Text(
              "Order Details",
              style: AppTextStyles.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.foreground,
              ),
            ),
          ),

          body: FadeSlideIn(
            duration: const Duration(milliseconds: 500),
            slideOffset: 15,
            child: SingleChildScrollView(
              padding:
              const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // ORDER HEADER
                  // ==================================================

                  OrderSectionTitle(
                    title:
                    '${TranslationKeys.orderHash.tr} '
                        '${c.shortOrderNumber(currentOrder.id)}',
                    subtitle:
                    '${TranslationKeys.placedOn.tr} '
                        '${c.formatDate(currentOrder.createdAt)}',
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // ORDER SUMMARY
                  // ==================================================

                  OrderSummaryCard(
                    title:
                    TranslationKeys.orderSummary.tr,
                    children: [
                      OrderSummaryRow(
                        label:
                        TranslationKeys.subtotal.tr,
                        valueWidget:
                        CurrencyPriceText(
                          usdAmount:
                          (summarySubtotal ?? 0)
                              .toDouble(),
                          style:
                          AppTextStyles.poppins(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w400,
                            color:
                            AppColors.foreground,
                          ),
                        ),
                      ),

                      OrderSummaryRow(
                        label:
                        TranslationKeys.shipping.tr,
                        value:
                        TranslationKeys.free.tr,
                      ),

                      const Divider(
                        height: 24,
                        color:
                        AppColors.divider,
                      ),

                      OrderSummaryRow(
                        label:
                        TranslationKeys.total.tr,
                        valueWidget:
                        CurrencyPriceText(
                          usdAmount:
                          (summaryTotal ?? 0)
                              .toDouble(),
                          style:
                          AppTextStyles.poppins(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.w500,
                            color:
                            AppColors.accent,
                          ),
                        ),
                        labelStyle:
                        AppTextStyles.poppins(
                          fontSize: 20,
                          fontWeight:
                          FontWeight.w500,
                          color:
                          AppColors.foreground,
                        ),
                      ),

                      // ==================================================
                      // CANCEL ORDER
                      // ==================================================

                      if (showCancelButton) ...[
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child:
                          ElevatedButton.icon(
                            icon: const Icon(
                              Icons.cancel_outlined,
                              size: 20,
                              color:
                              AppColors.white,
                            ),
                            label: Text(
                              TranslationKeys
                                  .cancelOrder.tr,
                              style:
                              AppTextStyles.poppins(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.w600,
                                color:
                                AppColors.white,
                              ),
                            ),
                            style:
                            ElevatedButton.styleFrom(
                              backgroundColor:
                              AppColors.error,
                              foregroundColor:
                              AppColors.white,
                              elevation: 0,
                              shadowColor:
                              AppColors.transparent,
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                  12,
                                ),
                              ),
                            ),
                            onPressed: () {
                              Get.dialog(
                                MediaQuery(
                                  data:
                                  MediaQuery.of(context)
                                      .copyWith(
                                    textScaler:
                                    const TextScaler
                                        .linear(1.0),
                                    boldText: false,
                                  ),
                                  child:
                                  CancelOrderDialog(
                                    onConfirm:
                                        (reason) async {
                                      final success =
                                      await c.cancelOrder(
                                        orderId:
                                        currentOrder.id,
                                        reason: reason,
                                      );

                                      if (success) {
                                        Get.back();

                                        Get.snackbar(
                                          TranslationKeys
                                              .cancelled
                                              .tr,
                                          TranslationKeys
                                              .orderCancelledSuccessfully
                                              .tr,
                                          snackPosition:
                                          SnackPosition
                                              .TOP,
                                          backgroundColor:
                                          AppColors
                                              .accent,
                                          colorText:
                                          AppColors
                                              .background,
                                        );
                                      }

                                      return success;
                                    },
                                  ),
                                ),
                                barrierDismissible:
                                false,
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // PAYMENT REQUIRED
                  // ==================================================

                  if (isAwaitingPayment)
                    OrderPaymentRequiredCard(
                      orderId:
                      currentOrder.id,
                      formattedAmount:
                      c.formatCurrency(
                        summaryTotal,
                      ),
                      amountValue:
                      (summaryTotal ?? 0)
                          .toDouble(),
                      currency: 'USD',
                    ),

                  if (isAwaitingPayment)
                    const SizedBox(height: 16),

                  // ==================================================
                  // CUSTOMER INFO
                  // ==================================================

                  OrderSummaryCard(
                    title:
                    TranslationKeys.customerInfo.tr,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 20,
                            color:
                            AppColors.accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentOrder
                                  .customerName ??
                                  '-',
                              style:
                              AppTextStyles.poppins(
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w500,
                                color:
                                AppColors
                                    .mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            size: 20,
                            color:
                            AppColors.accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentOrder
                                  .customerEmail ??
                                  '-',
                              style:
                              AppTextStyles.poppins(
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w500,
                                color:
                                AppColors
                                    .mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 20,
                            color:
                            AppColors.accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              currentOrder
                                  .customerPhone ??
                                  '-',
                              style:
                              AppTextStyles.poppins(
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w500,
                                color:
                                AppColors
                                    .mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // SHIPPING ADDRESS
                  // ==================================================

                  OrderSummaryCard(
                    title:
                    TranslationKeys
                        .shippingAddress.tr,
                    children: [
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 20,
                            color:
                            AppColors.accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              shippingAddressText,
                              style:
                              AppTextStyles.poppins(
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w500,
                                color:
                                AppColors
                                    .mutedForeground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // PAYMENT PROOF
                  // ==================================================

                  if (currentOrder.paymentImage !=
                      null &&
                      currentOrder.paymentImage!
                          .isNotEmpty)
                    OrderSummaryCard(
                      title: "Payment Proof",
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.dialog(
                              Dialog(
                                backgroundColor:
                                AppColors.background,
                                insetPadding:
                                const EdgeInsets.all(
                                  20,
                                ),
                                child:
                                InteractiveViewer(
                                  minScale: 0.8,
                                  maxScale: 5,
                                  child:
                                  FutureBuilder<
                                      String?>(
                                    future:
                                    SecureStorage
                                        .getToken(),
                                    builder:
                                        (context,
                                        snapshot) {
                                      if (!snapshot.hasData) {
                                        return const SizedBox(
                                          height: 180,
                                          child:
                                          Center(
                                            child:
                                            CircularProgressIndicator(
                                              color:
                                              AppColors
                                                  .accent,
                                            ),
                                          ),
                                        );
                                      }

                                      final token =
                                      snapshot.data!;

                                      final imageUrl =
                                          "https://kdtdiamond.com/api/v1/orders/"
                                          "${currentOrder.id}"
                                          "/payment-proof-file?token=$token";

                                      debugPrint(
                                        "Image URL => "
                                            "$imageUrl",
                                      );

                                      return FutureBuilder<
                                          String?>(
                                        future:
                                        SecureStorage
                                            .getToken(),
                                        builder:
                                            (context,
                                            snapshot) {
                                          if (snapshot
                                              .connectionState !=
                                              ConnectionState
                                                  .done) {
                                            return Container(
                                              height: 180,
                                              width: double
                                                  .infinity,
                                              alignment:
                                              Alignment
                                                  .center,
                                              child:
                                              const CircularProgressIndicator(
                                                color:
                                                AppColors
                                                    .accent,
                                              ),
                                            );
                                          }

                                          if (!snapshot.hasData ||
                                              snapshot.data ==
                                                  null ||
                                              snapshot.data!
                                                  .isEmpty) {
                                            return Container(
                                              height:
                                              180,
                                              width:
                                              double.infinity,
                                              alignment:
                                              Alignment
                                                  .center,
                                              color:
                                              AppColors
                                                  .lightGray,
                                              child:
                                              const Icon(
                                                Icons
                                                    .lock_outline,
                                                size: 50,
                                                color:
                                                AppColors
                                                    .darkGray,
                                              ),
                                            );
                                          }

                                          final token =
                                          snapshot
                                              .data!;

                                          final imageUrl =
                                              "https://kdtdiamond.com/api/v1/orders/"
                                              "${currentOrder.id}"
                                              "/payment-proof-file?token=$token";

                                          debugPrint(
                                            "Token => "
                                                "$token",
                                          );

                                          return ClipRRect(
                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                              8,
                                            ),
                                            child:
                                            Image.network(
                                              imageUrl,
                                              headers: {
                                                "Authorization":
                                                "Bearer $token",
                                                "Accept":
                                                "image/*",
                                              },
                                              height: 180,
                                              width: double
                                                  .infinity,
                                              fit: BoxFit
                                                  .cover,
                                              loadingBuilder:
                                                  (
                                                  context,
                                                  child,
                                                  loadingProgress,
                                                  ) {
                                                if (loadingProgress ==
                                                    null) {
                                                  return child;
                                                }

                                                return const SkeletonLoader(
                                                  height:
                                                  180,
                                                );
                                              },
                                              errorBuilder:
                                                  (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                  ) {
                                                debugPrint(
                                                  "Image Error => "
                                                      "$error",
                                                );

                                                debugPrint(
                                                  "Image URL => "
                                                      "$imageUrl",
                                                );

                                                return Container(
                                                  height:
                                                  180,
                                                  width: double
                                                      .infinity,
                                                  alignment:
                                                  Alignment
                                                      .center,
                                                  color:
                                                  AppColors
                                                      .lightGray,
                                                  child:
                                                  Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      const Icon(
                                                        Icons
                                                            .broken_image_outlined,
                                                        size: 50,
                                                        color:
                                                        AppColors
                                                            .darkGray,
                                                      ),
                                                      const SizedBox(
                                                        height: 8,
                                                      ),
                                                      Text(
                                                        "Unable to load image",
                                                        style:
                                                        AppTextStyles
                                                            .poppins(
                                                          fontSize:
                                                          12,
                                                          color:
                                                          AppColors
                                                              .darkGray,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },

                          child:
                          FutureBuilder<String?>(
                            future:
                            SecureStorage.getToken(),
                            builder:
                                (context, snapshot) {
                              if (snapshot
                                  .connectionState !=
                                  ConnectionState.done) {
                                return const SkeletonLoader(
                                  height: 180,
                                );
                              }

                              final token =
                                  snapshot.data ?? "";

                              final imageUrl =
                                  "https://kdtdiamond.com/api/v1/orders/"
                                  "${currentOrder.id}"
                                  "/payment-proof-file?token=$token";

                              return ClipRRect(
                                borderRadius:
                                BorderRadius.circular(
                                  8,
                                ),
                                child:
                                Image.network(
                                  imageUrl,
                                  headers: {
                                    "Authorization":
                                    "Bearer $token",
                                  },
                                  height: 180,
                                  width:
                                  double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (
                                      context,
                                      child,
                                      loadingProgress,
                                      ) {
                                    if (loadingProgress ==
                                        null) {
                                      return child;
                                    }

                                    return const SkeletonLoader(
                                      height: 180,
                                    );
                                  },
                                  errorBuilder: (
                                      _,
                                      error,
                                      __,
                                      ) {
                                    debugPrint(
                                      "Thumbnail Error => "
                                          "$error",
                                    );

                                    return Container(
                                      height: 180,
                                      alignment:
                                      Alignment
                                          .center,
                                      color:
                                      AppColors
                                          .lightGray,
                                      child:
                                      const Icon(
                                        Icons
                                            .broken_image_outlined,
                                        size: 50,
                                        color:
                                        AppColors
                                            .darkGray,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 8),

                        Center(
                          child: Text(
                            "Tap image to view",
                            style:
                            AppTextStyles.poppins(
                              fontSize: 12,
                              color: AppColors
                                  .mutedForeground,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // TRACKING HISTORY
                  // ==================================================

                  OrderSummaryCard(
                    title:
                    TranslationKeys
                        .trackingHistory.tr,
                    children: [
                      if (currentOrder
                          .trackingLogs.isEmpty)
                        Text(
                          TranslationKeys
                              .noTrackingHistoryAvailable
                              .tr,
                          style:
                          AppTextStyles.poppins(
                            color: AppColors
                                .mutedForeground,
                          ),
                        )
                      else
                        ...List.generate(
                          currentOrder
                              .trackingLogs.length,
                              (index) {
                            final log =
                            currentOrder
                                .trackingLogs[index];

                            final isLast =
                                index ==
                                    currentOrder
                                        .trackingLogs
                                        .length -
                                        1;

                            return OrderTimelineItem(
                              isLast: isLast,
                              status:
                              log.status ?? '-',
                              message:
                              log.message ?? '',
                              date:
                              c.formatDate(
                                log.date,
                              ),
                              color:
                              c.statusColor(
                                log.status,
                              ),
                              icon:
                              c.statusIcon(
                                log.status,
                              ),
                            );
                          },
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // ITEMS ORDERED
                  // ==================================================

                  OrderSummaryCard(
                    title:
                    TranslationKeys
                        .itemsOrdered.tr,
                    children: [
                      ...currentOrder.items.map(
                            (item) =>
                            OrderItemCard(
                              item: item,
                              onViewDiamond:
                              onViewDiamond == null
                                  ? null
                                  : () =>
                                  onViewDiamond!(
                                    item,
                                  ),
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  String _cancelledByText(
      String? value,
      ) {
    if (value == null || value.isEmpty) {
      return '-';
    }

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