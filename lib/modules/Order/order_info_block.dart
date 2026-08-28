import 'package:flutter/material.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';

class OrderInfoBlock extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const OrderInfoBlock({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
  }) : assert(value != null || valueWidget != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.poppins(
              color: AppColors.mutedForeground,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          valueWidget ??
              Text(
                value!,
                style: AppTextStyles.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.foreground,
                ),
                overflow: TextOverflow.ellipsis,
              ),
        ],
      ),
    );
  }
}