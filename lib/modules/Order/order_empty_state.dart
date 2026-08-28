import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';
import '../Loader/Helper/Loader_helper.dart';
import '../translations/Translation_key/translation_keys.dart';

class OrderEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  const OrderEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
        boldText: false,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              // ==================================================
              // ICON
              // ==================================================

              const Icon(
                Icons.shopping_bag_outlined,
                size: 56,
                color: AppColors.mutedForeground,
              ),

              const SizedBox(height: 12),

              // ==================================================
              // TITLE
              // ==================================================

              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.lora(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.foreground,
                ),
              ),

              const SizedBox(height: 8),

              // ==================================================
              // SUBTITLE
              // ==================================================

              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.lora(
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // SHOP BUTTON
              // ==================================================

              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    AppNavigator.to(
                      "/navigation",
                      arguments: {
                        "tab": 2,
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    AppColors.accent,
                    foregroundColor:
                    AppColors.white,
                    disabledBackgroundColor:
                    AppColors.accentDisabled,
                    disabledForegroundColor:
                    AppColors.white,
                    elevation: 0,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(3),
                    ),
                  ),
                  child: Text(
                    TranslationKeys.shopDiamonds.tr,
                    style: AppTextStyles.lora(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}