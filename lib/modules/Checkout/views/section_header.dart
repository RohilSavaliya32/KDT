import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryDark),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTextStyles.lora(
            fontSize: AppFontSizes.s20,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}