import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../Setting_Controller/Currency_Controller.dart';
import '../Setting_Controller/currency_selection_controller.dart';

class CurrencySelectionView
    extends GetView<CurrencySelectionController> {
  const CurrencySelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyController =
    Get.find<CurrencyController>();

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
          'Currency',
          style: AppTextStyles.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.foreground,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: TextField(
                  onChanged: controller.onSearchChanged,
                  style: AppTextStyles.poppins(
                    fontSize: 14,
                    color: AppColors.foreground,
                  ),
                  cursorColor: AppColors.accent,
                  decoration: InputDecoration(
                    hintText: 'Search currency...',
                    hintStyle: AppTextStyles.poppins(
                      fontSize: 14,
                      color: AppColors.mutedForeground,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.iconGray,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                      ),
                    );
                  }

                  final list = controller.filteredCurrencies;

                  if (list.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'No Currency Found',
                              style: AppTextStyles.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.foreground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Currency list is currently unavailable.\n'
                                  'Please try again later.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: AppColors.divider,
                    ),
                    itemBuilder: (context, index) {
                      final item = list[index];

                      final code = item.code;
                      final name = item.name;
                      final rate = item.rate;

                      final isSelected =
                          currencyController.selectedCurrency.value ==
                              code;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '$code - $name',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: AppColors.foreground,
                          ),
                        ),
                        subtitle: Text(
                          '1 USD = ${rate.toStringAsFixed(4)} $code',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                          Icons.check_circle,
                          color: AppColors.accent,
                        )
                            : null,
                        onTap: () {
                          controller.selectCurrency(code);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}