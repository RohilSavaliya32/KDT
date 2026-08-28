import 'package:flutter/material.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';

class OrderTimelineItem extends StatelessWidget {
  final bool isLast;
  final String status;
  final String message;
  final String date;
  final Color color;
  final IconData icon;

  const OrderTimelineItem({
    super.key,
    required this.isLast,
    required this.status,
    required this.message,
    required this.date,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        // ==================================================
        // TIMELINE ICON + LINE
        // ==================================================

        SizedBox(
          width: 42,
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                  border: Border.all(
                    color: AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              ),

              if (!isLast)
                Container(
                  width: 2,
                  height: 78,
                  color: AppColors.border,
                ),
            ],
          ),
        ),

        // ==================================================
        // TIMELINE CONTENT
        // ==================================================

        Expanded(
          child: Container(
            margin: const EdgeInsets.only(
              bottom: 14,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius:
              BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.border,
              ),
              color: AppColors.cardBg,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // STATUS
                Text(
                  status,
                  style: AppTextStyles.lora(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w500,
                    color:
                    AppColors.foreground,
                  ),
                ),

                const SizedBox(height: 4),

                // MESSAGE
                Text(
                  message,
                  style:
                  AppTextStyles.poppins(
                    fontSize: 12,
                    color:
                    AppColors.mutedForeground,
                  ),
                ),

                const SizedBox(height: 10),

                // DATE
                Text(
                  date,
                  style:
                  AppTextStyles.poppins(
                    fontSize: 10,
                    color:
                    AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}