import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_text_style.dart';
import '../../../utils/app_colors.dart';
import '../../translations/Translation_key/translation_keys.dart';

class DiamondsAdvancedFilters extends StatelessWidget {
  final double width;
  final List<String> cutOptions;
  final List<String> colorOptions;
  final List<String> clarityOptions;
  final List<String> certificationOptions;

  final List<int> selectedCutIndexes;
  final List<int> selectedColorIndexes;
  final List<int> selectedClarityIndexes;
  final List<int> selectedCertificationIndexes;

  final ValueChanged<int> onCutSelected;
  final ValueChanged<int> onCertificationSelected;
  final ValueChanged<int> onColorSelected;
  final ValueChanged<int> onClaritySelected;
  final ValueChanged<String> onCaratMinChanged;
  final ValueChanged<String> onCaratMaxChanged;

  const DiamondsAdvancedFilters({
    super.key,
    required this.width,
    required this.cutOptions,
    required this.colorOptions,
    required this.clarityOptions,
    required this.certificationOptions,
    required this.selectedCutIndexes,
    required this.selectedColorIndexes,
    required this.selectedClarityIndexes,
    required this.selectedCertificationIndexes,
    required this.onCutSelected,
    required this.onCertificationSelected,
    required this.onColorSelected,
    required this.onClaritySelected,
    required this.onCaratMinChanged,
    required this.onCaratMaxChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = width > 1000;

    return Wrap(
      spacing: 26,
      runSpacing: 20,
      children: [
        SizedBox(
          width: isDesktop ? 180 : double.infinity,
          child: _filterColumn(
            context: context,
            title: TranslationKeys.carat.tr,
            child: Row(
              children: [
                Expanded(
                  child: _inputBox(
                    context: context,
                    hintText: TranslationKeys.from.tr,
                    onChanged: onCaratMinChanged,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _inputBox(
                    context: context,
                    hintText: TranslationKeys.to.tr,
                    onChanged: onCaratMaxChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: isDesktop ? 220 : double.infinity,
          child: _filterColumn(
            context: context,
            title: TranslationKeys.cut.tr,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(cutOptions.length, (index) {
                final label = cutOptions[index];
                final selected = selectedCutIndexes.contains(index);

                return _smallOption(
                  context: context,
                  text: label,
                  selected: selected,
                  onTap: () => onCutSelected(index),
                );
              }),
            ),
          ),
        ),
        SizedBox(
          width: isDesktop ? 250 : double.infinity,
          child: _filterColumn(
            context: context,
            title: TranslationKeys.color.tr,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(colorOptions.length, (index) {
                final label = colorOptions[index];
                final selected = selectedColorIndexes.contains(index);

                return _smallOption(
                  context: context,
                  text: label,
                  selected: selected,
                  onTap: () => onColorSelected(index),
                );
              }),
            ),
          ),
        ),
        SizedBox(
          width: isDesktop ? 260 : double.infinity,
          child: _filterColumn(
            context: context,
            title: TranslationKeys.clarity.tr,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(clarityOptions.length, (index) {
                final label = clarityOptions[index];
                final selected = selectedClarityIndexes.contains(index);

                return _smallOption(
                  context: context,
                  text: label,
                  selected: selected,
                  onTap: () => onClaritySelected(index),
                );
              }),
            ),
          ),
        ),
        SizedBox(
          width: isDesktop ? 240 : double.infinity,
          child: _filterColumn(
            context: context,
            title: TranslationKeys.certification.tr,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(certificationOptions.length, (index) {
                final label = certificationOptions[index];
                final selected = selectedCertificationIndexes.contains(index);

                return _smallOption(
                  context: context,
                  text: label,
                  selected: selected,
                  onTap: () => onCertificationSelected(index),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterColumn({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.lora(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _inputBox({
    required BuildContext context,
    required String hintText,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      height: 44,
      child: TextField(
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        textAlignVertical: TextAlignVertical.center,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(r'^\d*\.?\d*'),
          ),
        ],
        onChanged: onChanged,
        style: AppTextStyles.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.darkGray,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.borderGray,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.foreground,
              width: 1.5,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _smallOption({
    required BuildContext context,
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: AppColors.border,
            width: 1.2,
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}