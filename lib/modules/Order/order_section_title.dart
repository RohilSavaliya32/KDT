import 'package:flutter/material.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';

class OrderSectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const OrderSectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            height: 1,
            color: AppColors.foreground,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          subtitle,
          style: AppTextStyles.poppins(
            fontSize: 12,
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}