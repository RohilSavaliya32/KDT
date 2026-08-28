import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterOtpScreen extends StatelessWidget {
  const RegisterOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<RegisterController>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============ BACK BUTTON ============
          Row(
            children: [
              IconButton(
                onPressed: c.backToRegister,
                icon: const Icon(Icons.arrow_back),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              const Text(
                'Verify OTP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ============ INFO TEXT ============
          Text(
            'Enter the 6-digit OTP sent to ${c.selectedCountryCode.value}${c.mobileController.text.trim()}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // ============ GENERAL ERROR ============
          if (c.generalError.value.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.generalError.value,
                      style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                    ),
                  ),
                  GestureDetector(
                    onTap: c.clearGeneralError,
                    child: Icon(Icons.close, color: Colors.red.shade700, size: 16),
                  ),
                ],
              ),
            ),

          // ============ OTP INPUT FIELDS ============
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 48,
                height: 56,
                child: TextFormField(
                  controller: c.otpControllers[index],
                  focusNode: c.otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  style: const TextStyle(
                    fontSize: 22,
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
                        color: c.otpError.value.isNotEmpty
                            ? Colors.red
                            : Colors.grey.shade300,
                        width: c.otpError.value.isNotEmpty ? 2 : 1,
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      borderSide: BorderSide(
                        color: Color(0xFF005234),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      if (index < 5) {
                        c.otpFocusNodes[index + 1].requestFocus();
                      } else {
                        c.otpFocusNodes[index].unfocus();
                      }
                    } else {
                      if (index > 0) {
                        c.otpFocusNodes[index - 1].requestFocus();
                      }
                    }

                    c.clearOtpError();
                  },
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          // ============ OTP ERROR ============
          if (c.otpError.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                c.otpError.value,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // ============ RESEND OTP ============
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => Text(
                c.otpCanResend.value
                    ? 'Didn\'t receive OTP?'
                    : 'Resend in ${c.otpSecondsLeft.value}s',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              )),
              Obx(() => TextButton(
                onPressed: c.otpCanResend.value
                    ? c.resendOtp
                    : null,
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    color: Color(0xFF005234),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
            ],
          ),
          const SizedBox(height: 24),

          // ============ VERIFY BUTTON ============
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Obx(
                  () => ElevatedButton(
                onPressed: c.isOtpLoading.value || c.isRegistering.value
                    ? null
                    : c.verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5C46),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: c.isOtpLoading.value || c.isRegistering.value
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Verify & Register',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ============ CHANGE NUMBER ============
          Center(
            child: TextButton(
              onPressed: c.backToRegister,
              child: const Text(
                "← Change phone number",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ============ TERMS TEXT ============
          Text(
            'This site is protected by reCAPTCHA and the Google Privacy Policy and Terms of Service apply.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}