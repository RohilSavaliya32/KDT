class ReturnsPolicyModel {
  final String? en;
  final String? ko;
  final String? ja;

  ReturnsPolicyModel({
    this.en,
    this.ko,
    this.ja,
  });

  factory ReturnsPolicyModel.fromJson(Map<String, dynamic> json) {
    return ReturnsPolicyModel(
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