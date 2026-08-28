import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/storage/secure_storage.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../login/auth_api_service.dart';
import 'package:kdt/modules/profile/controllers/profile_controller.dart';

class EditProfileController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final isMobileVerified = false.obs;
  final RxBool isInitialLoading = true.obs;
  final isVerificationRequired = false.obs;

  final selectedCountryCode = '+91'.obs;
  final selectedCountryISOCode = 'IN'.obs;

  String storedVerifiedMobile = '';
  String storedVerifiedCountryCode = '';

  final isLoading = false.obs;
  final loginType = ''.obs;
  bool get isEmailEditable => loginType.value == "mobile";
  bool get isPhoneEditable => loginType.value == "email" || loginType.value == "google";
  final Rx<File?> pickedImageFile = Rx<File?>(null);
  final RxBool isUploadingImage = false.obs;
  final imageError = RxnString();
  final firstNameError = RxnString();
  final lastNameError = RxnString();
  final ImagePicker _picker = ImagePicker();

  static const int maxImageSizeBytes = 12 * 1024 * 1024; // 12 MB
  static const List<String> allowedExtensions = ['.png', '.jpg', '.jpeg'];

  @override
  @override
  void onInit() {
    super.onInit();

    loadInitialData();
  }
  Future<void> loadInitialData() async {
    try {
      isInitialLoading.value = true;

      // Login type load
      await loadLoginType();

      final profileController = Get.find<ProfileController>();

      // Name
      final fullName = profileController.name.value.trim();
      final parts = fullName.split(' ');

      firstNameController.text =
      parts.isNotEmpty ? parts.first : '';

      lastNameController.text =
      parts.length > 1
          ? parts.sublist(1).join(' ')
          : '';

      // Email
      emailController.text =
          profileController.email.value;

      // Mobile
      final mobile = profileController.mobile.value;

      if (mobile.startsWith('+')) {
        if (mobile.startsWith('+91')) {
          selectedCountryCode.value = '+91';
          selectedCountryISOCode.value = 'IN';
          mobileController.text = mobile.substring(3);
        } else if (mobile.startsWith('+82')) {
          selectedCountryCode.value = '+82';
          selectedCountryISOCode.value = 'KR';
          mobileController.text = mobile.substring(3);
        } else {
          mobileController.text = mobile;
        }
      } else {
        mobileController.text = mobile;
      }

      print("========== EDIT PROFILE INIT ==========");
      print("Name => ${profileController.name.value}");
      print("Email => ${profileController.email.value}");
      print("Mobile => ${profileController.mobile.value}");

      // Verification data
      await loadMobileVerificationData();

      // Mobile listener
      mobileController.addListener(
        checkMobileVerificationStatus,
      );
    } catch (e, s) {
      print("========== EDIT PROFILE INITIAL LOAD ERROR ==========");
      print(e);
      print(s);
    } finally {
      // VERY IMPORTANT
      isInitialLoading.value = false;
    }
  }

  Future<void> loadLoginType() async {
    loginType.value = await SecureStorage.getLoginType() ?? "";
  }

  Future<void> pickProfileImage() async {
    try {
      imageError.value = null;
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (picked == null) return;

      final file = File(picked.path);
      final fileName = picked.path.toLowerCase();

      final hasValidExtension =
      allowedExtensions.any((ext) => fileName.endsWith(ext));

      if (!hasValidExtension) {
        imageError.value = "Only PNG, JPG and JPEG images are allowed.";
        return;
      }

      final fileSizeBytes = await file.length();
      if (fileSizeBytes > maxImageSizeBytes) {
        imageError.value ="Image size must be less than 12 MB.";
        return;
      }

      pickedImageFile.value = file;
      imageError.value = null;
    } catch (e) {
      print("PICK IMAGE ERROR => $e");
    }
  }

  void cancelImageSelection() {
    pickedImageFile.value = null;
    imageError.value = null;
  }

  Future<void> uploadProfileImage() async {
    if (pickedImageFile.value == null) return;
    await _uploadImage(pickedImageFile.value!);
    pickedImageFile.value = null;
  }

  Future<void> removeProfileImage() async {
    try {
      isUploadingImage.value = true;
      final profileController = Get.find<ProfileController>();
      final authController = Get.find<AuthController>();

      profileController.profileImage.value = '';

      final updatedUser = Map<String, dynamic>.from(
        authController.userData ?? {},
      );
      updatedUser['profileImage'] = '';
      await authController.box.write('user_data', jsonEncode(updatedUser));

      pickedImageFile.value = null;
      imageError.value = null;

      Get.snackbar("Success", "Profile image removed");
    } catch (e) {
      print("REMOVE IMAGE ERROR => $e");
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> _uploadImage(File file) async {
    try {
      isUploadingImage.value = true;

      final authApi = AuthApiService();
      final response = await authApi.uploadProfileImage(file);

      final success = response['success'] == true;
      final imageUrl = response['data']?['profileImage']?.toString();

      if (success && imageUrl != null && imageUrl.isNotEmpty) {
        final profileController = Get.find<ProfileController>();
        final authController = Get.find<AuthController>();

        profileController.profileImage.value = imageUrl;

        final updatedUser = Map<String, dynamic>.from(
          authController.userData ?? {},
        );
        updatedUser['profileImage'] = imageUrl;
        await authController.box.write('user_data', jsonEncode(updatedUser));

        Get.snackbar("Success", "Profile photo updated");
      } else {
        throw Exception(response['message']?.toString() ?? 'Upload failed');
      }
    } catch (e) {
      print("UPLOAD IMAGE ERROR => $e");
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> saveProfile() async {
    try {
      isLoading.value = true;

      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();
      firstNameError.value = null;
      lastNameError.value = null;
      final email = emailController.text.trim();
      final mobile = mobileController.text.trim();

      bool hasError = false;

      if (firstName.isEmpty) {
        firstNameError.value = "First Name is required";
        hasError = true;
      }

      if (lastName.isEmpty) {
        lastNameError.value = "Last Name is required";
        hasError = true;
      }

      if (hasError) {
        return;
      }

      final authApi = AuthApiService();

      checkMobileVerificationStatus();
      if (isVerificationRequired.value) {
        Get.snackbar(
          'Verification Required',
          'Please verify your mobile number before saving.',
        );
        return;
      }

      final fullMobile = "${selectedCountryCode.value}$mobile";

      final success = await authApi.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        mobile: fullMobile,
      );

      if (success) {
        final authController = Get.find<AuthController>();
        final profileController = Get.find<ProfileController>();

        final fullName = '$firstName $lastName'.trim();

        final updatedUser = {
          'name': fullName,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'mobile': fullMobile,
          'id': authController.userData?['id'],
          'role': authController.userData?['role'],
          'profileImage': profileController.profileImage.value,
        };

        await authController.box.write('user_data', jsonEncode(updatedUser));

        profileController.name.value = fullName;
        profileController.email.value = email;
        profileController.mobile.value = fullMobile;

        await profileController.refreshProfile();

        Get.back();
      }
    } catch (e, s) {
      print("========== UPDATE PROFILE ERROR ==========");
      print(e);
      print(s);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMobileVerificationData() async {
    final authController = Get.find<AuthController>();
    final box = authController.box;

    isMobileVerified.value = box.read('isMobileVerified') ?? false;
    storedVerifiedMobile = box.read('verifiedMobile')?.toString() ?? '';
    storedVerifiedCountryCode = box.read('verifiedCountryCode')?.toString() ?? '';

    checkMobileVerificationStatus();
  }

  void checkMobileVerificationStatus() {
    final currentMobile = mobileController.text.trim();
    final currentCountryCode = selectedCountryCode.value.trim();

    final fullCurrent = "$currentCountryCode$currentMobile";

    final isSameVerifiedNumber = isMobileVerified.value && fullCurrent == storedVerifiedMobile;

    isVerificationRequired.value = !isSameVerifiedNumber;
  }

  Future<void> saveVerifiedMobile({
    required String mobile,
    required String countryCode,
  }) async {
    final authController = Get.find<AuthController>();
    final box = authController.box;

    final fullMobile = "$countryCode$mobile";

    await box.write('isMobileVerified', true);
    await box.write('verifiedMobile', fullMobile);
    await box.write('verifiedCountryCode', countryCode);

    isMobileVerified.value = true;
    storedVerifiedMobile = fullMobile;
    storedVerifiedCountryCode = countryCode;

    isVerificationRequired.value = false;
  }

  Future<void> verifyMobile() async {
    final mobile = mobileController.text.trim();
    final countryCode = selectedCountryCode.value.trim();

    if (mobile.isEmpty) {
      Get.snackbar('Error', 'Please enter mobile number');
      return;
    }

    // OTP logic would go here
    // For now we just simulate success if it was previously verified or if we want to bypass for now
  }

  void onCountryChanged(String code, String dialCode) {
    selectedCountryISOCode.value = code;
    selectedCountryCode.value = dialCode;
    checkMobileVerificationStatus();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    super.onClose();
  }
}