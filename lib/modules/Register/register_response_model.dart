class RegisterResponseModel {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? error;

  RegisterResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
      data: json["data"] is Map<String, dynamic> ? json["data"] : null,
      error: json["error"] is Map<String, dynamic> ? json["error"] : null,
    );
  }
}