import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final String? imageUrl;
  final IconData? icon;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.imageUrl,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.white,
          side: BorderSide(color: AppColors.white.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageUrl != null)
              Image.network(imageUrl!, height: 20, width: 20),
            if (icon != null) Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(text),
          ],
        ),
      ),
    );
  }
}