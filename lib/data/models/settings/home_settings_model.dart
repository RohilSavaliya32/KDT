class HomeSettingsModel {
  final String? gstNo;
  final String? regNo;
  final String? phone1;
  final String? phone2;
  final String? address1;
  final String? address2;
  final String? logoText;
  final String? heroTitle;
  final String? footerLogo;
  final String? headerLogo;
  final String? logoTextKo;
  final String? logoTextZh;
  final String? bannerImage;
  final String? expertPhone;
  final String? footerEmail;
  final String? heroTitleKo;
  final String? heroTitleZh;
  final List<String> bannerImages;
  final String? heroSubtitle;
  final String? socialWechat;
  final String? heroButtonText;
  final String? heroSubtitleKo;
  final String? heroSubtitleZh;
  final String? socialFacebook;
  final String? socialInstagram;
  final String? heroButtonTextKo;
  final String? heroButtonTextZh;
  final String? footerDescription;
  final String? footerDescriptionKo;
  final String? footerDescriptionZh;
  final String? promoBannerSubtitle;
  final String? collectionsLeftImage;
  final String? collectionsTopRightText;
  final String? collectionsTopRightImage;
  final String? collectionsBottomRightText;
  final String? collectionsBottomRightImage;
  final String? promoBannerImage;
  final String? promoBannerTitle;


  HomeSettingsModel({
    this.gstNo,
    this.regNo,
    this.phone1,
    this.phone2,
    this.address1,
    this.address2,
    this.logoText,
    this.heroTitle,
    this.footerLogo,
    this.headerLogo,
    this.logoTextKo,
    this.logoTextZh,
    this.bannerImage,
    this.expertPhone,
    this.footerEmail,
    this.heroTitleKo,
    this.heroTitleZh,
    this.bannerImages = const [],
    this.heroSubtitle,
    this.socialWechat,
    this.heroButtonText,
    this.heroSubtitleKo,
    this.heroSubtitleZh,
    this.socialFacebook,
    this.socialInstagram,
    this.heroButtonTextKo,
    this.heroButtonTextZh,
    this.footerDescription,
    this.footerDescriptionKo,
    this.footerDescriptionZh,
    this.promoBannerSubtitle,
    this.collectionsLeftImage,
    this.collectionsTopRightText,
    this.collectionsTopRightImage,
    this.collectionsBottomRightText,
    this.collectionsBottomRightImage,
    this.promoBannerImage,
    this.promoBannerTitle,
  });

  factory HomeSettingsModel.fromJson(Map<String, dynamic> json) {
    return HomeSettingsModel(
      gstNo: json['gstNo'],
      regNo: json['regNo'],
      phone1: json['phone1'],
      phone2: json['phone2'],
      address1: json['address1'],
      address2: json['address2'],
      logoText: json['logoText'],
      heroTitle: json['heroTitle'],
      footerLogo: json['footerLogo'],
      headerLogo: json['headerLogo'],
      logoTextKo: json['logoTextKo'],
      logoTextZh: json['logoTextZh'],
      bannerImage: json['bannerImage'],
      expertPhone: json['expertPhone'],
      footerEmail: json['footerEmail'],
      heroTitleKo: json['heroTitleKo'],
      heroTitleZh: json['heroTitleZh'],
      bannerImages: (json['bannerImages'] as List<dynamic>?)
          ?.map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList() ??
          [],
      heroSubtitle: json['heroSubtitle'],
      socialWechat: json['socialWechat'],
      heroButtonText: json['heroButtonText'],
      heroSubtitleKo: json['heroSubtitleKo'],
      heroSubtitleZh: json['heroSubtitleZh'],
      socialFacebook: json['socialFacebook'],
      socialInstagram: json['socialInstagram'],
      heroButtonTextKo: json['heroButtonTextKo'],
      heroButtonTextZh: json['heroButtonTextZh'],
      footerDescription: json['footerDescription'],
      footerDescriptionKo: json['footerDescriptionKo'],
      footerDescriptionZh: json['footerDescriptionZh'],
      promoBannerSubtitle: json['promoBannerSubtitle'],
      collectionsLeftImage: json['collectionsLeftImage'],
      collectionsTopRightText: json['collectionsTopRightText'],
      collectionsTopRightImage: json['collectionsTopRightImage'],
      collectionsBottomRightText: json['collectionsBottomRightText'],
      collectionsBottomRightImage: json['collectionsBottomRightImage'],
      promoBannerImage: json['promoBannerImage'],
      promoBannerTitle: json['promoBannerTitle'],


    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gstNo': gstNo,
      'regNo': regNo,
      'phone1': phone1,
      'phone2': phone2,
      'address1': address1,
      'address2': address2,
      'logoText': logoText,
      'heroTitle': heroTitle,
      'footerLogo': footerLogo,
      'headerLogo': headerLogo,
      'logoTextKo': logoTextKo,
      'logoTextZh': logoTextZh,
      'bannerImage': bannerImage,
      'expertPhone': expertPhone,
      'footerEmail': footerEmail,
      'heroTitleKo': heroTitleKo,
      'heroTitleZh': heroTitleZh,
      'bannerImages': bannerImages,
      'heroSubtitle': heroSubtitle,
      'socialWechat': socialWechat,
      'heroButtonText': heroButtonText,
      'heroSubtitleKo': heroSubtitleKo,
      'heroSubtitleZh': heroSubtitleZh,
      'socialFacebook': socialFacebook,
      'socialInstagram': socialInstagram,
      'heroButtonTextKo': heroButtonTextKo,
      'heroButtonTextZh': heroButtonTextZh,
      'footerDescription': footerDescription,
      'footerDescriptionKo': footerDescriptionKo,
      'footerDescriptionZh': footerDescriptionZh,
      'promoBannerSubtitle' : promoBannerSubtitle,
      'collectionsLeftImage': collectionsLeftImage,
      'collectionsTopRightText': collectionsTopRightText,
      'collectionsTopRightImage': collectionsTopRightImage,
      'collectionsBottomRightText': collectionsBottomRightText,
      'collectionsBottomRightImage': collectionsBottomRightImage,
      'promoBannerImage': promoBannerImage,
      'promoBannerTitle': promoBannerTitle,
    };
  }
}