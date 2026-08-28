class NotificationPreferences {
  final bool isNotificationEnabled;
  final bool reviews;
  final bool promotions;
  final bool orderUpdates;
  final bool productAlerts;
  final bool paymentUpdates;
  final bool deliveryUpdates;

  NotificationPreferences({
    required this.isNotificationEnabled,
    required this.reviews,
    required this.promotions,
    required this.orderUpdates,
    required this.productAlerts,
    required this.paymentUpdates,
    required this.deliveryUpdates,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final prefs = data['preferences'] ?? {};

    return NotificationPreferences(
      isNotificationEnabled: data['isNotificationEnabled'] ?? false,
      reviews: prefs['reviews'] ?? false,
      promotions: prefs['promotions'] ?? false,
      orderUpdates: prefs['orderUpdates'] ?? false,
      productAlerts: prefs['productAlerts'] ?? false,
      paymentUpdates: prefs['paymentUpdates'] ?? false,
      deliveryUpdates: prefs['deliveryUpdates'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "isNotificationEnabled": isNotificationEnabled,
      "preferences": {
        "reviews": reviews,
        "promotions": promotions,
        "orderUpdates": orderUpdates,
        "productAlerts": productAlerts,
        "paymentUpdates": paymentUpdates,
        "deliveryUpdates": deliveryUpdates,
      }
    };
  }

  NotificationPreferences copyWith({
    bool? isNotificationEnabled,
    bool? reviews,
    bool? promotions,
    bool? orderUpdates,
    bool? productAlerts,
    bool? paymentUpdates,
    bool? deliveryUpdates,
  }) {
    return NotificationPreferences(
      isNotificationEnabled:
      isNotificationEnabled ?? this.isNotificationEnabled,
      reviews: reviews ?? this.reviews,
      promotions: promotions ?? this.promotions,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      productAlerts: productAlerts ?? this.productAlerts,
      paymentUpdates: paymentUpdates ?? this.paymentUpdates,
      deliveryUpdates: deliveryUpdates ?? this.deliveryUpdates,
    );
  }
}