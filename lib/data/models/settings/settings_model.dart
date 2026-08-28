import 'package:kdt/data/models/settings/retunrn_policy.dart';
import 'package:kdt/data/models/settings/shipping_policy.dart';

import 'bank_settings_model.dart';
import 'contact_settings_model.dart';
import 'firebase_settings_model.dart';
import 'home_settings_model.dart';
import 'policy_model.dart';
import 'terms_model.dart';
class SettingsModel {
  final HomeSettingsModel? home;
  final BankSettingsModel? bank;
  final ContactSettingsModel? contact;
  final FirebaseSettingsModel? firebase;
  final PolicyModel? privacyPolicy;
  final TermsModel? termsOfService;
  final ShippingPolicyModel? shippingPolicy;
  final ReturnsPolicyModel? returnsPolicy;
  final dynamic payments;

  SettingsModel({
    this.home,
    this.bank,
    this.contact,
    this.firebase,
    this.privacyPolicy,
    this.termsOfService,
    this.shippingPolicy,
    this.returnsPolicy,
    this.payments,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      home: json['home'] != null
          ? HomeSettingsModel.fromJson(Map<String, dynamic>.from(json['home']))
          : null,
      bank: json['bank'] != null
          ? BankSettingsModel.fromJson(Map<String, dynamic>.from(json['bank']))
          : null,
      contact: json['contact'] != null
          ? ContactSettingsModel.fromJson(
          Map<String, dynamic>.from(json['contact']))
          : null,
      firebase: json['firebase'] != null
          ? FirebaseSettingsModel.fromJson(
          Map<String, dynamic>.from(json['firebase']))
          : null,
      privacyPolicy: json['privacyPolicy'] != null
          ? PolicyModel.fromJson(
          Map<String, dynamic>.from(json['privacyPolicy']))
          : null,
      termsOfService: json['termsOfService'] != null
          ? TermsModel.fromJson(
          Map<String, dynamic>.from(json['termsOfService']))
          : null,
      shippingPolicy: json['shippingPolicy'] != null
          ? ShippingPolicyModel.fromJson(
          Map<String, dynamic>.from(json['shippingPolicy']))
          : null,

      returnsPolicy: json['returnsPolicy'] != null
          ? ReturnsPolicyModel.fromJson(
          Map<String, dynamic>.from(json['returnsPolicy']))
          : null,
      payments: json['payments'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'home': home?.toJson(),
      'bank': bank?.toJson(),
      'contact': contact?.toJson(),
      'firebase': firebase?.toJson(),
      'privacyPolicy': privacyPolicy?.toJson(),
      'termsOfService': termsOfService?.toJson(),
      'shippingPolicy': shippingPolicy?.toJson(),
      'returnsPolicy': returnsPolicy?.toJson(),
      'payments': payments,
    };
  }
}