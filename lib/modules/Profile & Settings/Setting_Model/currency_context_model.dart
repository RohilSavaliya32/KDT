import 'currency_model.dart';

class CurrencyContextModel {
  final String detectedCurrency;
  final Map<String, double> rates;
  final List<CurrencyModel> availableCurrencies;

  CurrencyContextModel({
    required this.detectedCurrency,
    required this.rates,
    required this.availableCurrencies,
  });

  factory CurrencyContextModel.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] ?? {});

    final rates = <String, double>{};

    (data['rates'] as Map?)?.forEach((key, value) {
      if (value is num) {
        rates[key.toString()] = value.toDouble();
      }
    });

    final currencies = (data['availableCurrencies'] as List? ?? [])
        .whereType<Map>()
        .map(
          (item) => CurrencyModel.fromJson(
        Map<String, dynamic>.from(item),
        ratesMap: rates,
      ),
    )
        .toList();

    return CurrencyContextModel(
      detectedCurrency: data['detectedCurrency']?.toString() ?? 'USD',
      rates: rates,
      availableCurrencies: currencies,
    );
  }
}