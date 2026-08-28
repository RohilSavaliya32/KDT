class LoginResponse {
  final bool success;
  final String message;
  final LoginData data;
  final Map<String, dynamic> meta;

  LoginResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: LoginData.fromJson(json['data'] ?? {}),
      meta: Map<String, dynamic>.from(json['meta'] ?? {}),
    );
  }
}

class LoginData {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String role;
  final String accessToken;

  LoginData({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.role,
    required this.accessToken,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      role: json['role'] ?? '',
      accessToken: json['accessToken'] ?? '',
    );
  }
}