import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppDecorations {
  static const double cardRadius = 16.0;
  static const double buttonRadius = 8.0;
  static const double inputRadius = 12.0;

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 15,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get smoothShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static BoxDecoration cardDecoration({
    Color? color,
    double? radius,
    List<BoxShadow>? shadow,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.white,
      borderRadius: BorderRadius.circular(radius ?? cardRadius),
      boxShadow: shadow ?? softShadow,
      border: border,
    );
  }
}
