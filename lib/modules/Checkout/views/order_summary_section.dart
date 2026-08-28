// ============================================================
// FILE: widgets/order_summary_section.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../Profile & Settings/currency_price_text.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../translations/Translation_key/translation_keys.dart';
import '../controllers/checkout_controller.dart';
import 'coupon_widget.dart';
import 'section_header.dart';

class OrderSummarySection extends StatelessWidget {
  const OrderSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CheckoutController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          icon: Icons.receipt_long_outlined,
          title: "Order Summary",
        ),
        const SizedBox(height: 14),
        Divider(color: AppColors.borderGray),
        const SizedBox(height: 18),
        _buildProductList(context),
        const SizedBox(height: 10),
        CouponWidget(controller: controller),
        const SizedBox(height: 16),
        _buildAppliedCoupon(controller),
        const SizedBox(height: 16),
        _buildPriceDetails(controller),
        const SizedBox(height: 14),
        Divider(color: AppColors.borderGray),
        const SizedBox(height: 14),
        Obx(() => _TotalWidget(total: controller.total)),
        const SizedBox(height: 26),
        _PlaceOrderButton(controller: controller),
      ],
    );
  }

  // ============================================================
  // PRODUCT LIST
  // ============================================================
  Widget _buildProductList(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Obx(() {
      return Column(
        children: cartController.cartItems.map((item) {
          final usdPrice = double.tryParse(item.price.toString()) ?? 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ProductItemWidget(
              title: item.diamondTitle.toString(),
              priceWidget: CurrencyPriceText(
                usdAmount: usdPrice,
                style: AppTextStyles.poppins(
                  fontSize: AppFontSizes.s14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryDark,
                ),
              ),
              qty: item.quantity.value,
            ),
          );
        }).toList(),
      );
    });
  }

  // ============================================================
  // APPLIED COUPON
  // ============================================================
  Widget _buildAppliedCoupon(CheckoutController controller) {
    return Obx(() {
      final applied = controller.appliedCoupon.value;
      if (applied == null) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${TranslationKeys.couponApplied.tr}: ${applied.code}",
                    style: AppTextStyles.poppins(
                      fontSize: AppFontSizes.s13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${applied.discountPercent}% Off",
                    style: AppTextStyles.poppins(
                      fontSize: AppFontSizes.s12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: controller.removeAppliedCoupon,
              child: Text(
                TranslationKeys.remove.tr,
                style: AppTextStyles.poppins(
                  fontSize: AppFontSizes.s12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ============================================================
  // PRICE DETAILS
  // ============================================================
  Widget _buildPriceDetails(CheckoutController controller) {
    return Obx(() {
      final subtotal = controller.subtotal;
      final discount = controller.discountAmount;

      return Column(
        children: [
          _PriceRow(
            label: TranslationKeys.subtotal.tr,
            priceWidget: CurrencyPriceText(
              usdAmount: subtotal,
              style: AppTextStyles.poppins(
                fontSize: AppFontSizes.s14,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (discount > 0) ...[
            const SizedBox(height: 10),
            _PriceRow(
              label: "${TranslationKeys.discount.tr} (${controller.appliedCoupon.value?.discountPercent ?? 0}%)",
              priceWidget: CurrencyPriceText(
                usdAmount: discount,
                prefix: '-',
                style: AppTextStyles.poppins(
                  fontSize: AppFontSizes.s14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.success,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          _PriceRow(
            label: TranslationKeys.shipping.tr,
            priceWidget: Text(
              "Free",
              style: AppTextStyles.poppins(
                fontSize: AppFontSizes.s14,
                fontWeight: FontWeight.w400,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ============================================================
// PRICE ROW HELPER
// ============================================================

class _PriceRow extends StatelessWidget {
  final String label;
  final Widget priceWidget;

  const _PriceRow({
    required this.label,
    required this.priceWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.poppins(
            fontSize: AppFontSizes.s14,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        priceWidget,
      ],
    );
  }
}

// ============================================================
// PRODUCT ITEM WIDGET
// ============================================================

class _ProductItemWidget extends StatelessWidget {
  final String title;
  final Widget priceWidget;
  final int qty;

  const _ProductItemWidget({
    required this.title,
    required this.priceWidget,
    required this.qty,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$title x$qty',
            style: AppTextStyles.poppins(
              fontSize: AppFontSizes.s14,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        priceWidget,
      ],
    );
  }
}

// ============================================================
// TOTAL WIDGET
// ============================================================

class _TotalWidget extends StatelessWidget {
  final double total;
  const _TotalWidget({required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          TranslationKeys.total.tr,
          style: AppTextStyles.poppins(
            fontSize: AppFontSizes.s18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        CurrencyPriceText(
          usdAmount: total,
          style: AppTextStyles.poppins(
            fontSize: AppFontSizes.s18,
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PLACE ORDER BUTTON
// ============================================================

class _PlaceOrderButton extends StatelessWidget {
  final CheckoutController controller;
  const _PlaceOrderButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isPlacingOrder.value;
      final canPlaceOrder = controller.isFormValid.value && !isLoading;

      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: canPlaceOrder ? AppColors.primaryDark : AppColors.disabledGray,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
            elevation: 0,
          ),
          onPressed: canPlaceOrder ? controller.placeOrder : null,
          child: isLoading
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                TranslationKeys.placeOrder.tr,
                style: AppTextStyles.poppins(
                  fontSize: AppFontSizes.s16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ],
          )
              : Text(
            TranslationKeys.placeOrder.tr,
            style: AppTextStyles.poppins(
              fontSize: AppFontSizes.s16,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        ),
      );
    });
  }
}