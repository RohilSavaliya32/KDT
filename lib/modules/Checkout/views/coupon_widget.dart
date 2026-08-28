import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../controllers/checkout_controller.dart';

class CouponWidget extends StatefulWidget {
  final CheckoutController controller;

  const CouponWidget({
    super.key,
    required this.controller,
  });

  @override
  State<CouponWidget> createState() => _CouponWidgetState();
}

class _CouponWidgetState extends State<CouponWidget> {
  final ExpansionTileController _tileController =
  ExpansionTileController();

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Coupon Code + Apply
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.couponController,
                  decoration: InputDecoration(
                    hintText: "Coupon Code",
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: controller.applyCouponFromText,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.lightGray,
                    foregroundColor: AppColors.primaryDark,
                  ),
                  child: const Text("Apply"),
                ),
              ),
            ],
          ),

          if (controller.couponError.value.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              controller.couponError.value,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],

          const SizedBox(height: 10),

          /// Available Coupons
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderGray),
              borderRadius: BorderRadius.circular(2),
            ),
            child: ExpansionTile(
              controller: _tileController,
              tilePadding:
              const EdgeInsets.symmetric(horizontal: 12),
              title: Text(
                controller.selectedCoupon.value?.label ??
                    "Available Offers...",
                style: AppTextStyles.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              children: controller.availableCoupons.map((coupon) {
                final selected =
                    controller.selectedCoupon.value?.id == coupon.id;

                return InkWell(
                  onTap: () {
                    controller.selectCoupon(coupon);

                    /// Select hote hi dropdown close
                    Future.delayed(
                      const Duration(milliseconds: 100),
                          () {
                        if (mounted) {
                          _tileController.collapse();
                        }
                      },
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    color: selected
                        ? AppColors.accent
                        : Colors.transparent,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            coupon.label,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : Colors.black87,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }
}