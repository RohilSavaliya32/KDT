class CurrencyModel {
  final String code;
  final String name;
  final double rate;
  final String? symbol;

  CurrencyModel({
    required this.code,
    required this.name,
    required this.rate,
    this.symbol,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json, {Map<String, double>? ratesMap,}) {
    final code = json['code']?.toString() ?? '';
    return CurrencyModel(
      code: code,
      name: json['name']?.toString() ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? ratesMap?[code] ?? 1.0,
      symbol: json['symbol']?.toString(),
    );
  }
}