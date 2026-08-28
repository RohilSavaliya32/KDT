class SizeGuideItem {
  final double carat;
  final int order;
  final String mmSize;

  SizeGuideItem({
    required this.carat,
    required this.order,
    required this.mmSize,
  });

  factory SizeGuideItem.fromJson(Map<String, dynamic> json) {
    return SizeGuideItem(
      carat: (json["carat"] as num).toDouble(),
      order: json["order"] ?? 0,
      mmSize: json["mmSize"] ?? "",
    );
  }
}

class SizeGuideResponse {
  final Map<String, List<SizeGuideItem>> shapes;

  SizeGuideResponse({
    required this.shapes,
  });

  factory SizeGuideResponse.fromJson(Map<String, dynamic> json) {
    final data = json["data"] as Map<String, dynamic>;

    return SizeGuideResponse(
      shapes: data.map(
            (key, value) => MapEntry(
          key,
          (value as List)
              .map((e) => SizeGuideItem.fromJson(e))
              .toList(),
        ),
      ),
    );
  }
}