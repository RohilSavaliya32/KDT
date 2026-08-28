import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/storage/secure_storage.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../../Register/controllers/register_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/Google_Login/google_signin_service.dart';
import '../auth_api_service.dart';
import '../views/auth_repository.dart';

class LoginController extends GetxController {
  final AuthApiService _api = AuthApiService();
  final GoogleSigninService _googleService = GoogleSigninService();

  // Text Controllers
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  // Focus Nodes
  final emailFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  // UI States
  final useEmail = true.obs;
  final isLoading = false.obs;          // Continue Button
  final isGoogleLoading = false.obs;
  final isOtpLoading = false.obs;
  final showOtpScreen = false.obs;
  final showPasswordScreen = false.obs;

  // Error States
  final emailError = RxnString();
  final phoneError = RxnString();
  final passwordError = RxnString();
  final otpError = RxnString();

  // Country Selection
  final selectedCountryCode = "+91".obs;
  final selectedFlag = "🇮🇳".obs;
  final selectedCountry = "India".obs;
  final selectedCountryIso = "IN".obs;

  // User Check
  final userExists = false.obs;
  final checkedIdentifier = ''.obs;
  final checkedEmail = ''.obs;
  final checkedMobile = ''.obs;

  // OTP Timer
  final otpSecondsLeft = 60.obs;
  final otpCanResend = false.obs;
  Timer? _otpTimer;
  String? _verificationId;
  int? _resendToken;

  // OTP Mode: 'login', 'register', 'forgot_password'
  final otpMode = 'login'.obs;

  // Forgot Password
  final showForgotPasswordScreen = false.obs;

  // Register
  final showRegisterScreen = false.obs;

  // Navigation flag
  bool _isNavigating = false;

  @override
  void onClose() {
    _otpTimer?.cancel();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    otpController.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }

  // ============ RESET FORM ============
  void resetLoginForm() {
    _otpTimer?.cancel();
    _verificationId = null;
    _resendToken = null;
    showOtpScreen.value = false;
    showPasswordScreen.value = false;
    isOtpLoading.value = false;
    otpError.value = null;
    otpController.clear();
    otpSecondsLeft.value = 60;
    otpCanResend.value = false;

    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    emailError.value = null;
    phoneError.value = null;
    passwordError.value = null;
    checkedIdentifier.value = '';
    checkedEmail.value = '';
    checkedMobile.value = '';
    userExists.value = false;
    selectedCountryCode.value = "+91";
    selectedFlag.value = "🇮🇳";
    selectedCountry.value = "India";
    selectedCountryIso.value = "IN";
    useEmail.value = true;
    showForgotPasswordScreen.value = false;
    showRegisterScreen.value = false;
    isLoading.value = false;
    _isNavigating = false;

    FocusManager.instance.primaryFocus?.unfocus();
  }

  void backToLogin() {
    showRegisterScreen.value = false;
    showForgotPasswordScreen.value = false;
    showOtpScreen.value = false;
    showPasswordScreen.value = false;
    isOtpLoading.value = false;
    otpError.value = null;
    otpController.clear();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void toggleLoginType() {
    useEmail.toggle();
    emailError.value = null;
    phoneError.value = null;
    passwordError.value = null;
    passwordController.clear();
    showOtpScreen.value = false;
    showForgotPasswordScreen.value = false;
    showRegisterScreen.value = false;
    showPasswordScreen.value = false;
    isOtpLoading.value = false;

    if (useEmail.value) {
      phoneFocusNode.unfocus();
    } else {
      emailFocusNode.unfocus();
    }
  }

  void updateCountry(String flag, String code, String country, String countryCode) {
    selectedFlag.value = flag.isNotEmpty ? flag : '🇮🇳';
    selectedCountryCode.value = code.isNotEmpty ? code : '+91';
    selectedCountry.value = country.isNotEmpty ? country : 'India';
    selectedCountryIso.value = countryCode.isNotEmpty ? countryCode : 'IN';
  }

  String get identifier {
    if (useEmail.value) {
      return emailController.text.trim();
    }
    return "${selectedCountryCode.value}${phoneController.text.trim()}";
  }

  // ============ CHECK USER ============
  Future<void> validateAndProceed() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (useEmail.value) {
      final email = emailController.text.trim();
      if (email.isEmpty) {
        emailError.value = "Please enter your email address";
        return;
      }
      if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email)) {
        emailError.value = "Please enter valid email address";
        return;
      }
      emailError.value = null;
      await checkUser(email);
    } else {
      final phone = phoneController.text.trim();
      if (phone.isEmpty) {
        phoneError.value = "Please enter your phone number";
        return;
      }
      if (phone.length < 5 || phone.length > 15) {
        phoneError.value = "Phone number must be between 5 and 15 digits";
        return;
      }
      phoneError.value = null;
      await checkUser("${selectedCountryCode.value}$phone");
    }
  }

  Future<void> checkUser(String value) async {
    try {
      isLoading.value = true;
      final response = await _api.checkUser(value);

      userExists.value = response.data.exists;
      checkedIdentifier.value = value;
      checkedEmail.value = response.meta.email;
      checkedMobile.value = response.meta.mobile ?? "";

      if (response.data.exists) {
        showPasswordScreen.value = true;
        showOtpScreen.value = false;
        showForgotPasswordScreen.value = false;
        showRegisterScreen.value = false;
      } else {
        openRegisterScreen();
      }
    } catch (e) {
      final errorText = e.toString().toLowerCase();
      if (errorText.contains('not found') ||
          errorText.contains('404') ||
          errorText.contains('user does not exist') ||
          errorText.contains('user not found')) {
        openRegisterScreen();
      } else {
        Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ============ EMAIL LOGIN ============
  Future<bool> loginWithPassword() async {
    final password = passwordController.text.trim();

    if (password.isEmpty) {
      passwordError.value = "Please enter your password";
      return false;
    }

    passwordError.value = null;
    isLoading.value = true;

    try {
      final loginEmail = useEmail.value
          ? emailController.text.trim()
          : checkedEmail.value.isNotEmpty
          ? checkedEmail.value
          : emailController.text.trim();

      final response = await _api.login(
        email: loginEmail,
        password: password,
      );

      final authController = Get.find<AuthController>();
      await authController.login(
        response.data.accessToken,
        userData: {
          'id': response.data.id,
          'name': response.data.name,
          'email': response.data.email,
          'mobile': response.data.mobile,
          'role': response.data.role,
        },
      );
      // ✅ Save Login Type
      await SecureStorage.saveLoginType("email");
      // ✅ Close dialog before navigation
      await _closeLoginDialogAndNavigate();

      Get.snackbar("Success", "Login successful!", snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar("Login Failed", e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============ PHONE OTP LOGIN ============
  Future<void> sendPhoneOtp({String? mode}) async {
    otpMode.value = mode ?? 'login';

    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      phoneError.value = "Please enter your phone number";
      return;
    }

    if (phone.length < 5 || phone.length > 15) {
      phoneError.value = "Phone number must be between 5 and 15 digits";
      return;
    }

    phoneError.value = null;

    final fullPhoneNumber = "${selectedCountryCode.value}$phone";

    try {
      isLoading.value = true;
      final response = await _api.checkUser(fullPhoneNumber);

      if (!response.data.exists) {
        isLoading.value = false;
        openRegisterScreen();
        return;
      }

      checkedEmail.value = response.meta.email;
      checkedMobile.value = response.meta.mobile ?? fullPhoneNumber;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = false;

    try {
      isOtpLoading.value = true;

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithPhoneCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          isOtpLoading.value = false;
          Get.snackbar("OTP Failed", e.message ?? e.code, snackPosition: SnackPosition.BOTTOM);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          startOtpTimer();
          isOtpLoading.value = false;
          showOtpScreen.value = true;
          Get.snackbar("Success", "OTP sent to $fullPhoneNumber", snackPosition: SnackPosition.BOTTOM);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 5),
      );
    } catch (e) {
      isOtpLoading.value = false;
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> resendPhoneOtp() async {
    String fullPhoneNumber;

    if (checkedMobile.value.isNotEmpty) {
      fullPhoneNumber = checkedMobile.value.trim();
      if (!fullPhoneNumber.startsWith("+")) {
        fullPhoneNumber = "${selectedCountryCode.value}$fullPhoneNumber";
      }
    } else {
      final phone = phoneController.text.trim();
      fullPhoneNumber = "${selectedCountryCode.value}$phone";
    }

    debugPrint("========================================");
    debugPrint("RESEND OTP");
    debugPrint("OTP MODE            : ${otpMode.value}");
    debugPrint("checkedMobile       : ${checkedMobile.value}");
    debugPrint("selectedCountryCode : ${selectedCountryCode.value}");
    debugPrint("phoneController     : ${phoneController.text}");
    debugPrint("FINAL PHONE         : $fullPhoneNumber");
    debugPrint("========================================");

    try {
      isOtpLoading.value = true;

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint("OTP AUTO VERIFIED");
          await _signInWithPhoneCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint("OTP FAILED");
          debugPrint("ERROR CODE    : ${e.code}");
          debugPrint("ERROR MESSAGE : ${e.message}");
          isOtpLoading.value = false;
          Get.snackbar("OTP Failed", e.message ?? e.code, snackPosition: SnackPosition.BOTTOM);
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint("OTP RESENT SUCCESS");
          debugPrint("verificationId : $verificationId");
          debugPrint("resendToken    : $resendToken");
          _verificationId = verificationId;
          _resendToken = resendToken;
          startOtpTimer();
          isOtpLoading.value = false;
          Get.snackbar("Success", "OTP resent successfully", snackPosition: SnackPosition.BOTTOM);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint("AUTO RETRIEVAL TIMEOUT");
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 5),
      );
    } catch (e, s) {
      debugPrint("EXCEPTION : $e");
      debugPrint("STACK : $s");
      isOtpLoading.value = false;
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> verifyPhoneOtp(String otp) async {
    if (_verificationId == null) {
      otpError.value = "OTP session expired. Please resend code.";
      Get.snackbar("Error", "OTP session expired. Please resend code.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isOtpLoading.value = true;
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _signInWithPhoneCredential(credential);
    } on FirebaseAuthException catch (e) {
      otpError.value = e.message ?? e.code;
      Get.snackbar("Invalid OTP", e.message ?? e.code, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isOtpLoading.value = false;
    }
  }

  // ============ ✅ FIXED: SIGN IN WITH PHONE CREDENTIAL ============
  Future<void> _signInWithPhoneCredential(PhoneAuthCredential credential) async {
    // Prevent duplicate navigation
    if (_isNavigating) {
      debugPrint("⚠️ Navigation already in progress, skipping...");
      return;
    }

    try {
      _isNavigating = true;
      isOtpLoading.value = true;

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken(true);

      if (idToken == null) {
        throw Exception("Failed to get ID token");
      }

      if (otpMode.value == 'forgot_password') {
        showOtpScreen.value = false;
        showForgotPasswordScreen.value = true;
        isOtpLoading.value = false;
        _isNavigating = false;
        return;
      }

      // Login flow
      final response = await _api.firebaseLogin(idToken: idToken);
      final authController = Get.find<AuthController>();

      await authController.login(
        response.data.accessToken,
        userData: {
          'id': response.data.id,
          'name': response.data.name,
          'email': response.data.email,
          'mobile': response.data.mobile,
          'role': response.data.role,
        },
      );
      await SecureStorage.saveLoginType("mobile");
      // ✅ Close OTP screen
      showOtpScreen.value = false;

      // ✅ Close any snackbar
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }

      // ✅ CLOSE DIALOG BEFORE NAVIGATION
      await _closeLoginDialogAndNavigate();

    } catch (e) {
      debugPrint("❌ _signInWithPhoneCredential error: $e");
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
      rethrow;
    } finally {
      isOtpLoading.value = false;
      Future.delayed(const Duration(milliseconds: 500), () {
        _isNavigating = false;
      });
    }
  }

  // ============ ✅ NEW: CLOSE DIALOG AND NAVIGATE ============
  Future<void> _closeLoginDialogAndNavigate() async {
    try {
      // Method 1: Try to close dialog using Get.back()
      if (Get.isDialogOpen ?? false) {
        debugPrint("✅ Closing login dialog...");
        Get.back(); // Close the dialog
        await Future.delayed(const Duration(milliseconds: 200)); // Wait for dialog to close
      }

      // Method 2: Alternative - close all overlays
      if (Get.isDialogOpen ?? false) {
        debugPrint("⚠️ Dialog still open, force closing...");
        Navigator.of(Get.overlayContext!).pop();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Check if we're already on the navigation route
      final currentRoute = Get.currentRoute;
      if (currentRoute != "/navigation") {
        debugPrint("✅ Navigating to /navigation");
        // Use AppNavigator for common loader support
        AppNavigator.offAll("/navigation");
      } else {
        debugPrint("✅ Already on /navigation route");
        // Just refresh the current route
        Get.forceAppUpdate();
      }

    } catch (e) {
      debugPrint("❌ Error in _closeLoginDialogAndNavigate: $e");

      // Fallback: Try navigation with delay
      try {
        await Future.delayed(const Duration(milliseconds: 300));
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        await Future.delayed(const Duration(milliseconds: 100));
        AppNavigator.offAll("/navigation");
      } catch (e2) {
        debugPrint("❌ Fallback navigation failed: $e2");
        // Last resort
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isDialogOpen ?? false) {
            Navigator.of(Get.overlayContext!).pop();
          }
          AppNavigator.offAll("/navigation");
        });
      }
    }
  }

  // ============ REGISTER ============
  void openRegisterScreen() {
    if (!Get.isRegistered<RegisterController>()) {
      Get.put(
        RegisterController(
          Get.find<AuthRepository>(),
        ),
      );
    }
    final registerController = Get.find<RegisterController>();
    registerController.resetForm();
    registerController.initFromLogin(
      email: useEmail.value ? emailController.text.trim() : null,
      mobile: useEmail.value ? null : phoneController.text.trim(),
      countryCode: selectedCountryCode.value,
      countryName: selectedCountry.value,
      countryIso: selectedCountryIso.value,
    );

    showOtpScreen.value = false;
    showForgotPasswordScreen.value = false;
    showPasswordScreen.value = false;
    showRegisterScreen.value = true;
  }

  // ============ FORGOT PASSWORD ============
  void openForgotPassword() {
    showForgotPasswordScreen.value = true;
    showOtpScreen.value = false;
    showRegisterScreen.value = false;
    showPasswordScreen.value = false;
  }

  Future<void> sendForgotPasswordOtp() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      phoneError.value = "Please enter your phone number";
      return;
    }
    phoneError.value = null;
    otpMode.value = 'forgot_password';
    await sendPhoneOtp(mode: 'forgot_password');
  }

  Future<bool> resetPassword(String otp, String newPassword) async {
    if (_verificationId == null) {
      Get.snackbar(
        "Error",
        "OTP session expired. Please resend code.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      isOtpLoading.value = true;

      debugPrint("========== RESET PASSWORD ==========");
      debugPrint("OTP : $otp");
      debugPrint("VerificationId : $_verificationId");

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      debugPrint("Credential Created");

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      debugPrint("Firebase Login Success");
      debugPrint("UID : ${userCredential.user?.uid}");

      final idToken = await userCredential.user?.getIdToken(true);

      debugPrint("ID TOKEN : $idToken");

      await _api.resetPassword(
        newPassword: newPassword,
        firebaseIdToken: idToken,
      );

      debugPrint("RESET PASSWORD API SUCCESS");

      showForgotPasswordScreen.value = false;
      showPasswordScreen.value = true;

      Get.snackbar(
        "Success",
        "Password updated successfully",
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e, s) {
      debugPrint("RESET PASSWORD ERROR");
      debugPrint(e.toString());
      debugPrint(s.toString());

      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;
    } finally {
      isOtpLoading.value = false;
    }
  }

  // ============ GOOGLE LOGIN ============
  Future<bool> loginWithGoogle() async {
    try {
      isGoogleLoading.value = true;

      debugPrint("==================================");
      debugPrint("GOOGLE LOGIN START");
      debugPrint("==================================");

      final idToken = await _googleService.signIn();

      debugPrint("Firebase Token:");
      debugPrint(idToken);

      if (idToken == null) {
        debugPrint("Firebase Token is NULL");
        return false;
      }

      debugPrint("==================================");
      debugPrint("Calling firebaseLogin API...");
      debugPrint("==================================");

      final response = await _api.firebaseLogin(
        idToken: idToken,
      );

      debugPrint("==================================");
      debugPrint("firebaseLogin API SUCCESS");
      debugPrint("Access Token : ${response.data.accessToken}");
      debugPrint("User ID      : ${response.data.id}");
      debugPrint("Name         : ${response.data.name}");
      debugPrint("Email        : ${response.data.email}");
      debugPrint("==================================");

      final authController = Get.find<AuthController>();

      debugPrint("Calling AuthController.login()");

      await authController.login(
        response.data.accessToken,
        userData: {
          'id': response.data.id,
          'name': response.data.name,
          'email': response.data.email,
          'mobile': response.data.mobile,
          'role': response.data.role,
        },
      );
      await SecureStorage.saveLoginType("google");
      debugPrint("AuthController.login SUCCESS");

      await _closeLoginDialogAndNavigate();

      debugPrint("Navigation SUCCESS");

      Get.snackbar(
        "Success",
        "Google Login Successful",
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;

    } catch (e, s) {

      debugPrint("==================================");
      debugPrint("GOOGLE LOGIN ERROR");
      debugPrint("==================================");
      debugPrint(e.toString());
      debugPrint(s.toString());
      debugPrint("==================================");

      Get.snackbar(
        "Google Login Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );

      return false;

    } finally {
      isGoogleLoading.value = false;
    }
  }
  // ============ OTP TIMER ============
  void startOtpTimer() {
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

  // ============ HELPERS ============
  void clearEmailError([String? _]) => emailError.value = null;
  void clearPhoneError([String? _]) => phoneError.value = null;
  void clearPasswordError([String? _]) => passwordError.value = null;
}
