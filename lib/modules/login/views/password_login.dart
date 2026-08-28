import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_text_style.dart';
import '../../../utils/app_colors.dart';
import '../controllers/login_controller.dart';

class PasswordLoginDialog extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const PasswordLoginDialog({super.key, this.onLoginSuccess});

  @override
  State<PasswordLoginDialog> createState() => _PasswordLoginDialogState();
}

class _PasswordLoginDialogState extends State<PasswordLoginDialog> {
  bool _obscurePassword = true;

  // Consistent font size constants
  static const double _headingSize = 22;
  static const double _subtitleSize = 14;
  static const double _labelSize = 14;
  static const double _bodySize = 14;
  static const double _buttonSize = 15;
  static const double _smallTextSize = 10;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LoginController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Obx(() => SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============ HEADER: CLOSE ICON + LOGO ============
          // ============ HEADER: CLOSE ICON + LOGO ============
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Close Icon
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    c.resetLoginForm();
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 2, top: 2),
                    child: Icon(
                      Icons.close,
                      size: 22,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Logo (Close icon ke niche)
              Center(
                child: Image.asset(
                  'assets/shapes/logo.png',
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ============ TITLE ============
          Text(
              "Welcome Back",
              style: AppTextStyles.lora(
                fontSize: 25,
                fontWeight: FontWeight.w600,
              )
          ),
          const SizedBox(height: 6),

          // ============ SUBTITLE ============
          Text(
            "Enter your password to access your account.",
            style: AppTextStyles.poppins(
              fontSize: _subtitleSize,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 24),

          // ============ EMAIL / PHONE LABEL ============
          Text(
            c.useEmail.value ? "Email Address" : "Phone Number",
            style: AppTextStyles.poppins(
              fontSize: _labelSize,
              fontWeight: FontWeight.w500,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 6),

          // ============ EMAIL / PHONE VALUE (Read Only) ============
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  c.useEmail.value ? Icons.email_outlined : Icons.phone_outlined,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    c.useEmail.value
                        ? c.emailController.text.trim()
                        : '${c.selectedCountryCode.value} ${c.phoneController.text.trim()}',
                    style: AppTextStyles.poppins(
                      fontSize: _bodySize,
                      fontWeight: FontWeight.w500,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ============ PASSWORD LABEL ============
          Text(
            "Password",
            style: AppTextStyles.poppins(
              fontSize: _labelSize,
              fontWeight: FontWeight.w500,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 6),

          // ============ PASSWORD INPUT ============
          TextField(
            controller: c.passwordController,
            focusNode: c.passwordFocusNode,
            obscureText: _obscurePassword,
            onChanged: (_) => c.passwordError.value = null,
            style: AppTextStyles.poppins(
              fontSize: _bodySize,
              color: AppColors.foreground,
            ),
            decoration: InputDecoration(
              hintText: "Enter your password",
              hintStyle: AppTextStyles.poppins(
                color: AppColors.mutedForeground,
                fontSize: _bodySize,
              ),
              errorText: c.passwordError.value,
              errorStyle: AppTextStyles.poppins(
                fontSize: 12,
                color: AppColors.error,
              ),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: AppColors.mutedForeground,
                size: 22,
              ),
              suffixIcon: IconButton(
                onPressed: () => setState(() {
                  _obscurePassword = !_obscurePassword;
                }),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.mutedForeground,
                  size: 22,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.error, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ============ FORGOT PASSWORD ============
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: c.isOtpLoading.value ? null : c.openForgotPassword,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "Forgot Password?",
                style: AppTextStyles.poppins(
                  color: AppColors.accent,
                  fontSize: _labelSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ============ LOGIN BUTTON ============
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: c.isLoading.value
                  ? null
                  : () async {
                final success = await c.loginWithPassword();
                if (success) {
                  widget.onLoginSuccess?.call();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff006241),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: c.isLoading.value
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                "Login",
                style: AppTextStyles.poppins(
                  color: AppColors.background,
                  fontWeight: FontWeight.w500,
                  fontSize: _buttonSize,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ============ BACK BUTTON ============
          Center(
            child: TextButton(
              onPressed: c.backToLogin,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "← Back",
                style: AppTextStyles.poppins(
                  color: AppColors.mutedForeground,
                  fontSize: _labelSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ============ TERMS TEXT ============
          Text(
            "This site is protected by reCAPTCHA and the Google Privacy Policy and Terms of Service apply.",
            textAlign: TextAlign.center,
            style: AppTextStyles.poppins(
              color: AppColors.mutedForeground,
              fontSize: _smallTextSize,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ));
  }
}