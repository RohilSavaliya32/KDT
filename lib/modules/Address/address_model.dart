class AddressModel {
  final String id;
  final String type;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String country;
  final String zipCode;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.type,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: '${json['id'] ?? json['_id'] ?? ''}',
      type: '${json['type'] ?? json['addressType'] ?? 'shipping'}',
      fullName: '${json['fullName'] ?? json['full_name'] ?? json['name'] ?? ''}',
      phone: '${json['phone'] ?? json['mobile'] ?? json['phoneNumber'] ?? ''}',
      street: '${json['street'] ?? json['streetAddress'] ?? json['address'] ?? json['address1'] ?? ''}',
      city: '${json['city'] ?? ''}',
      state: '${json['state'] ?? json['province'] ?? json['region'] ?? ''}',
      country: '${json['country'] ?? ''}',
      zipCode: '${json['zipCode'] ?? json['zipcode'] ?? json['zip'] ?? ''}',
      isDefault: json['isDefault'] == true ||
          json['default'] == true ||
          json['is_default'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "fullName": fullName,
      "phone": phone,
      "street": street,
      "city": city,
      "state": state,
      "country": country,
      "zipCode": zipCode,
      "isDefault": isDefault,
    };
  }

  String get displayLabel {
    final parts = <String>[
      if (fullName.isNotEmpty) fullName,
      if (street.isNotEmpty) street,
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
      if (zipCode.isNotEmpty) zipCode,
    ];
    return parts.join(' • ');
  }
}