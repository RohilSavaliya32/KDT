class ContactResponseModel {
  final bool success;
  final String message;

  ContactResponseModel({
    required this.success,
    required this.message,
  });

  factory ContactResponseModel.fromJson(Map<String, dynamic> json) {
    return ContactResponseModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
    );
  }
}