import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:kdt/utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../translations/Translation_key/translation_keys.dart';

class DiamondsTypeFilter extends StatelessWidget {
  final List<String> types;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const DiamondsTypeFilter({
    super.key,
    required this.types,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
        boldText: false,
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Text(
            '${TranslationKeys.type.tr}:',
            style: AppTextStyles.lora(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          ...List.generate(types.length, (index) {
            final selected = selectedIndex == index;
            return _pillButton(
              context: context,
              title: types[index],
              selected: selected,
              onTap: () => onSelected(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _pillButton({
    required BuildContext context,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuart,
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.foreground
                : AppColors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected
                  ? AppColors.foreground
                  : AppColors.lightgray,
            ),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: AppTextStyles.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected
                  ? AppColors.white
                  : AppColors.foreground,
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }
}