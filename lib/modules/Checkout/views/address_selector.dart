// ============================================================
// FILE: widgets/address_selector.dart (Updated)
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_decorations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../Address/address_model.dart';
import '../../translations/Translation_key/translation_keys.dart';
import '../controllers/checkout_controller.dart';

class AddressSelector extends StatelessWidget {
  final CheckoutController controller;

  const AddressSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.savedAddresses.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // QUICK AUTOFILL LABEL
            // ============================================================
            Row(
              children: [
                Icon(
                  Icons.autorenew_outlined,
                  size: 16,
                  color: AppColors.primaryDark,
                ),
                const SizedBox(width: 6),
                Text(
                  "Quick Autofill from Saved Addresses",
                  style: AppTextStyles.poppins(
                    fontSize: AppFontSizes.s13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ============================================================
            // ADDRESS SELECTOR BUTTON
            // ============================================================
            InkWell(
              onTap: () => _openAddressBottomSheet(context),
              borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
                  border: Border.all(
                    color: controller.selectedAddressId.value != null
                        ? AppColors.primaryDark
                        : AppColors.borderGray,
                    width: controller.selectedAddressId.value != null ? 1.5 : 1,
                  ),
                  boxShadow: AppDecorations.smoothShadow,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: controller.selectedAddressId.value != null
                          ? AppColors.primaryDark
                          : AppColors.darkGray,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Obx(() {
                        final selectedId = controller.selectedAddressId.value;
                        if (selectedId == null) {
                          return Text(
                            "Select a saved address",
                            style: AppTextStyles.poppins(
                              fontSize: AppFontSizes.s13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.darkGray,
                            ),
                          );
                        }
                        final selected = controller.savedAddresses
                            .firstWhereOrNull((e) => e.id == selectedId);
                        if (selected == null) {
                          return Text(
                            "Select a saved address",
                            style: AppTextStyles.poppins(
                              fontSize: AppFontSizes.s13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.darkGray,
                            ),
                          );
                        }
                        return Text(
                          selected.displayLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.poppins(
                            fontSize: AppFontSizes.s14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.darkGray,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ============================================================
  // ADDRESS BOTTOM SHEET (60% Height with Grip)
  // ============================================================
  void _openAddressBottomSheet(BuildContext context) {
    final addresses = controller.savedAddresses;
    final selectedId = controller.selectedAddressId.value;
    final screenHeight = MediaQuery.of(context).size.height;

    Get.bottomSheet(
      Container(
        height: screenHeight * 0.60,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDecorations.cardRadius)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ============================================================
            // GRIP HANDLE
            // ============================================================
            Center(
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta! > 10) {
                    Get.back();
                  }
                },
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ============================================================
            // HEADER
            // ============================================================
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primaryDark,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  "Select Address",
                  style: AppTextStyles.lora(
                    fontSize: AppFontSizes.s22,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.borderGray),
            const SizedBox(height: 12),

            // ============================================================
            // ADDRESS LIST
            // ============================================================
            Expanded(
              child: ListView.separated(
                itemCount: addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  final isSelected = selectedId == address.id;

                  return _buildAddressItem(
                    address: address,
                    isSelected: isSelected,
                    onTap: () {
                      controller.onAddressSelected(address.id);
                      Get.back();
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // ============================================================
            // CLEAR SELECTION BUTTON (visible only when address selected)
            // ============================================================
            if (selectedId != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: InkWell(
                  onTap: () {
                    controller.clearShippingFields();
                    Get.back();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.clear_outlined,
                          color: AppColors.error,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Clear selected address",
                          style: AppTextStyles.poppins(
                            fontSize: AppFontSizes.s13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDecorations.cardRadius)),
      ),
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.primaryDark.withOpacity(0.3),
      enableDrag: true,
    );
  }

  // ============================================================
  // ADDRESS ITEM - Radio Button Before Name, Single Line Address
  // ============================================================
  Widget _buildAddressItem({
    required AddressModel address,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryDark.withOpacity(0.06)
              : AppColors.white,
          borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
          border: Border.all(
            color: isSelected ? AppColors.primaryDark : AppColors.borderGray,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: isSelected ? null : AppDecorations.smoothShadow,
        ),
        child: Row(
          children: [
            // ============================================================
            // RADIO BUTTON (Before Name)
            // ============================================================
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primaryDark : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primaryDark : AppColors.darkGray,
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? const Icon(
                Icons.check_rounded,
                color: AppColors.white,
                size: 14,
              )
                  : null,
            ),
            const SizedBox(width: 14),

            // ============================================================
            // ADDRESS DETAILS - Single Line with Ellipsis
            // ============================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  Text(
                    address.fullName,
                    style: AppTextStyles.poppins(
                      fontSize: AppFontSizes.s15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Address in single line with ellipsis
                  Text(
                    "${address.street}, ${address.city}, ${address.state} ${address.zipCode}, ${address.country}",
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.poppins(
                      fontSize: AppFontSizes.s13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  // Phone (optional)
                  if (address.phone.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      "📞 ${address.phone}",
                      style: AppTextStyles.poppins(
                        fontSize: AppFontSizes.s12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}