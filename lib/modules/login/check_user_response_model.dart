class CheckUserResponse {
  final bool success;
  final String message;
  final CheckUserData data;
  final CheckUserMeta meta;

  CheckUserResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory CheckUserResponse.fromJson(Map<String, dynamic> json) {
    return CheckUserResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: CheckUserData.fromJson(json['data'] ?? {}),
      meta: CheckUserMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class CheckUserData {
  final bool exists;

  CheckUserData({
    required this.exists,
  });

  factory CheckUserData.fromJson(Map<String, dynamic> json) {
    return CheckUserData(
      exists: json['exists'] ?? false,
    );
  }
}

class CheckUserMeta {
  final String email;
  final String mobile;
  final String authType;

  CheckUserMeta({
    required this.email,
    required this.mobile,
    required this.authType,
  });

  factory CheckUserMeta.fromJson(Map<String, dynamic> json) {
    return CheckUserMeta(
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      authType: json['authType'] ?? '',
    );
  }
}