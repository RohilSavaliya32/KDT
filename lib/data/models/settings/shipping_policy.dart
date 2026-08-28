class ShippingPolicyModel {
  final String? en;
  final String? ko;
  final String? ja;

  ShippingPolicyModel({
    this.en,
    this.ko,
    this.ja,
  });

  factory ShippingPolicyModel.fromJson(Map<String, dynamic> json) {
    return ShippingPolicyModel(
      en: json['en'],
      ko: json['ko'],
      ja: json['ja'] ?? json['jp'] ?? json['zh'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'ko': ko,
      'ja': ja,
    };
  }
}