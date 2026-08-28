import 'package:flutter/material.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';
import '../Profile & Settings/currency_price_text.dart';
import 'OrderModel.dart';

class OrderMiniItemTile extends StatelessWidget {
  final OrderItemModel item;

  const OrderMiniItemTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.cardBg,
      shadowColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // ==================================================
            // IMAGE
            // ==================================================

            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.border,
                ),
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

            const SizedBox(width: 12),

            // ==================================================
            // TITLE + DESCRIPTION
            // ==================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title ?? '-',
                    style: AppTextStyles.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.foreground,
                    ),
                    overflow:
                    TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${item.carat?.toStringAsFixed(0) ?? '-'}c '
                        '${item.shape ?? ''} Diamond',
                    style: AppTextStyles.poppins(
                      fontSize: 14,
                      color:
                      AppColors.mutedForeground,
                    ),
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ==================================================
            // PRICE
            // ==================================================

            Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                CurrencyPriceText(
                  usdAmount:
                  (item.price ?? 0).toDouble(),
                  style: AppTextStyles.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}