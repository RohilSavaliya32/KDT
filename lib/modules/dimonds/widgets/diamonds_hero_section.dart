import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../translations/Translation_key/translation_keys.dart';

class DiamondsHeroSection extends StatelessWidget {
  const DiamondsHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        children: [
          Text(
            TranslationKeys.diamonds.tr,
            style: AppTextStyles.lora(
              fontSize: 35,
              fontWeight: FontWeight.w500,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: screenWidth * 0.9,
            child: Text(
              TranslationKeys.browseCollectionDescription.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}