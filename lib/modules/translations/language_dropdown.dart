import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Translation_controllers/language_controller.dart';
import 'Translation_key/translation_keys.dart';

class LanguageBottomSheet extends StatelessWidget {
  const LanguageBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildTitle(),
          Expanded(
            child: _buildLanguageList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            TranslationKeys.selectLanguage.tr,
            style: GoogleFonts.lora(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F5B45),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageList() {
    return GetBuilder<LanguageController>(
      builder: (controller) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: controller.languages.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final language = controller.languages[index];
            final String code = language['code'];
            final String name = language['name'];
            final String nativeName = language['nativeName'];
            final String flag = language['flag'];
            final bool isSelected = controller.isSelected(code);

            return _buildLanguageItem(
              context: context,
              flag: flag,
              name: name,
              nativeName: nativeName,
              isSelected: isSelected,
              onTap: () {
                // Change language
                controller.setLanguage(code);
                // Close bottom sheet
                Get.back();
                // Show success snackbar
                Get.snackbar(
                  'Language Changed',
                  'Language changed to $nativeName',
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: const Color(0xFF0F5B45),
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageItem({
    required BuildContext context,
    required String flag,
    required String name,
    required String nativeName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            // Flag
            Text(
              flag,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 16),

            // Language name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nativeName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF0F5B45) : Colors.black87,
                    ),
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F5B45),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}