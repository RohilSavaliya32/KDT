import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:kdt/modules/fade_slide_in.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../login/controllers/login_controller.dart';
import '../../Register/controllers/register_controller.dart';
import '../../Register/views/register_otp_screen.dart';

class RegisterDialog extends StatelessWidget {
  const RegisterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<LoginController>();

    // Get or create RegisterController
    late final RegisterController registerC;

    if (!Get.isRegistered<RegisterController>()) {
      registerC = Get.put(
        RegisterController(Get.find()),
      );
    } else {
      registerC = Get.find<RegisterController>();
    }

    return Obx(() {
      // Show OTP screen for phone registration
      if (registerC.showOtpScreen.value) {
        return RegisterOtpScreen();
      }

      return FadeSlideIn(
        duration: const Duration(milliseconds: 400),
        slideOffset: 15,
        child: _RegisterForm(
          registerC: registerC,
          loginC: c,
        ),
      );
    });
  }
}

class _RegisterForm extends StatelessWidget {
  final RegisterController registerC;
  final LoginController loginC;

  const _RegisterForm({
    required this.registerC,
    required this.loginC,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Form(
          key: registerC.formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =====================================================
                // CLOSE BUTTON + LOGO
                // =====================================================

                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Transform.translate(
                        offset: const Offset(10, 10),
                        child: InkWell(
                          borderRadius:
                          BorderRadius.circular(20),
                          onTap: () => Get.back(),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              size: 22,
                              color:
                              AppColors.mutedForeground,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

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

                // =====================================================
                // TITLE
                // =====================================================

                Text(
                  "Create Account",
                  style: AppTextStyles.lora(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                // =====================================================
                // SUBTITLE
                // =====================================================

                Text(
                  "Complete your details to join our artisan catalog.",
                  style: AppTextStyles.poppins(
                    color: AppColors.mutedForeground,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 20),

                // =====================================================
                // GENERAL ERROR
                // =====================================================

                Obx(() {
                  if (registerC.generalError.value.isNotEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius:
                        BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              registerC.generalError.value,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap:
                            registerC.clearGeneralError,
                            child: const Icon(
                              Icons.close,
                              color: AppColors.error,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                }),

                const SizedBox(height: 16),

                // =====================================================
                // FIRST NAME
                // =====================================================

                Text(
                  "First Name",
                  style: AppTextStyles.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                  ),
                ),

                const SizedBox(height: 6),

                TextFormField(
                  controller:
                  registerC.firstNameController,
                  focusNode:
                  registerC.firstNameFocusNode,
                  textInputAction:
                  TextInputAction.next,
                  cursorColor: AppColors.accent,
                  decoration: InputDecoration(
                    hintText: "Enter first name",
                    errorStyle: AppTextStyles.poppins(fontSize: 11, color: AppColors.error),
                    contentPadding:
                    const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                    focusedBorder:
                    OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 2,
                      ),
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                    enabledBorder:
                    OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.error, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.error, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return "First name is required";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // =====================================================
                // LAST NAME
                // =====================================================

                Text(
                  "Last Name",
                  style: AppTextStyles.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                  ),
                ),

                const SizedBox(height: 6),

                TextFormField(
                  controller:
                  registerC.lastNameController,
                  focusNode:
                  registerC.lastNameFocusNode,
                  textInputAction:
                  TextInputAction.next,
                  cursorColor: AppColors.accent,
                  decoration: InputDecoration(
                    hintText: "Enter last name",
                    errorStyle: AppTextStyles.poppins(fontSize: 11, color: AppColors.error),
                    contentPadding:
                    const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                    focusedBorder:
                    OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 2,
                      ),
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                    enabledBorder:
                    OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius:
                      BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.error, width: 1),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.error, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return "Last name is required";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // =====================================================
                // EMAIL
                // =====================================================

                Text(
                  "Email Address",
                  style: AppTextStyles.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                  ),
                ),

                const SizedBox(height: 6),

                Obx(
                      () => TextFormField(
                    controller:
                    registerC.emailController,
                    focusNode:
                    registerC.emailFocusNode,
                    enabled:
                    !registerC.isEmailLocked.value,
                    readOnly:
                    registerC.isEmailLocked.value,
                    keyboardType:
                    TextInputType.emailAddress,
                    textInputAction:
                    TextInputAction.next,
                    onChanged: (_) =>
                        registerC.clearEmailError(),
                    cursorColor: AppColors.accent,
                    decoration: InputDecoration(
                      hintText:
                      "Enter email address",
                      errorStyle: AppTextStyles.poppins(fontSize: 11, color: AppColors.error),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        size: 20,
                        color:
                        AppColors.mutedForeground,
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      focusedBorder:
                      OutlineInputBorder(
                        borderSide:
                        const BorderSide(
                          color:
                          AppColors.accent,
                          width: 2,
                        ),
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      enabledBorder:
                      OutlineInputBorder(
                        borderSide: BorderSide(
                          color:
                          Colors.grey.shade300,
                        ),
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.error, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.error, width: 2),
                      ),
                      errorText:
                      registerC
                          .emailError
                          .value
                          .isNotEmpty
                          ? registerC
                          .emailError.value
                          : null,
                      filled:
                      registerC.isEmailLocked.value,
                      fillColor:
                      registerC.isEmailLocked.value
                          ? Colors.grey.shade100
                          : null,
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "Email address is required";
                      }

                      if (!GetUtils.isEmail(
                          value.trim())) {
                        return "Please enter a valid email address";
                      }

                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // =====================================================
                // PHONE
                // =====================================================

                Text(
                  "Mobile Number",
                  style: AppTextStyles.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                  ),
                ),

                const SizedBox(height: 6),

                Obx(
                      () => IgnorePointer(
                    ignoring:
                    registerC.isMobileLocked.value,
                    child: IntlPhoneField(
                      key: ValueKey(
                        registerC.selectedDialCode.value,
                      ),
                      controller:
                      registerC.mobileController,
                      focusNode:
                      registerC.mobileFocusNode,
                      enabled:
                      !registerC.isMobileLocked.value,
                      initialCountryCode:
                      registerC.selectedDialCode.value,
                      disableLengthCheck: true,
                      dropdownIconPosition:
                      IconPosition.trailing,
                      flagsButtonPadding:
                      const EdgeInsets.only(
                        left: 12,
                      ),
                      cursorColor: AppColors.accent,
                      decoration:
                      InputDecoration(
                        hintText:
                        "Enter mobile number",
                        errorStyle: AppTextStyles.poppins(fontSize: 11, color: AppColors.error),
                        filled:
                        registerC.isMobileLocked.value,
                        fillColor:
                        registerC.isMobileLocked.value
                            ? Colors.grey.shade100
                            : null,
                        contentPadding:
                        const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            8,
                          ),
                        ),
                        focusedBorder:
                        OutlineInputBorder(
                          borderSide:
                          const BorderSide(
                            color:
                            AppColors.accent,
                            width: 2,
                          ),
                          borderRadius:
                          BorderRadius.circular(
                            8,
                          ),
                        ),
                        enabledBorder:
                        OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                            Colors.grey.shade300,
                          ),
                          borderRadius:
                          BorderRadius.circular(
                            8,
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
                      ),
                      onCountryChanged:
                          (country) {
                        if (registerC
                            .isCountryLocked) {
                          return;
                        }

                        registerC.updateCountry(
                          country.dialCode,
                          country.code,
                          country.name,
                        );
                      },
                      validator: (value) {
                        if (value == null ||
                            value.number.isEmpty) {
                          return "Mobile number is required";
                        }

                        if (value.number.length <
                            10) {
                          return "Please enter a valid mobile number (minimum 10 digits)";
                        }

                        return null;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =====================================================
                // PASSWORD
                // =====================================================

                Text(
                  "Password",
                  style: AppTextStyles.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                  ),
                ),

                const SizedBox(height: 6),

                Obx(
                      () => TextFormField(
                    controller:
                    registerC.passwordController,
                    focusNode:
                    registerC.passwordFocusNode,
                    obscureText:
                    registerC.obscurePassword.value,
                    textInputAction:
                    TextInputAction.done,
                    cursorColor: AppColors.accent,
                    decoration: InputDecoration(
                      hintText:
                      "Enter password (min 6 characters)",
                      errorStyle: AppTextStyles.poppins(fontSize: 11, color: AppColors.error),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        size: 22,
                        color:
                        AppColors.mutedForeground,
                      ),
                      suffixIcon: IconButton(
                        iconSize: 22,
                        onPressed: registerC
                            .togglePasswordVisibility,
                        icon: Icon(
                          registerC
                              .obscurePassword.value
                              ? Icons
                              .visibility_off_outlined
                              : Icons
                              .visibility_outlined,
                        ),
                        color:
                        AppColors.mutedForeground,
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      focusedBorder:
                      OutlineInputBorder(
                        borderSide:
                        const BorderSide(
                          color:
                          AppColors.accent,
                          width: 2,
                        ),
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      enabledBorder:
                      OutlineInputBorder(
                        borderSide: BorderSide(
                          color:
                          Colors.grey.shade300,
                        ),
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.error, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.error, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return "Password is required";
                      }

                      if (value.trim().length < 6) {
                        return "Password must be at least 6 characters";
                      }

                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // =====================================================
                // REGISTER BUTTON
                // =====================================================

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Obx(
                        () => ElevatedButton(
                      onPressed:
                      registerC.isLoading.value ||
                          registerC
                              .isOtpLoading.value
                          ? null
                          : () async {
                        if (registerC
                            .validateAll()) {
                          await registerC
                              .sendOtp();
                        }
                      },
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        AppColors.accent,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            8,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child:
                      registerC
                          .isOtpLoading.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                          AppColors
                              .background,
                        ),
                      )
                          : Text(
                        "Continue",
                        style:
                        AppTextStyles
                            .poppins(
                          color:
                          AppColors
                              .background,
                          fontWeight:
                          FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =====================================================
                // BACK LINK
                // =====================================================

                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      registerC.resetForm();
                      loginC.backToLogin();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 18,
                      color:
                      AppColors.mutedForeground,
                    ),
                    label: Text(
                      "Back",
                      style:
                      AppTextStyles.poppins(
                        color: AppColors
                            .mutedForeground,
                        fontWeight:
                        FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style:
                    TextButton.styleFrom(
                      foregroundColor:
                      AppColors.accent,
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      tapTargetSize:
                      MaterialTapTargetSize
                          .shrinkWrap,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // =====================================================
                // TERMS
                // =====================================================

                Text(
                  "This site is protected by reCAPTCHA and the Google Privacy Policy and Terms of Service apply.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.poppins(
                    color:
                    AppColors.mutedForeground,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}