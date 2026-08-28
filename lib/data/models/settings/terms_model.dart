class TermsModel {
  final String? en;
  final String? ko;
  final String? ja;

  TermsModel({
    this.en,
    this.ko,
    this.ja,
  });

  factory TermsModel.fromJson(Map<String, dynamic> json) {
    return TermsModel(
      en: json['en'],
      ko: json['ko'],
      ja: json['ja'] ?? json['jp'] ?? json['zh'], // Support ja, jp, or fallback to zh if that's what API sends
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