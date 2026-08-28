class RegisterRequestModel {
  final String name;
  final String email;
  final String mobile;
  final String password;

  RegisterRequestModel({
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "mobile": mobile,
      "password": password,
    };
  }
}