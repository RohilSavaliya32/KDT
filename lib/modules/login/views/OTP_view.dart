import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class CommonOtpDialog extends StatefulWidget {
  final String phoneNumber;
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback? onSuccess;

  const CommonOtpDialog({
    super.key,
    required this.phoneNumber,
    required this.title,
    required this.subtitle,
    required this.onBack,
    this.onSuccess,
  });

  @override
  State<CommonOtpDialog> createState() => _CommonOtpDialogState();
}

class _CommonOtpDialogState extends State<CommonOtpDialog> {
  final List<TextEditingController> _otpControllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
  List.generate(6, (_) => FocusNode());
  String _otpError = '';

  LoginController get c => Get.find<LoginController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _otpFocusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otp => _otpControllers.map((e) => e.text).join();

  void _onOtpChanged(String value, int index) {
    if (_otpError.isNotEmpty) {
      setState(() => _otpError = '');
    }

    if (value.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyOtp() async {
    if (_otp.length < 6) {
      setState(() => _otpError = 'Please enter complete 6-digit code');
      return;
    }

    setState(() => _otpError = '');
    await c.verifyPhoneOtp(_otp);

    if (c.otpError.value == null) {
      widget.onSuccess?.call();
    } else {
      setState(() => _otpError = c.otpError.value ?? '');
    }
  }

  void _clearOtp() {
    for (final controller in _otpControllers) {
      controller.clear();
    }
    setState(() => _otpError = '');
    _otpFocusNodes.first.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(
      children: [
        IgnorePointer(
          ignoring: c.isOtpLoading.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              GestureDetector(
                onTap: widget.onBack,
                child: const Icon(Icons.arrow_back, size: 24),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                widget.subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              // Phone Number
              Text(
                widget.phoneNumber,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff006241),
                ),
              ),
              const SizedBox(height: 24),

              // OTP Input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 48,
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
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          borderSide: BorderSide(color: Color(0xff006241), width: 2),
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
                  );
                }),
              ),
              if (_otpError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(
                    child: Text(
                      _otpError,
                      style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Resend
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
                    const SizedBox(width: 8),
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
              const SizedBox(height: 8),

              // Change Phone Number
              GestureDetector(
                onTap: widget.onBack,
                child: const Text(
                  "← Change Phone Number",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: c.isOtpLoading.value || _otp.length < 6
                      ? null
                      : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff006241),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    elevation: 0,
                  ),
                  child: c.isOtpLoading.value
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
              const SizedBox(height: 16),

              // Terms
              Text(
                "This site is protected by reCAPTCHA and the Google Privacy Policy and Terms of Service apply.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}