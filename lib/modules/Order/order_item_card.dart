import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';

import '../Profile & Settings/currency_price_text.dart';
import '../translations/Translation_key/translation_keys.dart';
import 'OrderModel.dart';

class OrderItemCard extends StatelessWidget {
  final OrderItemModel item;
  final VoidCallback? onViewDiamond;

  const OrderItemCard({
    super.key,
    required this.item,
    this.onViewDiamond,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          // =====================================================
          // IMAGE + TITLE + DESCRIPTION
          // =====================================================

          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.border,
                  ),
                  color: AppColors.lightGray,
                ),
                clipBehavior: Clip.antiAlias,
                child: item.image == null ||
                    item.image!.isEmpty
                    ? const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.mutedForeground,
                )
                    : Image.network(
                  item.image!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(
                    Icons.broken_image_outlined,
                    color:
                    AppColors.mutedForeground,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    Text(
                      item.title ?? "-",
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      AppTextStyles.poppins(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w600,
                        color:
                        AppColors.foreground,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // DESCRIPTION
                    Text(
                      "${item.carat?.toStringAsFixed(0) ?? '-'} ct • "
                          "${item.shape ?? ''} Diamond",
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style:
                      AppTextStyles.poppins(
                        fontSize: 13,
                        color:
                        AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // =====================================================
          // PRICE + VIEW DIAMOND
          // =====================================================

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            crossAxisAlignment:
            CrossAxisAlignment.center,
            children: [
              CurrencyPriceText(
                usdAmount:
                (item.price ?? 0).toDouble(),
                style:
                AppTextStyles.poppins(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  AppColors.foreground,
                ),
              ),

              if (onViewDiamond != null)
                SizedBox(
                  height: 38,
                  child:
                  ElevatedButton.icon(
                    onPressed: onViewDiamond,
                    icon: const Icon(
                      Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.white,
                    ),
                    label: Text(
                      TranslationKeys
                          .viewDiamond.tr,
                      style:
                      AppTextStyles.poppins(
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w600,
                        color:
                        AppColors.white,
                      ),
                    ),
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.accent,
                      foregroundColor:
                      AppColors.white,
                      elevation: 0,
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          8,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}