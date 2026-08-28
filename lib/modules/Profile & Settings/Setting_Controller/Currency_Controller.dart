import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Setting_Api/Currency_api.dart';

class CurrencyController extends GetxController {
  CurrencyController({CurrencyApiService? apiService})
      : _apiService = apiService ?? CurrencyApiService();

  final CurrencyApiService _apiService;

  final selectedCurrency = 'USD'.obs;
  final selectedRate = 1.0.obs;
  final selectedSymbol = Rxn<String>();

  final rates = <String, double>{}.obs;
  final isDetecting = false.obs;

  @override
  void onInit() {
    super.onInit();
    detectAndSetCurrency();
  }

  String _resolveDeviceLocale() {
    final locale = Get.deviceLocale;

    if (locale?.countryCode != null && locale!.countryCode!.isNotEmpty) {
      return '${locale.languageCode}-${locale.countryCode}';
    }

    return locale?.languageCode ?? 'en';
  }

  Future<void> detectAndSetCurrency() async {
    try {
      isDetecting.value = true;

      final locale = _resolveDeviceLocale();

      final result = await _apiService.fetchCurrencyContext(
        locale: locale,
      );

      rates
        ..clear()
        ..addAll(result.rates);

      final code = result.detectedCurrency;
      final rate = result.rates[code] ?? 1.0;

      final symbol = result.availableCurrencies
          .where((e) => e.code == code)
          .map((e) => e.symbol)
          .cast<String?>()
          .firstOrNull;

      setCurrency(
        code: code,
        rate: rate,
        symbol: symbol,
      );

      debugPrint(
        '✅ Currency Detected: $code | Locale: $locale | Rate: $rate',
      );
    } catch (e) {
      debugPrint('❌ Currency Detection Failed: $e');
    } finally {
      isDetecting.value = false;
    }
  }

  void setCurrency({
    required String code,
    required double rate,
    String? symbol,
  }) {
    selectedCurrency.value = code;
    selectedRate.value = rate;
    selectedSymbol.value = symbol;
  }
}