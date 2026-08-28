import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/modules/fade_slide_in.dart';
import 'package:kdt/modules/login/views/password_login.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';
import '../../Register/views/register_screen.dart';
import '../../translations/Translation_key/translation_keys.dart';
import '../controllers/login_controller.dart';
import 'OTP_view.dart';
import 'forgot_password_otp_dialog.dart';
import 'login_shared_widgets.dart';

class EmailLoginDialog extends StatelessWidget {
  const EmailLoginDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LoginController>();

    return Obx(() {
      // Show OTP screen if needed
      if (c.showOtpScreen.value) {
        return CommonOtpDialog(
          phoneNumber: c.identifier,
          title: TranslationKeys.verifyCode.tr,
          subtitle: TranslationKeys.weSentCodeTo.tr,
          onBack: () {
            c.showOtpScreen.value = false;
            c.isOtpLoading.value = false;
            c.otpController.clear();
          },
          onSuccess: () {
            // OTP verified - user already logged in
          },
        );
      }

      // Show Forgot Password
      if (c.showForgotPasswordScreen.value) {
        return const ForgotPasswordDialog();
      }

      // Show Register
      if (c.showRegisterScreen.value) {
        return const RegisterDialog();
      }

      // Show Password Screen (User exists)
      if (c.showPasswordScreen.value) {
        return const PasswordLoginDialog();
      }

      return FadeSlideIn(
        duration: const Duration(milliseconds: 400),
        slideOffset: 15,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      TranslationKeys.welcome.tr,
                      style: AppTextStyles.lora(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      )
                  ),
                  const SizedBox(height: 8),
                  Text(
                    TranslationKeys.enterEmailToContinue.tr,
                    style: AppTextStyles.poppins(
                      color: AppColors.mutedForeground,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: c.emailController,
              focusNode: c.emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              scrollPadding: EdgeInsets.zero,
              style: const TextStyle(fontSize: 16),
              onChanged: c.clearEmailError,
              cursorColor: AppColors.accent,
              decoration: InputDecoration(
                hintText: TranslationKeys.emailAddress.tr,
                hintStyle: const TextStyle(fontSize: 14),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  size: 24,
                  color: AppColors.mutedForeground,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: c.emailError.value != null ? Colors.red : Colors.grey.shade300,
                    width: c.emailError.value != null ? 2 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                    color: c.emailError.value != null ? Colors.red : AppColors.accent,
                    width: 2,
                  ),
                ),
              ),
            ),
            if (c.emailError.value != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.emailError.value!,
                        style: AppTextStyles.poppins(
                          color: AppColors.error,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: c.toggleLoginType,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    TranslationKeys.useMobileInstead.tr,
                    style: AppTextStyles.poppins(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: c.isLoading.value ? null : c.validateAndProceed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                child: c.isLoading.value
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
                  ),
                )
                    : Text(
                  TranslationKeys.continueText.tr,
                  style: AppTextStyles.poppins(
                    color: AppColors.background,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            const LoginDividerWithText(),
            const SizedBox(height: 20),
            const LoginGoogleButton(),
            const SizedBox(height: 20),
            const LoginTermsText(),
          ],
        ),
      );
    });
  }
}