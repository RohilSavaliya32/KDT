class CouponModel {
  final String id;
  final String code;
  final int discountPercent;

  CouponModel({
    required this.id,
    required this.code,
    required this.discountPercent,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: '${json['id'] ?? ''}',
      code: '${json['code'] ?? ''}',
      discountPercent: (json['discountPercent'] as num?)?.toInt() ?? 0,
    );
  }

  String get label => '$code (${discountPercent}% Off)';
}