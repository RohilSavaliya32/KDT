import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../Profile & Settings/currency_price_text.dart';
import '../translations/Translation_key/translation_keys.dart';
import 'OrderModel.dart';
import 'order_info_block.dart';
import 'order_status_chip.dart';
import 'order_mini_item_tile.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final String shortOrderNo;
  final String Function(String?) formatDate;
  final Color statusColor;
  final IconData statusIcon;
  final VoidCallback onViewDetails;

  const OrderCard({
    super.key,
    required this.order,
    required this.shortOrderNo,
    required this.formatDate,
    required this.statusColor,
    required this.statusIcon,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final firstItem =
    order.items.isNotEmpty ? order.items.first : null;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
        boldText: false,
      ),
      child: Card(
        elevation: 0,
        color: AppColors.cardBg,
        shadowColor: AppColors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(
            color: AppColors.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // ==================================================
              // ORDER INFORMATION
              // ==================================================

              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: OrderInfoBlock(
                      label:
                      TranslationKeys.orderPlaced.tr,
                      value: formatDate(order.createdAt)
                          .split(',')
                          .first,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: OrderInfoBlock(
                      label:
                      TranslationKeys.total.tr,
                      valueWidget:
                      CurrencyPriceText(
                        usdAmount:
                        (order.total ?? 0)
                            .toDouble(),
                        style:
                        AppTextStyles.poppins(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.w500,
                          color:
                          AppColors.foreground,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: OrderInfoBlock(
                      label:
                      '${TranslationKeys.orderHash.tr} ',
                      value: shortOrderNo,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ==================================================
              // STATUS + VIEW DETAILS
              // ==================================================

              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment:
                WrapCrossAlignment.center,
                children: [
                  OrderStatusChip(
                    text: order.status ?? '-',
                    color: statusColor,
                    icon: statusIcon,
                  ),

                  SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: onViewDetails,
                      style:
                      OutlinedButton.styleFrom(
                        foregroundColor:
                        AppColors.foreground,
                        side: const BorderSide(
                          color: AppColors.border,
                        ),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(2),
                        ),
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                      ),
                      child: Text(
                        TranslationKeys
                            .viewDetails.tr,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style:
                        AppTextStyles.poppins(
                          fontWeight:
                          FontWeight.w500,
                          color:
                          AppColors.foreground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // DIVIDER
              // ==================================================

              const Divider(
                height: 1,
                color: AppColors.divider,
              ),

              const SizedBox(height: 14),

              // ==================================================
              // ITEMS ORDERED TITLE
              // ==================================================

              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color: AppColors.iconGray,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    TranslationKeys.itemsOrdered.tr,
                    style:
                    AppTextStyles.poppins(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w400,
                      color:
                      AppColors.foreground,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ==================================================
              // FIRST ITEM
              // ==================================================

              if (firstItem != null)
                OrderMiniItemTile(
                  item: firstItem,
                ),

              // ==================================================
              // MORE ITEMS
              // ==================================================

              if (order.items.length > 1) ...[
                const SizedBox(height: 8),

                Text(
                  '+ ${order.items.length - 1} '
                      '${TranslationKeys.moreItems.tr}',
                  style:
                  AppTextStyles.poppins(
                    fontSize: 13,
                    color:
                    AppColors.mutedForeground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}