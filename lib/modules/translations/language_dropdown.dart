import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';
import 'Translation_controllers/language_controller.dart';
import 'Translation_key/translation_keys.dart';

class LanguageBottomSheet extends StatelessWidget {
  const LanguageBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          _buildTitle(),
          const SizedBox(height: 12),
          _buildLanguageList(),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      width: 45,
      height: 4.5,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            TranslationKeys.selectLanguage.tr,
            style: AppTextStyles.lora(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageList() {
    return GetBuilder<LanguageController>(
      builder: (controller) {
        return Column(
          children: controller.languages.map((language) {
            final String code = language['code'];
            final String name = language['name'];
            final String nativeName = language['nativeName'];
            final String flag = language['flag'];
            final bool isSelected = controller.isSelected(code);

            return _buildLanguageItem(
              flag: flag,
              name: name,
              nativeName: nativeName,
              isSelected: isSelected,
              onTap: () {
                if (!isSelected) {
                  controller.setLanguage(code);
                }
                Get.back();
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildLanguageItem({
    required String flag,
    required String name,
    required String nativeName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isSelected ? AppColors.accent.withOpacity(0.05) : Colors.transparent,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            children: [
              // Flag Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent.withOpacity(0.1) : AppColors.lightGray,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),

              // Language names
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nativeName,
                      style: AppTextStyles.poppins(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.accent : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      name,
                      style: AppTextStyles.poppins(
                        fontSize: 13,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.accent,
                  size: 24,
                )
              else
                Icon(
                  Icons.circle_outlined,
                  color: Colors.grey.shade300,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
