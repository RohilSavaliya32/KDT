class ReturnsPolicyModel {
  final String? en;
  final String? ko;
  final String? zh;

  ReturnsPolicyModel({
    this.en,
    this.ko,
    this.zh,
  });

  factory ReturnsPolicyModel.fromJson(Map<String, dynamic> json) {
    return ReturnsPolicyModel(
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