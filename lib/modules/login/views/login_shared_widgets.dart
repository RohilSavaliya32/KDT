import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginDividerWithText extends StatelessWidget {
  const LoginDividerWithText({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
          child: Text(
            "OR CONTINUE WITH",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

class LoginGoogleButton extends StatelessWidget {
  const LoginGoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    final controller = Get.find<LoginController>();

    return Obx(
          () => SizedBox(
        width: double.infinity,
        height: isSmallScreen ? 44 : 48,
        child: OutlinedButton.icon(
          onPressed: controller.isGoogleLoading.value
              ? null
              : () async {
            FocusScope.of(context).unfocus();

            final success = await controller.loginWithGoogle();

            if (success) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          },
          icon: controller.isGoogleLoading.value
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
              : SvgPicture.asset(
            'assets/icon/google.svg',
            width: isSmallScreen ? 18 : 20,
            height: isSmallScreen ? 18 : 20,
          ),
          label: Text(
            controller.isGoogleLoading.value
                ? "Please wait..."
                : "Sign in with Google",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: isSmallScreen ? 13 : 14,
            ),
          ),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                isSmallScreen ? 4 : 2,
              ),
            ),
            side: BorderSide(
              color: Colors.grey.shade300,
            ),
            elevation: 0,
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );  }
}

class LoginTermsText extends StatelessWidget {
  const LoginTermsText({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Text(
      "This site is protected by reCAPTCHA and the Google Privacy Policy and Terms of Service apply.",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey.shade500,
        fontSize: isSmallScreen ? 9 : 11,
        height: 1.4,
      ),
    );
  }
}