import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../controllers/login_controller.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key});

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final TextEditingController _newPasswordController = TextEditingController();
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
  List.generate(6, (_) => FocusNode());

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String _otpError = '';
  String _passwordError = '';

  LoginController get c => Get.find<LoginController>();

  @override
  void initState() {
    super.initState();
    // Start OTP timer when dialog opens
    c.otpMode.value = 'forgot_password';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.startOtpTimer();
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otp => _otpControllers.map((e) => e.text).join();

  bool get _canSubmit =>
      _otp.length == 6 &&
          _newPasswordController.text.trim().isNotEmpty &&
          !c.isOtpLoading.value &&
          !_isSubmitting;

  void _onOtpChanged(String value, int index) {
    if (_otpError.isNotEmpty) {
      setState(() => _otpError = '');
    }

    if (value.isNotEmpty) {
      if (value.length > 1) {
        _otpControllers[index].text = value.substring(value.length - 1);
      }
      
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      }
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _submit() async {
    // Validate OTP
    final otpToVerify = _otp;
    if (otpToVerify.length < 6) {
      setState(() => _otpError = 'Please enter complete 6-digit code');
      return;
    }

    // Validate Password
    final newPassword = _newPasswordController.text.trim();
    if (newPassword.isEmpty) {
      setState(() => _passwordError = 'Please fill out this field.');
      return;
    }
    if (newPassword.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _otpError = '';
      _passwordError = '';
      _isSubmitting = true;
    });

    final success = await c.resetPassword(otpToVerify, newPassword);
    setState(() => _isSubmitting = false);

    if (success) {
      c.backToLogin();
    } else {
      setState(() {
        _otpError = c.otpError.value ?? 'Wrong OTP. Please enter the correct OTP.';
        
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          for (final controller in _otpControllers) {
            controller.clear();
          }
          _otpFocusNodes.first.requestFocus();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumber = c.checkedMobile.value.isNotEmpty
        ? c.checkedMobile.value
        : "${c.selectedCountryCode.value}${c.phoneController.text.trim()}";

    return Obx(() => SingleChildScrollView(child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              // KDT DIAMONDS Badge
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Close Icon
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          c.resetLoginForm();
                          Navigator.of(context, rootNavigator: true).pop();
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

                    // Logo
                    Center(
                      child: Image.asset(
                        'assets/shapes/logo.png',
                        height: 22,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.poppins(
                    fontSize: 16,
                    color:AppColors.mutedForeground,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(
                        text: "Enter the 6-digit OTP sent to ",
                        style: TextStyle(
                            fontSize: 14
                        )
                    ),
                    TextSpan(
                      text: phoneNumber,
                      style: AppTextStyles.poppins(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.w500,
                          fontSize: 14
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 48,
              height: 48,
              child: RawKeyboardListener(
                focusNode: FocusNode(),
                onKey: (event) {
                  if (event is RawKeyDownEvent && 
                      event.logicalKey == LogicalKeyboardKey.backspace &&
                      _otpControllers[index].text.isEmpty &&
                      index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                },
                child: TextFormField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: _otpError.isNotEmpty ? Colors.red : Colors.grey.shade300,
                        width: _otpError.isNotEmpty ? 2 : 1,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      borderSide: BorderSide(
                        color: AppColors.accent,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  onChanged: (value) => _onOtpChanged(value, index),
                ),
              ),
            );
          }),
        ),
        if (_otpError.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                _otpError,
                style: AppTextStyles.poppins(
                  color: AppColors.error,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),

        // ============ RESEND OTP (With Timer) ============
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text(
              c.otpCanResend.value
                  ? "Didn't receive code?"
                  : "Resend code in ${c.otpSecondsLeft.value}s",
              style: AppTextStyles.poppins(
                color: c.otpCanResend.value ? Colors.grey[600] : Colors.grey[500],
                fontSize: 14,
              ),
            )),
            Obx(() {
              if (c.otpCanResend.value) {
                return Row(
                  children: [
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: c.isOtpLoading.value
                          ? null
                          : () async {
                        c.otpMode.value = 'forgot_password';
                        debugPrint("OTP MODE BEFORE RESEND : ${c.otpMode.value}");
                        await c.resendPhoneOtp();
                      },
                      child: Text(
                        "Resend",
                        style: AppTextStyles.poppins(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        const SizedBox(height: 24),

        // ============ NEW PASSWORD LABEL ============
        Text(
          "New Password",
          style: AppTextStyles.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 8),

        // ============ NEW PASSWORD INPUT ============
        TextField(
          controller: _newPasswordController,
          obscureText: _obscurePassword,
          onChanged: (_) {
            setState(() {
              if (_passwordError.isNotEmpty) {
                _passwordError = '';
              }
            });
          },
          decoration: InputDecoration(
            hintText: "Enter new password",
            hintStyle: AppTextStyles.poppins(
              color: AppColors.mutedForeground,
              fontSize: 14,
            ),
            errorText: _passwordError.isNotEmpty ? _passwordError : null,
            errorStyle: AppTextStyles.poppins(fontSize: 12),
            prefixIcon: const Icon(
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
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: Color(0xff006241),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ============ RESET PASSWORD BUTTON ============
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _canSubmit ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _canSubmit
                  ? AppColors.accent // Enabled
                  : AppColors.accent_disabel, // Disabled

              foregroundColor: AppColors.background,
              disabledBackgroundColor: AppColors.accent_disabel,
              disabledForegroundColor: Colors.white70,

              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: (_isSubmitting || c.isOtpLoading.value)
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.background,
              ),
            )
                : Text(
              "Reset Password",
              style: AppTextStyles.poppins(
                color: AppColors.background,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // ============ BACK BUTTON ============
        Center(
          child: TextButton(
            onPressed: () {
              c.backToLogin();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child:  Text(
              "← Back",
              style: AppTextStyles.poppins(
                color: AppColors.mutedForeground,
                fontSize: 14,
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
            fontSize: 10,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
      ],
    ),));
  }
}