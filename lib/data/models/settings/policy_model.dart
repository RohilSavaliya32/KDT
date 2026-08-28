class PolicyModel {
  final String? en;
  final String? ko;
  final String? zh;

  PolicyModel({
    this.en,
    this.ko,
    this.zh,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
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