import 'package:flutter/material.dart';
import 'package:kdt/utils/app_text_style.dart';

class OrderStatusChip extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const OrderStatusChip({
    super.key,
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: AppTextStyles.poppins(color: color, fontSize: 12, fontWeight: FontWeight.w500,),
          ),
        ],
      ),
    );
  }
}