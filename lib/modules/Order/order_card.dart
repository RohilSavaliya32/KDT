import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_colors.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../utils/app_text_style.dart';
import '../Profile & Settings/currency_price_text.dart';
import '../translations/Translation_key/translation_keys.dart';
import 'OrderModel.dart';
import 'order_info_block.dart';
import 'bank_details_dialog.dart';
import 'payment_proof_dialog.dart';

class OrderCard extends StatefulWidget {
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
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final status = (widget.order.status ?? '').toLowerCase();
    final isAwaitingPayment = status == 'awaiting payment';
    final isPaymentProcessing = status.contains('payment processing');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // ORDER INFORMATION HEADER
                // ==================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: OrderInfoBlock(
                        label: TranslationKeys.orderPlaced.tr.toUpperCase(),
                        value: "#${widget.shortOrderNo}",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OrderInfoBlock(
                        label: "DATE PLACED".toUpperCase(),
                        value: widget.formatDate(widget.order.createdAt).split(',').first,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OrderInfoBlock(
                        label: TranslationKeys.total.tr.toUpperCase(),
                        valueWidget: CurrencyPriceText(
                          usdAmount: (widget.order.total ?? 0).toDouble(),
                          style: AppTextStyles.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F5B45),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ==================================================
                // STATUS + ACTION ROW
                // ==================================================
                Row(
                  children: [
                    _buildStatusChip(widget.order.status ?? '-'),
                    const SizedBox(width: 8),
                    const Spacer(),
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: OutlinedButton.icon(
                        onPressed: widget.onViewDetails,
                        icon: const Icon(
                          Icons.open_in_new,
                          size: 14,
                          color: AppColors.foreground,
                        ),
                        label: Text(
                          TranslationKeys.viewDetails.tr,
                          style: AppTextStyles.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.foreground,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: isExpanded ? const Color(0xFF003E29) : Colors.transparent,
                          border: Border.all(
                            color: isExpanded ? const Color(0xFF003E29) : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: isExpanded ? Colors.white : AppColors.foreground,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.border),

          if (!isExpanded) ...[
            // ==================================================
            // COLLAPSED FOOTER
            // ==================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.order.items.length} ${widget.order.items.length > 1 ? TranslationKeys.itemsOrdered.tr.toLowerCase() : 'item'}",
                    style: AppTextStyles.poppins(
                      fontSize: 14,
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (isAwaitingPayment) ...[
                    const SizedBox(height: 12),
                    _buildPaymentButtons(),
                  ],
                ],
              ),
            ),
          ] else ...[
            // ==================================================
            // EXPANDED CONTENT
            // ==================================================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ORDER ITEMS",
                    style: AppTextStyles.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.mutedForeground,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.order.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, index) {
                      final item = widget.order.items[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: item.image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item.image!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.image_outlined,
                                        color: AppColors.disabledGray,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.image_outlined,
                                    color: AppColors.disabledGray,
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title ?? '-',
                                  style: AppTextStyles.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.foreground,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (item.sku != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    item.sku!,
                                    style: AppTextStyles.poppins(
                                      fontSize: 12,
                                      color: AppColors.mutedForeground,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                CurrencyPriceText(
                                  usdAmount: (item.price ?? 0).toDouble(),
                                  style: AppTextStyles.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 16),

                  Text(
                    "Bank Transfer Details",
                    style: AppTextStyles.poppins(
                      fontSize: 14,
                      color: AppColors.mutedForeground,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (!isPaymentProcessing)
                    Text(
                      "to our bank account and upload the receipt.",
                      style: AppTextStyles.poppins(
                        fontSize: 14,
                        color: const Color(0xFFD4AF37),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (isAwaitingPayment) ...[
                    const SizedBox(height: 16),
                    _buildPaymentButtons(),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Get.dialog(const BankDetailsDialog());
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              "Bank Transfer Details",
              style: AppTextStyles.poppins(fontSize: 12, color: AppColors.foreground, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Get.dialog(PaymentProofDialog(order: widget.order));
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 10),
              backgroundColor: const Color(0xFF1F1F1F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text(
              "Submit Payment Proof",
              style: AppTextStyles.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color bgColor = const Color(0xFFE3F2FD);
    Color textColor = const Color(0xFF1976D2);

    final s = status.toLowerCase();
    if (s.contains('payment processing')) {
      bgColor = const Color(0xFFE3F2FD);
      textColor = const Color(0xFF1976D2);
    } else if (s.contains('cancel')) {
      bgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFD32F2F);
    } else if (s.contains('awaiting payment')) {
      bgColor = const Color(0xFFFFF8E1);
      textColor = const Color(0xFFF57F17);
    } else if (s.contains('paid') || s.contains('completed')) {
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: AppTextStyles.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
