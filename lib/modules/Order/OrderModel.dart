class OrderModel {
  final String id;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final ShippingAddressModel? shippingAddress;
  final List<OrderItemModel> items;

  final num? total;
  final num? subtotalUsd;
  final num? displaySubtotal;
  final num? displayTotal;

  final String? status;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? paymentImage;
  final List<TrackingLogModel> trackingLogs;

  final String? cancellationReason;
  final String? cancelledAt;
  final String? cancelledBy;

  final String? createdAt;
  final String? updatedAt;

  OrderModel({
    required this.id,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.shippingAddress,
    required this.items,
    this.total,
    this.subtotalUsd,
    this.displaySubtotal,
    this.displayTotal,
    this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.paymentImage,
    required this.trackingLogs,
    this.cancellationReason,
    this.cancelledAt,
    this.cancelledBy,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      customerName: json['customerName']?.toString(),
      customerEmail: json['customerEmail']?.toString(),
      customerPhone: json['customerPhone']?.toString(),
      shippingAddress: json['shippingAddress'] is Map
          ? ShippingAddressModel.fromJson(
        Map<String, dynamic>.from(json['shippingAddress']),
      )
          : null,
      items: (json['items'] as List? ?? [])
          .map(
            (e) => OrderItemModel.fromJson(
          Map<String, dynamic>.from(e as Map),
        ),
      )
          .toList(),
      total: _num(json['total']),
      subtotalUsd: _num(json['subtotalUsd']),
      displaySubtotal: _num(json['displaySubtotal']),
      displayTotal: _num(json['displayTotal']),
      status: json['status']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      paymentStatus: json['paymentStatus']?.toString(),
      paymentImage: json['paymentImage']?.toString(),
      trackingLogs: (json['trackingLogs'] as List? ?? [])
          .map(
            (e) => TrackingLogModel.fromJson(
          Map<String, dynamic>.from(e as Map),
        ),
      )
          .toList(),
      cancellationReason: json['cancellationReason']?.toString(),
      cancelledAt: json['cancelledAt']?.toString(),
      cancelledBy: json['cancelledBy']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  OrderModel copyWith({
    String? id,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    ShippingAddressModel? shippingAddress,
    List<OrderItemModel>? items,
    num? total,
    num? subtotalUsd,
    num? displaySubtotal,
    num? displayTotal,
    String? status,
    String? paymentMethod,
    String? paymentStatus,
    String? paymentImage,
    List<TrackingLogModel>? trackingLogs,
    String? cancellationReason,
    String? cancelledAt,
    String? cancelledBy,
    String? createdAt,
    String? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      items: items ?? this.items,
      total: total ?? this.total,
      subtotalUsd: subtotalUsd ?? this.subtotalUsd,
      displaySubtotal: displaySubtotal ?? this.displaySubtotal,
      displayTotal: displayTotal ?? this.displayTotal,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentImage: paymentImage ?? this.paymentImage,
      trackingLogs: trackingLogs ?? this.trackingLogs,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static num? _num(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '');
  }
}

class ShippingAddressModel {
  final String? city;
  final String? state;
  final String? street;
  final String? country;
  final String? zipCode;

  ShippingAddressModel({
    this.city,
    this.state,
    this.street,
    this.country,
    this.zipCode,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      street: json['street']?.toString(),
      country: json['country']?.toString(),
      zipCode: json['zipCode']?.toString(),
    );
  }

  String get fullAddress {
    final parts = <String>[
      if ((street ?? '').isNotEmpty) street!,
      if ((city ?? '').isNotEmpty) city!,
      if ((state ?? '').isNotEmpty) state!,
      if ((country ?? '').isNotEmpty) country!,
      if ((zipCode ?? '').isNotEmpty) zipCode!,
    ];
    return parts.join(', ');
  }
}

class OrderItemModel {
  final String id;
  final String? sku;
  final String? slug;
  final num? carat;
  final String? image;
  final num? price;
  final String? shape;
  final String? title;
  final int quantity;
  final num? originalPrice;
  final num? displayPrice;
  final num? displayOriginalPrice;

  OrderItemModel({
    required this.id,
    this.sku,
    this.slug,
    this.carat,
    this.image,
    this.price,
    this.shape,
    this.title,
    required this.quantity,
    this.originalPrice,
    this.displayPrice,
    this.displayOriginalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id']?.toString() ?? '',
      sku: json['sku']?.toString(),
      slug: json['slug']?.toString(),
      carat: _num(json['carat']),
      image: json['image']?.toString(),
      price: _num(json['price']),
      shape: json['shape']?.toString(),
      title: json['title']?.toString(),
      quantity: _int(json['quantity'], fallback: 1),
      originalPrice: _num(json['originalPrice']),
      displayPrice: _num(json['displayPrice']),
      displayOriginalPrice: _num(json['displayOriginalPrice']),
    );
  }

  static num? _num(dynamic value) {
    if (value is num) return value;
    return num.tryParse(value?.toString() ?? '');
  }

  static int _int(dynamic value, {int fallback = 1}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class TrackingLogModel {
  final String? date;
  final String? status;
  final String? message;

  TrackingLogModel({
    this.date,
    this.status,
    this.message,
  });

  factory TrackingLogModel.fromJson(Map<String, dynamic> json) {
    return TrackingLogModel(
      date: json['date']?.toString(),
      status: json['status']?.toString(),
      message: json['message']?.toString(),
    );
  }
}