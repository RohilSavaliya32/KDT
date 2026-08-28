class PolicyModel {
  final String? en;
  final String? ko;
  final String? ja;

  PolicyModel({
    this.en,
    this.ko,
    this.ja,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
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