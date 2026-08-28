class ShippingPolicyModel {
  final String? en;
  final String? ko;
  final String? zh;

  ShippingPolicyModel({
    this.en,
    this.ko,
    this.zh,
  });

  factory ShippingPolicyModel.fromJson(Map<String, dynamic> json) {
    return ShippingPolicyModel(
      en: json['en'],
      ko: json['ko'],
      zh: json['zh'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'ko': ko,
      'zh': zh,
    };
  }
}