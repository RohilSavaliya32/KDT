class ContactSettingsModel {
  final String? whatsappNumber;
  final String? kakaoId;
  final String? wechatId;
  final String? phoneKorea;
  final String? phoneIndia;
  final String? calendlyKorea;
  final String? calendlyIndia;

  ContactSettingsModel({
    this.whatsappNumber,
    this.kakaoId,
    this.wechatId,
    this.phoneKorea,
    this.phoneIndia,
    this.calendlyKorea,
    this.calendlyIndia,
  });

  factory ContactSettingsModel.fromJson(Map<String, dynamic> json) {
    return ContactSettingsModel(
      whatsappNumber: json['whatsappNumber'],
      kakaoId: json['kakaoId'],
      wechatId: json['wechatId'],
      phoneKorea: json['phoneKorea'],
      phoneIndia: json['phoneIndia'],
      calendlyKorea: json['calendlyKorea'],
      calendlyIndia: json['calendlyIndia'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'whatsappNumber': whatsappNumber,
      'kakaoId': kakaoId,
      'wechatId': wechatId,
      'phoneKorea': phoneKorea,
      'phoneIndia': phoneIndia,
      'calendlyKorea': calendlyKorea,
      'calendlyIndia': calendlyIndia,
    };
  }
}