import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/storage/secure_storage.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../login/controllers/login_controller.dart';
import '../../login/views/auth_repository.dart';
import '../register_request_model.dart';
import '../register_response_model.dart';

class RegisterController extends GetxController {
  final AuthRepository repository;

  RegisterController(this.repository);

  final formKey = GlobalKey<FormState>();

  // ============ CONTROLLERS ============
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final otpControllers = List.generate(6, (_) => TextEditingController());

  // ============ FOCUS NODES ============
  final FocusNode firstNameFocusNode = FocusNode();
  final FocusNode lastNameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode mobileFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final otpFocusNodes = List.generate(6, (_) => FocusNode());
  // ============ OBSERVABLES ============
  final RxBool isLoading = false.obs;
  final RxBool isOtpLoading = false.obs;
  final RxBool isRegistering = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool showOtpScreen = false.obs;
  final RxBool agreeToTerms = false.obs;

  // ============ COUNTRY (for intl_phone_field) ============
  final RxString selectedCountryCode = '+91'.obs;
  final RxString selectedDialCode = 'IN'.obs;
  final RxString selectedCountryName = 'India'.obs;
  bool get isCountryLocked => isMobileLocked.value;

  // ============ ERRORS ============
  final RxString emailError = ''.obs;
  final RxString mobileError = ''.obs;
  final RxString generalError = ''.obs;
  final RxString otpError = ''.obs;

  // ============ LOCKED FIELDS ============
  final RxBool isEmailLocked = false.obs;
  final RxBool isMobileLocked = false.obs;
  final RxString lockedEmail = ''.obs;
  final RxString lockedMobile = ''.obs;

  // ============ OTP TIMER ============
  final RxInt otpSecondsLeft = 60.obs;
  final RxBool otpCanResend = false.obs;
  Timer? _otpTimer;

  // ============ FIREBASE ============
  String? _verificationId;
  int? _resendToken;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    if (args is Map<String, dynamic>) {
      initFromLogin(
        email: args['email'] as String?,
        mobile: args['mobile'] as String?,
      );
    }
  }

  @override
  void onClose() {
    _otpTimer?.cancel();
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    for (final c in otpControllers) {
      c.dispose();
    }
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    emailFocusNode.dispose();
    mobileFocusNode.dispose();
    passwordFocusNode.dispose();
    for (final f in otpFocusNodes) {
      f.dispose();
    }    super.onClose();
  }

  // ============ INIT FROM LOGIN ============
  void initFromLogin({
    String? email,
    String? mobile,
    String? countryCode,
    String? countryName,
    String? countryIso,
  }) {
    // Reset previous data
    emailController.clear();
    mobileController.clear();

    lockedEmail.value = '';
    lockedMobile.value = '';

    isEmailLocked.value = false;
    isMobileLocked.value = false;

    selectedCountryCode.value = '+91';
    selectedDialCode.value = 'IN';
    selectedCountryName.value = 'India';

    // Email login
    if (email != null && email.trim().isNotEmpty) {
      emailController.text = email;
      lockedEmail.value = email;
      isEmailLocked.value = true;
    }

    // Phone login
    if (mobile != null && mobile.trim().isNotEmpty) {
      mobileController.text = mobile;
      lockedMobile.value = mobile;
      isMobileLocked.value = true;
    }

    if (countryCode != null && countryCode.isNotEmpty) {
      selectedCountryCode.value = countryCode;
    }

    if (countryIso != null && countryIso.isNotEmpty) {
      selectedDialCode.value = countryIso;
    }

    if (countryName != null && countryName.isNotEmpty) {
      selectedCountryName.value = countryName;
    }
  }
  // ============ OTP TIMER ============
  void _startOtpTimer() {
    _otpTimer?.cancel();
    otpSecondsLeft.value = 60;
    otpCanResend.value = false;

    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpSecondsLeft.value <= 1) {
        timer.cancel();
        otpSecondsLeft.value = 0;
        otpCanResend.value = true;
      } else {
        otpSecondsLeft.value--;
      }
    });
  }

  // ============ VALIDATION ============
  bool validateEmail() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      emailError.value = 'Please enter your email';
      return false;
    }
    if (!GetUtils.isEmail(email)) {
      emailError.value = 'Please enter a valid email';
      return false;
    }
    emailError.value = '';
    return true;
  }

  bool validateMobile() {
    final mobile = mobileController.text.trim();
    if (mobile.isEmpty) {
      mobileError.value = 'Please enter your mobile number';
      return false;
    }
    if (mobile.length < 5 || mobile.length > 15) {
      mobileError.value = 'Please enter a valid mobile number';
      return false;
    }
    mobileError.value = '';
    return true;
  }

  bool validateOtp() {
    final otp = otpControllers.map((e) => e.text).join();

    if (otp.length != 6) {
      otpError.value = 'Please enter 6-digit OTP';
      return false;
    }

    otpError.value = '';
    return true;
  }

  bool validateAll() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return false;


    if (!isEmailLocked.value) {
      if (!validateEmail()) return false;
    }

    if (!isMobileLocked.value) {
      if (!validateMobile()) return false;
    }

    return true;
  }

  // ============ SEND OTP ============
  Future<void> sendOtp() async {
    if (!validateMobile()) return;

    try {
      isOtpLoading.value = true;
      generalError.value = '';

      final fullPhoneNumber = '$selectedCountryCode${mobileController.text.trim()}';

      if (kDebugMode) {
        debugPrint('================ SENDING OTP ================');
        debugPrint('Phone: $fullPhoneNumber');
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (kDebugMode) {
            debugPrint('================ AUTO VERIFICATION COMPLETED ================');
          }
          await _verifyOtpWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            debugPrint('================ VERIFICATION FAILED ================');
            debugPrint('Code: ${e.code}');
            debugPrint('Message: ${e.message}');
          }
          isOtpLoading.value = false;
          generalError.value = e.message ?? 'Failed to send OTP';
        },
        codeSent: (String verificationId, int? resendToken) {
          if (kDebugMode) {
            debugPrint('================ OTP SENT ================');
            debugPrint('Verification ID: $verificationId');
          }
          _verificationId = verificationId;
          _resendToken = resendToken;
          isOtpLoading.value = false;
          showOtpScreen.value = true;
          _startOtpTimer();

          Get.snackbar(
            'OTP Sent',
            'Verification code sent to your phone',
            snackPosition: SnackPosition.TOP,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (kDebugMode) {
            debugPrint('================ OTP TIMEOUT ================');
          }
          _verificationId = verificationId;
          isOtpLoading.value = false;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Send OTP Error: $e');
      isOtpLoading.value = false;
      generalError.value = e.toString();
    }
  }

  // ============ RESEND OTP ============
  Future<void> resendOtp() async {
    if (!otpCanResend.value) return;

    try {
      isOtpLoading.value = true;
      generalError.value = '';

      final fullPhoneNumber = '$selectedCountryCode${mobileController.text.trim()}';

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _verifyOtpWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          isOtpLoading.value = false;
          generalError.value = e.message ?? 'Failed to resend OTP';
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          isOtpLoading.value = false;
          _startOtpTimer();

          Get.snackbar(
            'OTP Resent',
            'Verification code resent successfully',
            snackPosition: SnackPosition.TOP,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          isOtpLoading.value = false;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Resend OTP Error: $e');
      isOtpLoading.value = false;
      generalError.value = e.toString();
    }
  }

  // ============ VERIFY OTP WITH CREDENTIAL ============
  Future<void> _verifyOtpWithCredential(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (kDebugMode) {
        debugPrint('================ OTP VERIFIED SUCCESSFULLY ================');
      }

      await registerUser();
    } catch (e) {
      if (kDebugMode) debugPrint('OTP Verification Error: $e');
      isOtpLoading.value = false;
      generalError.value = 'OTP verification failed';
    }
  }

  // ============ VERIFY OTP ============
  Future<void> verifyOtp() async {
    if (!validateOtp()) return;

    if (_verificationId == null) {
      generalError.value = 'OTP session expired. Please resend OTP.';
      return;
    }

    try {
      isOtpLoading.value = true;
      generalError.value = '';
      otpError.value = '';

      final otp = otpControllers.map((e) => e.text).join();
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (kDebugMode) {
        debugPrint('================ OTP VERIFIED ================');
      }

      await registerUser();
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) debugPrint('OTP Verification Error: $e');
      isOtpLoading.value = false;
      otpError.value = e.message ?? 'Invalid OTP. Please try again.';
    } catch (e) {
      if (kDebugMode) debugPrint('OTP Verification Error: $e');
      isOtpLoading.value = false;
      generalError.value = 'OTP verification failed. Please try again.';
    }
  }

  // ============ REGISTER USER ============
  Future<void> registerUser() async {
    try {
      isRegistering.value = true;
      generalError.value = '';

      final name = '${firstNameController.text.trim()} ${lastNameController.text.trim()}'.trim();
      final email = emailController.text.trim();
      final mobile = '$selectedCountryCode${mobileController.text.trim()}';
      final password = passwordController.text.trim();

      if (kDebugMode) {
        debugPrint('================ REGISTERING USER ================');
        debugPrint('Name: $name');
        debugPrint('Email: $email');
        debugPrint('Mobile: $mobile');
      }

      final request = RegisterRequestModel(
        name: name,
        email: email,
        mobile: mobile,
        password: password,
      );

      final response = await repository.registerUser(request);

      if (response.success && response.data != null) {
        if (kDebugMode) {
          debugPrint('================ REGISTER SUCCESSFUL ================');
          debugPrint('Token: ${response.data?['accessToken']}');
        }

        await _autoLogin(response);

        Get.snackbar(
          'Account Created',
          'Welcome to KDT Diamonds! Your account has been created successfully.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        AppNavigator.offAll('/navigation');
      } else {
        generalError.value = response.message.isNotEmpty
            ? response.message
            : 'Registration failed';
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Register Error: $e');
      generalError.value = e.toString();
    } finally {
      isRegistering.value = false;
      isOtpLoading.value = false;
      isLoading.value = false;
    }
  }

  // ============ AUTO LOGIN AFTER REGISTRATION ============
  Future<void> _autoLogin(RegisterResponseModel response) async {
    try {
      final authController = Get.find<AuthController>();

      final token = response.data?['accessToken'] ?? '';
      final userData = response.data?['user'] ?? response.data;

      if (token.isNotEmpty) {
        await authController.login(
          token,
          userData: userData is Map<String, dynamic>
              ? userData
              : {
            'id': userData?['id'] ?? '',
            'name': userData?['name'] ?? '',
            'email': userData?['email'] ?? '',
            'mobile': userData?['mobile'] ?? '',
            'role': userData?['role'] ?? '',
          },
        );
      } else {
        // Try to login with credentials if no token
        await authController.loginWithCredentials(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Auto login after register error: $e');
    }
  }

  // ============ UPDATE COUNTRY ============
  void updateCountry(String dialCode, String countryCode, String countryName) {
    selectedCountryCode.value = '+${dialCode.isNotEmpty ? dialCode : '91'}';
    selectedDialCode.value = countryCode.isNotEmpty ? countryCode : 'IN';
    selectedCountryName.value = countryName.isNotEmpty ? countryName : 'India';
  }

  // ============ TOGGLE PASSWORD VISIBILITY ============
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // ============ TOGGLE TERMS ============
  void toggleTerms() {
    agreeToTerms.value = !agreeToTerms.value;
  }

  // ============ CLEAR ERRORS ============
  void clearEmailError() => emailError.value = '';
  void clearMobileError() => mobileError.value = '';
  void clearOtpError() => otpError.value = '';
  void clearGeneralError() => generalError.value = '';

  // ============ BACK TO REGISTER ============
  void backToRegister() {
    showOtpScreen.value = false;
    for (final controller in otpControllers) {
      controller.clear();
    }
    otpError.value = '';
    generalError.value = '';
    _verificationId = null;
    _resendToken = null;
    _otpTimer?.cancel();
    otpSecondsLeft.value = 60;
    otpCanResend.value = false;
  }

  // ============ BACK TO LOGIN ============
// ============ BACK TO LOGIN ============
    void backToLogin() {
      resetForm();

      if (Get.isRegistered<LoginController>()) {
        final loginController = Get.find<LoginController>();

        loginController.showRegisterScreen.value = false;
        loginController.showPasswordScreen.value = false;
        loginController.showForgotPasswordScreen.value = false;

        loginController.emailController.clear();
        loginController.phoneController.clear();
        loginController.passwordController.clear();

        loginController.emailError.value = null;
        loginController.phoneError.value = null;
        loginController.passwordError.value = null;

        loginController.checkedIdentifier.value = '';
        loginController.checkedEmail.value = '';
        loginController.checkedMobile.value = '';

        loginController.userExists.value = false;

        loginController.selectedCountryCode.value = "+91";
        loginController.selectedCountry.value = "India";
        loginController.selectedCountryIso.value = "IN";
        loginController.selectedFlag.value = "🇮🇳";
      }

      FocusManager.instance.primaryFocus?.unfocus();
    }

  // ============ RESET FORM ============
// ============ RESET FORM ============
    void resetForm() {
      firstNameController.clear();
      lastNameController.clear();
      emailController.clear();
      mobileController.clear();
      passwordController.clear();
      for (final controller in otpControllers) {
        controller.clear();
      }
      emailError.value = '';
      mobileError.value = '';
      generalError.value = '';
      otpError.value = '';

      isLoading.value = false;
      isOtpLoading.value = false;
      isRegistering.value = false;

      showOtpScreen.value = false;

      _verificationId = null;
      _resendToken = null;

      _otpTimer?.cancel();
      otpSecondsLeft.value = 60;
      otpCanResend.value = false;

      isEmailLocked.value = false;
      isMobileLocked.value = false;

      lockedEmail.value = '';
      lockedMobile.value = '';

      agreeToTerms.value = false;
      obscurePassword.value = true;

      selectedCountryCode.value = '+91';
      selectedDialCode.value = 'IN';
      selectedCountryName.value = 'India';

      FocusManager.instance.primaryFocus?.unfocus();
    }
  // ============ GETTERS ============
  String get fullName => '${firstNameController.text.trim()} ${lastNameController.text.trim()}'.trim();
  String get email => emailController.text.trim();
  String get mobile => '$selectedCountryCode${mobileController.text.trim()}';
  String get password => passwordController.text.trim();
  bool get isFormValid => validateAll();
}