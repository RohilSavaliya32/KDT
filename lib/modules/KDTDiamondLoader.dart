import 'package:flutter/material.dart';

class DiamondLoader extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const DiamondLoader({
    super.key,
    this.size = 30,
    this.strokeWidth = 3,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          color: color ?? const Color(0xFF005234),
        ),
      ),
    );
  }
}