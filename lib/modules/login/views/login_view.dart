import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/modules/login/views/password_login.dart';
import 'package:kdt/modules/login/views/phone_login.dart';
import 'package:kdt/utils/app_colors.dart';

import '../../Register/views/register_screen.dart';
import '../auth_api_service.dart';
import '../controllers/login_controller.dart';
import 'auth_repository.dart';
import 'email_login.dart';
import 'forgot_password_otp_dialog.dart';
import 'OTP_view.dart';
import 'PhoneNumber_OTP.dart';
import '../../translations/Translation_key/translation_keys.dart';

Future<T?> showLoginModalDialog<T>(
    BuildContext context, {
      VoidCallback? onLoginSuccess,
    }) async {
  if (Get.isDialogOpen == true) return null;

  return showDialog<T>(
    context: context,
    barrierDismissible: true,
    useSafeArea: false,
    builder: (_) => LoginModalDialog(
      onLoginSuccess: onLoginSuccess,
    ),
  );
}

class LoginModalDialog extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginModalDialog({
    super.key,
    this.onLoginSuccess,
  });

  @override
  State<LoginModalDialog> createState() => _LoginModalDialogState();
}

class _LoginModalDialogState extends State<LoginModalDialog> {
  late final LoginController controller;

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<AuthApiService>()) {
      Get.put(AuthApiService());
    }

    if (!Get.isRegistered<AuthRepository>()) {
      Get.put(
        AuthRepository(
          Get.find<AuthApiService>(),
        ),
      );
    }

    if (!Get.isRegistered<LoginController>()) {
      controller = Get.put(LoginController());
    } else {
      controller = Get.find<LoginController>();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetLoginForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final isSmallScreen = screenWidth < 400;

    return Dialog(
      backgroundColor: Colors.white,
      elevation: 0,

      // Dialog ke bahar:
      // top = 100px
      // bottom = 100px
      // Total screen height se 200px kam
      insetPadding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 24,
        vertical: 100,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          isSmallScreen ? 12 : 8,
        ),
      ),

      child: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: Padding(
          // Dialog ke andar top + bottom 10px
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Container(
              width: isSmallScreen
                  ? screenWidth * 0.95
                  : 450,

              constraints: BoxConstraints(
                maxWidth: 450,

                // Maximum height = screen height - 200
                maxHeight: screenHeight - 200,
              ),

              padding: EdgeInsets.only(
                left: isSmallScreen ? 18 : 22,
                right: isSmallScreen ? 18 : 22,
                top: 8,
                bottom: 8,
              ),

              child: Obx(() {
                final showPassword = controller.showPasswordScreen.value;
                final showForgot = controller.showForgotPasswordScreen.value;
                final showRegister = controller.showRegisterScreen.value;
                final showOtp = controller.showOtpScreen.value;
                final isEmail = controller.useEmail.value;

                Widget currentScreen;

                if (showOtp) {
                  currentScreen = KeyedSubtree(
                    key: const ValueKey('otp_screen'),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                      child: isEmail
                          ? CommonOtpDialog(
                        phoneNumber: controller.identifier,
                        title: TranslationKeys.verifyCode.tr,
                        subtitle: TranslationKeys.weSentCodeTo.tr,
                        onBack: () {
                          controller.showOtpScreen.value = false;
                          controller.isOtpLoading.value = false;
                          controller.otpController.clear();
                        },
                        onSuccess: () {},
                      )
                          : PhoneOtpDialog(
                        phoneNumber:
                        "${controller.selectedCountryCode.value}${controller.phoneController.text.trim()}",
                        onBack: () {
                          controller.showOtpScreen.value = false;
                          controller.isOtpLoading.value = false;
                          controller.otpController.clear();
                          controller.otpError.value = null;
                          controller.otpSecondsLeft.value = 60;
                          controller.otpCanResend.value = false;
                        },
                      ),
                    ),
                  );
                } else if (showRegister) {
                  currentScreen = const KeyedSubtree(
                    key: ValueKey('register_screen'),
                    child: RegisterDialog(),
                  );
                } else if (showForgot) {
                  currentScreen = KeyedSubtree(
                    key: const ValueKey('forgot_screen'),
                    child: const SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      child: ForgotPasswordDialog(),
                    ),
                  );
                } else if (showPassword) {
                  currentScreen = KeyedSubtree(
                    key: const ValueKey('password_screen'),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      child: PasswordLoginDialog(
                        onLoginSuccess: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          widget.onLoginSuccess?.call();
                        },
                      ),
                    ),
                  );
                } else {
                  currentScreen = KeyedSubtree(
                    key: const ValueKey('login_screen'),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _HeaderSection(
                            isSmallScreen: isSmallScreen,
                            onClose: () {
                              controller.resetLoginForm();
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                          ),
                          const SizedBox(height: 4),
                          isEmail ? const EmailLoginDialog() : const PhoneLoginDialog(),
                        ],
                      ),
                    ),
                  );
                }

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: currentScreen,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final bool isSmallScreen;
  final VoidCallback onClose;

  const _HeaderSection({
    required this.isSmallScreen,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ===========================================================
        // CLOSE BUTTON
        // ===========================================================

        Align(
          alignment: Alignment.topRight,
          child: GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 0,
                top: 0,
              ),
              child: Icon(
                Icons.close,
                size: isSmallScreen ? 20 : 22,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
        ),

        const SizedBox(height: 3),

        // ===========================================================
        // LOGO
        // ===========================================================

        Center(
          child: Image.asset(
            'assets/shapes/logo.png',
            height: 22,
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(height: 3),
      ],
    );
  }
}