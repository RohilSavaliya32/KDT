import '../../Register/register_request_model.dart';
import '../../Register/register_response_model.dart';
import '../auth_api_service.dart';

class AuthRepository {
  final AuthApiService apiService;

  AuthRepository(this.apiService);

  Future<bool> emailExists(String email) async {
    return await apiService.checkEmailExists(email);
  }

  Future<bool> mobileExists(String mobile) async {
    return await apiService.checkMobileExists(mobile);
  }

  Future<RegisterResponseModel> registerUser(
      RegisterRequestModel model,
      ) async {
    return await apiService.register(
      name: model.name,
      email: model.email,
      mobile: model.mobile,
      password: model.password,
    );
  }
}