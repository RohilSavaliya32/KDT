class TermsModel {
  final String? en;
  final String? ko;
  final String? zh;

  TermsModel({
    this.en,
    this.ko,
    this.zh,
  });

  factory TermsModel.fromJson(Map<String, dynamic> json) {
    return TermsModel(
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