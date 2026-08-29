import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';
import '../translations/Translation_key/translation_keys.dart';

class OrderCancellationCard extends StatelessWidget {
  final String reason;
  final String date;
  final String cancelledBy;

  const OrderCancellationCard({
    super.key,
    required this.reason,
    required this.date,
    required this.cancelledBy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFEE2E2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cancel_outlined,
                color: AppColors.error,
                size: 20,
              ),

              const SizedBox(width: 8),

              Text(
                'Cancellation Details',
                style: AppTextStyles.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: AppColors.error,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Reason
          RichText(
            text: TextSpan(
              style: AppTextStyles.poppins(
                fontSize: 15,
                color: AppColors.foreground,
              ),
              children: [
                TextSpan(
                  text:
                  '${TranslationKeys.reason.tr}: ',
                  style: AppTextStyles.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                  ),
                ),
                TextSpan(
                  text: reason,
                  style: AppTextStyles.poppins(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Date
          RichText(
            text: TextSpan(
              style: AppTextStyles.poppins(
                fontSize: 15,
                color: AppColors.foreground,
              ),
              children: [
                TextSpan(
                  text:
                  '${TranslationKeys.date.tr}: ',
                  style: AppTextStyles.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                  ),
                ),
                TextSpan(
                  text: date,
                  style: AppTextStyles.poppins(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Cancelled By
          RichText(
            text: TextSpan(
              style: AppTextStyles.poppins(
                fontSize: 15,
                color: AppColors.foreground,
              ),
              children: [
                TextSpan(
                  text:
                  '${TranslationKeys.cancelledBy.tr}: ',
                  style: AppTextStyles.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                  ),
                ),
                TextSpan(
                  text: cancelledBy,
                  style: AppTextStyles.poppins(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}