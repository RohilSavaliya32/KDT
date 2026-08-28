import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../login/auth_api_service.dart';

class ProfileController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  final name = ''.obs;
  final email = ''.obs;
  final mobile = ''.obs;
  final profileImage = ''.obs; // 🆕 added
  final isEditProfileOpening = false.obs;

  @override
  void onInit() {
    super.onInit();

    ever<bool>(authController.authReady, (ready) {
      if (ready == true) {
        loadUserData();
      }
    });

    ever<bool>(authController.isLoggedIn, (loggedIn) {
      if (authController.authReady.value) {
        loadUserData();
      }
    });

    if (authController.authReady.value) {
      loadUserData();
    }
  }

  Future<void> loadUserData() async {
    if (!authController.authReady.value) return;

    if (!authController.isLoggedIn.value) {
      name.value = 'Guest User';
      email.value = '';
      mobile.value = '';
      profileImage.value = ''; // 🆕

      return;
    }

    name.value = authController.userName ?? 'Guest User';
    email.value = authController.userEmail ?? '';
    mobile.value = authController.userMobile ?? '';
    profileImage.value = authController.userData?['profileImage']?.toString() ?? ''; // 🆕

    await refreshProfile();
  }

  final ordersCount = 24.obs;
  final wishlistCount = 12.obs;
  final points = 1840.obs;

  void navigateTo(String route) {
    AppNavigator.to(route);
  }

  void openHelpCenter() => AppNavigator.to('/help-center');

  final isLoggingOut = false.obs;

  Future<void> logout() async {
    if (isLoggingOut.value) return;

    try {
      isLoggingOut.value = true;

      final authApi = AuthApiService();
      final success = await authApi.logout();

      if (success) {
        await Get.find<AuthController>().logout();

        Get.snackbar(
          'Success',
          'Logged out successfully',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
      );
    } finally {
      isLoggingOut.value = false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      if (!authController.isLoggedIn.value) return;

      final authApi = AuthApiService();
      final response = await authApi.getProfile();

      final data = response['data'];

      name.value = data['name']?.toString() ?? '';
      email.value = data['email']?.toString() ?? '';
      mobile.value = data['mobile']?.toString() ?? '';
      profileImage.value = data['profileImage']?.toString() ?? ''; // 🆕
      final profileBox = authController.box;

      // Store profile verification/auth information
      await profileBox.write(
        'isMobileVerified',
        data['isMobileVerified'] ?? false,
      );

      await profileBox.write(
        'isEmailVerified',
        data['isEmailVerified'] ?? false,
      );

      await profileBox.write(
        'authType',
        data['authType']?.toString() ?? '',
      );

      // Store verified mobile number and country code
      if (data['isMobileVerified'] == true &&
          data['mobile'] != null &&
          data['mobile'].toString().trim().isNotEmpty) {
        final verifiedMobile = data['mobile'].toString().trim();

        await profileBox.write(
          'verifiedMobile',
          verifiedMobile,
        );

        // API currently returns full mobile number.
        // Extract country code from the mobile number.
        if (verifiedMobile.startsWith('+91')) {
          await profileBox.write(
            'verifiedCountryCode',
            '+91',
          );
        }
      } else {
        await profileBox.remove('verifiedMobile');
        await profileBox.remove('verifiedCountryCode');
      }
      print("===================Profile Data==================");
      print("Updated Name => ${name.value}");
      print("Updated Email => ${email.value}");
      print("Updated Mobile => ${mobile.value}");
      print("Profile Image => ${profileImage.value}");
      print("Mobile Verified => ${data['isMobileVerified']}");
      print("Email Verified => ${data['isEmailVerified']}");
      print("Auth Type => ${data['authType']}");
      print("Verified Mobile => ${profileBox.read('verifiedMobile')}");
      print(
        "Verified Country Code => "
            "${profileBox.read('verifiedCountryCode')}",
      );
      print("===================================================");

      update();
    } catch (e) {
      print("PROFILE REFRESH ERROR => $e");
    }
  }
}
