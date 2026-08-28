  import 'dart:convert';
  import 'package:flutter/foundation.dart';

  class DiamondModel {
    final String title;
    final String id;
    final String sku;
    final String slug;
    final String seoTitle;
    final String seoDescription;
    final String? seoKeywords;
    final String shape;
    final double price;
    final double originalPrice;
    final int discountPercent;
    final double carat;
    final String color;
    final String clarity;
    final String cut;
    final String image;
    final List<String> images;
    final String certification;
    final String certNumber;
    final String certificateFile;
    final bool isLabGrown;
    final Measurements measurements;
    final double depthPercent;
    final double tablePercent;
    final String polish;
    final String symmetry;
    final String fluorescence;
    final int quantity;
    final String stockStatus;
    final double averageRating;
    final int ratingCount;
    final int reviewCount;
    final int buyCount;
    final DateTime createdAt;
    final DateTime updatedAt;
    final LocalizedContent localizedContent;

    DiamondModel({
      required this.title,
      required this.id,
      required this.sku,
      required this.slug,
      required this.seoTitle,
      required this.seoDescription,
      this.seoKeywords,
      required this.shape,
      required this.price,
      required this.originalPrice,
      required this.discountPercent,
      required this.carat,
      required this.color,
      required this.clarity,
      required this.cut,
      required this.image,
      required this.images,
      required this.certification,
      required this.certNumber,
      required this.certificateFile,
      required this.isLabGrown,
      required this.measurements,
      required this.depthPercent,
      required this.tablePercent,
      required this.polish,
      required this.symmetry,
      required this.fluorescence,
      required this.quantity,
      required this.stockStatus,
      required this.averageRating,
      required this.ratingCount,
      required this.reviewCount,
      required this.buyCount,
      required this.createdAt,
      required this.updatedAt,
      required this.localizedContent,
    });

    factory DiamondModel.fromJson(Map<String, dynamic> json) {
      debugPrint('================ DIAMOND API JSON ================');
      debugPrint(const JsonEncoder.withIndent('  ').convert(json));
      debugPrint('==================================================');

      final model = DiamondModel(
        title: json['title']?.toString() ?? '',
        id: json['id']?.toString() ?? '',
        sku: json['sku']?.toString() ?? '',
        slug: json['slug']?.toString() ?? '',
        seoTitle: json['seoTitle']?.toString() ?? '',
        seoDescription: json['seoDescription']?.toString() ?? '',
        seoKeywords: json['seoKeywords']?.toString(),
        shape: json['shape']?.toString() ?? '',
        price: _toDouble(json['price']),
        originalPrice: _toDouble(json['originalPrice']),
        discountPercent: _toInt(json['discountPercent']),
        carat: _toDouble(json['carat']),
        color: json['color']?.toString() ?? '',
        clarity: json['clarity']?.toString() ?? '',
        cut: json['cut']?.toString() ?? '',
        image: json['image']?.toString() ?? '',
        images: (json['images'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
            <String>[],
        certification: json['certification']?.toString() ?? '',
        certNumber: json['certNumber']?.toString() ?? '',
        certificateFile: json['certificateFile']?.toString() ?? '',
        isLabGrown: json['isLabGrown'] as bool? ?? false,
        measurements: Measurements.fromJson(
          (json['measurements'] as Map<String, dynamic>?) ?? {},
        ),
        depthPercent: _toDouble(json['depthPercent']),
        tablePercent: _toDouble(json['tablePercent']),
        polish: json['polish']?.toString() ?? '',
        symmetry: json['symmetry']?.toString() ?? '',
        fluorescence: json['fluorescence']?.toString() ?? '',
        quantity: _toInt(json['quantity']),
        stockStatus: json['stockStatus']?.toString() ?? 'Out of Stock',
        averageRating: _toDouble(json['averageRating']),
        ratingCount: _toInt(json['ratingCount']),
        reviewCount: _toInt(json['reviewCount']),
        buyCount: _toInt(json['buyCount']),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
            DateTime.now(),
        localizedContent: LocalizedContent.fromJson(
          (json['localizedContent'] as Map<String, dynamic>?) ?? {},
        ),
      );

      debugPrint('=============== PARSED DIAMOND ===============');
      debugPrint('ID: ${model.id}');
      debugPrint("title : ${model.title}");
      debugPrint('SKU: ${model.sku}');
      debugPrint('SLUG: ${model.slug}');
      debugPrint('SHAPE: ${model.shape}');
      debugPrint('CARAT: ${model.carat}');
      debugPrint('PRICE: ${model.price}');
      debugPrint('ORIGINAL PRICE: ${model.originalPrice}');
      debugPrint('DISCOUNT: ${model.discountPercent}');
      debugPrint('COLOR: ${model.color}');
      debugPrint('CLARITY: ${model.clarity}');
      debugPrint('CUT: ${model.cut}');
      debugPrint('IMAGE: ${model.image}');
      debugPrint('IMAGES COUNT: ${model.images.length}');
      debugPrint('CERTIFICATION: ${model.certification}');
      debugPrint('CERT NUMBER: ${model.certNumber}');
      debugPrint('IS LAB GROWN: ${model.isLabGrown}');
      debugPrint(
        'MEASUREMENTS => depth: ${model.measurements.depth}, width: ${model.measurements.width}, length: ${model.measurements.length}',
      );
      debugPrint('DEPTH %: ${model.depthPercent}');
      debugPrint('TABLE %: ${model.tablePercent}');
      debugPrint('POLISH: ${model.polish}');
      debugPrint('SYMMETRY: ${model.symmetry}');
      debugPrint('FLUORESCENCE: ${model.fluorescence}');
      debugPrint('QUANTITY: ${model.quantity}');
      debugPrint('QUANTITY: ${model.quantity}');
      debugPrint('AVG RATING: ${model.averageRating}');
      debugPrint('RATING COUNT: ${model.ratingCount}');
      debugPrint('REVIEW COUNT: ${model.reviewCount}');
      debugPrint('BUY COUNT: ${model.buyCount}');
      debugPrint('CREATED AT: ${model.createdAt}');
      debugPrint('UPDATED AT: ${model.updatedAt}');
      debugPrint('================================================');

      return model;
    }

    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'sku': sku,
        'slug': slug,
        'title': title,
        'seoTitle': seoTitle,
        'seoDescription': seoDescription,
        'seoKeywords': seoKeywords,
        'shape': shape,
        'price': price,
        'originalPrice': originalPrice,
        'discountPercent': discountPercent,
        'carat': carat,
        'color': color,
        'clarity': clarity,
        'cut': cut,
        'image': image,
        'images': images,
        'certification': certification,
        'certNumber': certNumber,
        'certificateFile': certificateFile,
        'isLabGrown': isLabGrown,
        'measurements': measurements.toJson(),
        'depthPercent': depthPercent,
        'tablePercent': tablePercent,
        'polish': polish,
        'symmetry': symmetry,
        'fluorescence': fluorescence,
        'quantity': quantity,
        'stockStatus': stockStatus,
        'averageRating': averageRating,
        'ratingCount': ratingCount,
        'reviewCount': reviewCount,
        'buyCount': buyCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'localizedContent': localizedContent.toJson(),
      };
    }

    static double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    static int _toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }
  }

  class Measurements {
    final double depth;
    final double width;
    final double length;

    Measurements({
      required this.depth,
      required this.width,
      required this.length,
    });

    factory Measurements.fromJson(Map<String, dynamic> json) {
      debugPrint('---------------- MEASUREMENTS JSON ----------------');
      debugPrint(const JsonEncoder.withIndent('  ').convert(json));
      debugPrint('---------------------------------------------------');

      final model = Measurements(
        depth: DiamondModel._toDouble(json['depth']),
        width: DiamondModel._toDouble(json['width']),
        length: DiamondModel._toDouble(json['length']),
      );

      debugPrint(
        'MEASUREMENTS PARSED => depth: ${model.depth}, width: ${model.width}, length: ${model.length}',
      );

      return model;
    }

    Map<String, dynamic> toJson() {
      return {
        'depth': depth,
        'width': width,
        'length': length,
      };
    }
  }

  class LocalizedContent {
    final String? name;
    final String? description;
    final String? shapeName;
    final String? cutDetails;
    final String? certificationInfo;
    final String? specifications;
    final String? marketingContent;
    final String? seoTitle;
    final String? seoDescription;
    final String? seoKeywords;

    LocalizedContent({
      this.name,
      this.description,
      this.shapeName,
      this.cutDetails,
      this.certificationInfo,
      this.specifications,
      this.marketingContent,
      this.seoTitle,
      this.seoDescription,
      this.seoKeywords,
    });

    factory LocalizedContent.fromJson(Map<String, dynamic> json) {
      debugPrint('------------- LOCALIZED CONTENT JSON --------------');
      debugPrint(const JsonEncoder.withIndent('  ').convert(json));
      debugPrint('---------------------------------------------------');

      final model = LocalizedContent(
        name: json['name']?.toString(),
        description: json['description']?.toString(),
        shapeName: json['shapeName']?.toString(),
        cutDetails: json['cutDetails']?.toString(),
        certificationInfo: json['certificationInfo']?.toString(),
        specifications: json['specifications']?.toString(),
        marketingContent: json['marketingContent']?.toString(),
        seoTitle: json['seoTitle']?.toString(),
        seoDescription: json['seoDescription']?.toString(),
        seoKeywords: json['seoKeywords']?.toString(),
      );

      debugPrint('LOCALIZED CONTENT PARSED => name: ${model.name}');
      debugPrint('LOCALIZED CONTENT PARSED => description: ${model.description}');
      debugPrint('LOCALIZED CONTENT PARSED => shapeName: ${model.shapeName}');

      return model;
    }

    Map<String, dynamic> toJson() {
      return {
        'name': name,
        'description': description,
        'shapeName': shapeName,
        'cutDetails': cutDetails,
        'certificationInfo': certificationInfo,
        'specifications': specifications,
        'marketingContent': marketingContent,
        'seoTitle': seoTitle,
        'seoDescription': seoDescription,
        'seoKeywords': seoKeywords,
      };
    }
  }