import 'package:flutter/material.dart';
import '../../KDTDiamondLoader.dart';

class AppLoader extends StatelessWidget {
  final String label;
  final Color color;

  const AppLoader({
    super.key,
    this.label = 'Loading...',
    this.color = const Color(0xFF0E6B5D),
  });

  @override
  Widget build(BuildContext context) {
    return const DiamondLoader();
  }
}
