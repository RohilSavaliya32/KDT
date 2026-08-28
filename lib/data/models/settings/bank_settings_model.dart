class BankSettingsModel {
  final String? bankName;
  final String? accountName;
  final String? accountNumber;
  final String? routingNumber;
  final String? swiftCode;

  BankSettingsModel({
    this.bankName,
    this.accountName,
    this.accountNumber,
    this.routingNumber,
    this.swiftCode,
  });

  factory BankSettingsModel.fromJson(Map<String, dynamic> json) {
    return BankSettingsModel(
      bankName: json['bankName'],
      accountName: json['accountName'],
      accountNumber: json['accountNumber'],
      routingNumber: json['routingNumber'],
      swiftCode: json['swiftCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'routingNumber': routingNumber,
      'swiftCode': swiftCode,
    };
  }
}