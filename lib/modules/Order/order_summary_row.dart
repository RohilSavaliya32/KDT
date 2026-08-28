import 'package:flutter/material.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';

class OrderSummaryRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const OrderSummaryRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.labelStyle,
    this.valueStyle,
  }) : assert(value != null || valueWidget != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: labelStyle ??
                  AppTextStyles.poppins(
                    fontSize: 14,
                    color: AppColors.mutedForeground,
                  ),
            ),
          ),

          valueWidget ??
              Text(
                value!,
                style: valueStyle ??
                    AppTextStyles.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.foreground,
                    ),
              ),
        ],
      ),
    );
  }
}