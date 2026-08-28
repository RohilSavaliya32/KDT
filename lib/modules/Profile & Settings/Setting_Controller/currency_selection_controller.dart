import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../Setting_Api/Currency_api.dart';
import '../Setting_Controller/Currency_Controller.dart';
import '../Setting_Model/currency_model.dart';

class CurrencySelectionController extends GetxController {
  CurrencySelectionController({
    required this.currencyController,
    required this.apiService,
  });

  final CurrencyController currencyController;
  final CurrencyApiService apiService;

  final isLoading = false.obs;
  final searchText = ''.obs;
  final currencies = <CurrencyModel>[].obs;

  List<CurrencyModel> get filteredCurrencies {
    final query = searchText.value.trim().toLowerCase();

    if (query.isEmpty) return currencies;

    return currencies.where((item) {
      return item.code.toLowerCase().contains(query) ||
          item.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    loadCurrencyList();
  }

  String _resolveDeviceLocale() {
    final locale = Get.deviceLocale;

    if (locale?.countryCode != null && locale!.countryCode!.isNotEmpty) {
      return '${locale.languageCode}-${locale.countryCode}';
    }

    return locale?.languageCode ?? 'en';
  }

  CurrencyModel? _findCurrency(String code) {
    try {
      return currencies.firstWhere((item) => item.code == code);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadCurrencyList() async {
    try {
      isLoading.value = true;

      final result = await apiService.fetchCurrencyContext(
        locale: _resolveDeviceLocale(),
      );

      currencyController.rates
        ..clear()
        ..addAll(result.rates);

      currencies.assignAll(result.availableCurrencies);

      debugPrint(
        '✅ Currency list loaded: ${currencies.length} currencies',
      );
    } catch (e) {
      debugPrint('❌ Failed to load currency list: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String value) {
    searchText.value = value;
  }

  void selectCurrency(String code) {
    final model = _findCurrency(code);

    currencyController.setCurrency(
      code: code,
      rate: currencyController.rates[code] ?? 1.0,
      symbol: model?.symbol,
    );

    debugPrint('💱 Selected Currency: $code');

    Get.back();
  }
}