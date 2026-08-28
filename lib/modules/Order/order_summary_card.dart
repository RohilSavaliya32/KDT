import 'package:flutter/material.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';

class OrderSummaryCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final IconData? titleIcon;

  const OrderSummaryCard({
    super.key,
    required this.title,
    required this.children,
    this.titleIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (titleIcon != null) ...[
                Icon(
                  titleIcon,
                  size: 18,
                  color: AppColors.iconGray,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: AppTextStyles.lora(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.foreground,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ...children,
        ],
      ),
    );
  }
}