import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:kdt/modules/fade_slide_in.dart';
import 'package:kdt/modules/login/views/password_login.dart';
import 'package:kdt/utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../Register/views/register_screen.dart';
import '../controllers/login_controller.dart';
import 'PhoneNumber_OTP.dart';
import 'forgot_password_otp_dialog.dart';
import 'login_shared_widgets.dart';

class PhoneLoginDialog extends StatelessWidget {
  const PhoneLoginDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LoginController>();

    return Obx(() {
      // ============ SHOW OTP SCREEN ============
      if (c.showOtpScreen.value) {
        return PhoneOtpDialog(
          phoneNumber: "${c.selectedCountryCode.value}${c.phoneController.text.trim()}",
          onBack: () {
            // Hide OTP screen and show phone entry screen
            c.showOtpScreen.value = false;
            c.isOtpLoading.value = false;
            c.otpController.clear();
            c.otpError.value = null;
            // Reset timer
            c.otpSecondsLeft.value = 60;
            c.otpCanResend.value = false;
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
        return PasswordLoginDialog(
          onLoginSuccess: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
        );
      }

      return FadeSlideIn(
        duration: const Duration(milliseconds: 400),
        slideOffset: 15,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "Welcome",
                      style: AppTextStyles.lora(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      )
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Verify your mobile number to sign in.",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ============ PHONE INPUT FIELD ============
            IntlPhoneField(
              controller: c.phoneController,
              focusNode: c.phoneFocusNode,
              cursorColor: AppColors.accent,
              onCountryChanged: (country) {
                c.updateCountry(
                  country.flag,
                  '+${country.dialCode}',
                  country.name,
                  country.code,
                );
              },
              decoration: InputDecoration(
                counterText: "",
                hintText: "Enter mobile number",
                errorText: c.phoneError.value != null && c.phoneError.value!.isNotEmpty
                    ? c.phoneError.value
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                  borderSide: BorderSide(color: AppColors.accent, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
              initialCountryCode: 'IN',
              dropdownTextStyle: const TextStyle(fontSize: 14),
              onChanged: (phone) => c.clearPhoneError(),
            ),
            const SizedBox(height: 6),

            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: c.toggleLoginType,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    "Use Email instead",
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
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
                onPressed: c.isOtpLoading.value ? null : () => c.sendPhoneOtp(mode: 'login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                child: c.isOtpLoading.value
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  "Continue",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const LoginDividerWithText(),
            const SizedBox(height: 16),
            const LoginGoogleButton(),
            const SizedBox(height: 16),
            const LoginTermsText(),
          ],
        ),
      );
    });
  }
}