import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'Setting_Controller/Currency_Controller.dart';
import 'currency_helper.dart';

class CurrencyPriceText extends StatelessWidget {
  final double usdAmount;
  final TextStyle? style;
  final String prefix;
  final String suffix;

  const CurrencyPriceText({
    super.key,
    required this.usdAmount,
    this.style,
    this.prefix = '',
    this.suffix = '',
  });

  String _localeFor(String code) {
    switch (code.toUpperCase()) {
      case 'INR':
      case 'NPR':
      case 'BTN':
        return 'en_IN';
      default:
        return 'en_US';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CurrencyController>()) {
      return Text(
        '$prefix\$${usdAmount.toStringAsFixed(0)}$suffix',
        style: style,
      );
    }

    final controller = Get.find<CurrencyController>();

    return Obx(() {
      final code = controller.selectedCurrency.value;
      final amount = usdAmount * controller.selectedRate.value;

      final symbol = controller.selectedSymbol.value?.isNotEmpty == true
          ? controller.selectedSymbol.value!
          : CurrencyHelper.symbol(code);

      final formattedAmount = NumberFormat.currency(
        locale: _localeFor(code),
        symbol: '',
        decimalDigits: 0,
      ).format(amount);

      return Text(
        '$prefix$symbol$formattedAmount$suffix',
        style: style,
      );
    });
  }
}