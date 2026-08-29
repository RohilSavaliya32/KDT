import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../controllers/login_controller.dart';

class PhoneOtpDialog extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback onBack;

  const PhoneOtpDialog({
    super.key,
    required this.phoneNumber,
    required this.onBack,
  });

  @override
  State<PhoneOtpDialog> createState() => _PhoneOtpDialogState();
}

class _PhoneOtpDialogState extends State<PhoneOtpDialog> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
  List.generate(6, (_) => FocusNode());
  String _otpError = '';

  // ============ ADD THIS: To track OTP completion ============
  final RxBool _isOtpComplete = false.obs;

  LoginController get c => Get.find<LoginController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _otpFocusNodes.first.requestFocus();
    });

    // ============ ADD THIS: Listen to OTP changes ============
    for (int i = 0; i < 6; i++) {
      _otpControllers[i].addListener(_checkOtpCompletion);
    }
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.removeListener(_checkOtpCompletion);
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  // ============ ADD THIS: Check if all OTP fields are filled ============
  void _checkOtpCompletion() {
    final otp = _otpControllers.map((e) => e.text).join();
    _isOtpComplete.value = otp.length == 6;
  }

  String get _otp => _otpControllers.map((e) => e.text).join();

  void _onOtpChanged(String value, int index) {
    if (_otpError.isNotEmpty) {
      setState(() => _otpError = '');
    }

    if (value.isNotEmpty) {
      if (value.length > 1) {
        // Handle paste or multiple chars
        _otpControllers[index].text = value.substring(value.length - 1);
      }
      
      if (index < 5) {
        _otpFocusNodes[index + 1].requestFocus();
      }
    } else if (value.isEmpty && index > 0) {
      // Focus moves back on clear
      _otpFocusNodes[index - 1].requestFocus();
    }

    _checkOtpCompletion();
  }

  Future<void> _verifyOtp() async {
    final otpToVerify = _otp;
    if (otpToVerify.length < 6) {
      setState(() => _otpError = 'Please enter complete 6-digit code');
      return;
    }

    setState(() => _otpError = '');
    await c.verifyPhoneOtp(otpToVerify);

    // Give the controller a moment to process navigation
    await Future.delayed(const Duration(milliseconds: 300));

    if (c.otpError.value == null) {
      if (mounted) {
        // Try to pop if the controller hasn't already closed it or navigated away
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {
          // Dialog might already be gone, which is fine
        }
      }
    } else {
      setState(() {
        _otpError = c.otpError.value ?? 'Wrong OTP. Please enter the correct OTP.';
        
        // Use a small delay to ensure focus and clear work correctly with the keyboard
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          for (final controller in _otpControllers) {
            controller.clear();
          }
          _isOtpComplete.value = false;
          _otpFocusNodes.first.requestFocus();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;

    return Obx(() => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ... (Header remains same)
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Close Icon (First Line)
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

            // Logo (Second Line)
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

        // ... (Titles and phone display remains same)
        Text(
            "Welcome Back",
            style:AppTextStyles.lora(
              fontSize: 25,
              fontWeight: FontWeight.w600,
            )
        ),
        const SizedBox(height: 6),

        Text(
          "Verify your mobile number to sign in.",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),

        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xff6B6B6B),
              ),
              children: [
                const TextSpan(text: "We've sent a code to "),
                TextSpan(
                  text: widget.phoneNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ============ OTP INPUT FIELDS ============
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 48,
              height: isSmallScreen ? 44 : 48,
              child: RawKeyboardListener(
                focusNode: FocusNode(), // Wrap in listener for backspace on empty
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
                        color: Color(0xff006241),
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
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: Text(
                _otpError,
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),

        // ============ RESEND OTP (After OTP Fields) ============
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              c.otpCanResend.value
                  ? "Didn't receive code?"
                  : "Resend code in ${c.otpSecondsLeft.value}s",
              style: TextStyle(
                color: c.otpCanResend.value ? Colors.grey[600] : Colors.grey[500],
                fontSize: 14,
              ),
            ),
            if (c.otpCanResend.value) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: c.isOtpLoading.value ? null : c.resendPhoneOtp,
                child: const Text(
                  "Resend",
                  style: TextStyle(
                    color: Color(0xff006241),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),

        // ============ VERIFY BUTTON (Enable when OTP complete) ============
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            // ============ FIX: Button enabled when OTP is complete ============
            onPressed: c.isOtpLoading.value || !_isOtpComplete.value
                ? null
                : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isOtpComplete.value
                  ? const Color(0xFF006241) // Enabled
                  : const Color(0xFF89A99A), // Disabled

              disabledBackgroundColor: const Color(0xFF89A99A),
              disabledForegroundColor: Colors.white70,
              foregroundColor: Colors.white,

              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),            child: c.isOtpLoading.value
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text(
            "Verify Code",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          ),
        ),
        const SizedBox(height: 12),

        // ============ CHANGE PHONE NUMBER (Back Button) ============
        Center(
          child: GestureDetector(
            onTap: () {
              // Clear OTP fields
              for (final controller in _otpControllers) {
                controller.clear();
              }
              _isOtpComplete.value = false; // Reset OTP complete state
              setState(() => _otpError = '');
              // Call onBack to go back to phone entry screen
              widget.onBack();
            },
            child: const Text(
              "← Change Phone Number",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ============ TERMS TEXT ============
        Text(
          "This site is protected by reCAPTCHA and the Google Privacy Policy and Terms of Service apply.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 10,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
      ],
    ));
  }
}