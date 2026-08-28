import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../../translations/Translation_key/translation_keys.dart';
import '../controllers/contact_us_controller.dart';

class ContactView extends GetView<ContactController> {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    // Disable text scaling for this screen
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
        boldText: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),

        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
            child: Obx(
                  () => Form(
                key: controller.formKey,
                autovalidateMode: controller.autoValidate.value,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 700;

                    final fieldWidth = isWide
                        ? (constraints.maxWidth - 24) / 2
                        : constraints.maxWidth;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name & Email Row
                        Wrap(
                          spacing: 24,
                          runSpacing: 20,
                          children: [
                            SizedBox(
                              width: fieldWidth,
                              child: _buildTextField(
                                label: TranslationKeys.fullName.tr,
                                controller: controller.nameController,
                                hint: TranslationKeys.enterFullName.tr,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return TranslationKeys
                                        .fullNameRequired
                                        .tr;
                                  }

                                  if (value.trim().length < 3) {
                                    return TranslationKeys
                                        .fullNameMinLength
                                        .tr;
                                  }

                                  return null;
                                },
                              ),
                            ),

                            SizedBox(
                              width: fieldWidth,
                              child: _buildTextField(
                                label: TranslationKeys.emailAddress.tr,
                                controller: controller.emailController,
                                hint: TranslationKeys.enterEmail.tr,
                                keyboardType:
                                TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return TranslationKeys
                                        .emailRequired
                                        .tr;
                                  }

                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$',
                                  );

                                  if (!emailRegex.hasMatch(
                                    value.trim(),
                                  )) {
                                    return TranslationKeys
                                        .validEmail
                                        .tr;
                                  }

                                  return null;
                                },
                              ),
                            ),

                            // Phone & Subject Row
                            SizedBox(
                              width: fieldWidth,
                              child: _buildTextField(
                                label: TranslationKeys.phoneNumber.tr,
                                controller: controller.phoneController,
                                hint: TranslationKeys.enterPhone.tr,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return TranslationKeys
                                        .phoneRequired
                                        .tr;
                                  }

                                  if (value.trim().length < 8) {
                                    return TranslationKeys
                                        .validPhone
                                        .tr;
                                  }

                                  return null;
                                },
                              ),
                            ),

                            SizedBox(
                              width: fieldWidth,
                              child: _buildTextField(
                                label: TranslationKeys.subject.tr,
                                controller:
                                controller.subjectController,
                                hint: TranslationKeys.enterSubject.tr,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return TranslationKeys
                                        .subjectRequired
                                        .tr;
                                  }

                                  if (value.trim().length < 3) {
                                    return TranslationKeys
                                        .subjectMinLength
                                        .tr;
                                  }

                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Message Field
                        Text(
                          TranslationKeys.message.tr,
                          style: AppTextStyles.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: AppColors.foreground,
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextFormField(
                          controller: controller.messageController,
                          maxLines: 6,
                          style: AppTextStyles.poppins(
                            fontSize: 15,
                            color: AppColors.foreground,
                          ),
                          cursorColor: AppColors.accent,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return TranslationKeys
                                  .messageRequired
                                  .tr;
                            }

                            if (value.trim().length < 10) {
                              return TranslationKeys
                                  .messageMinLength
                                  .tr;
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            hintText:
                            TranslationKeys.messageHint.tr,
                            hintStyle: AppTextStyles.poppins(
                              color: AppColors.mutedForeground,
                            ),

                            // Normal Border
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderGray,
                              ),
                            ),

                            // Enabled Border
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderGray,
                              ),
                            ),

                            // Focused Border
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.accent,
                                width: 2,
                              ),
                            ),

                            // Error Border
                            errorBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.error,
                              ),
                            ),

                            // Focused Error Border
                            focusedErrorBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.error,
                                width: 2,
                              ),
                            ),

                            filled: true,
                            fillColor: AppColors.background,

                            contentPadding:
                            const EdgeInsets.all(16),

                            errorMaxLines: 2,
                          ),
                        ),

                        // Space for bottom fixed button
                        const SizedBox(height: 100),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        // =========================================================
        // Fixed Submit Button at Bottom
        // =========================================================
        bottomNavigationBar: SafeArea(
          child: Container(
            color: AppColors.background,
            padding: const EdgeInsets.fromLTRB(
              30,
              10,
              30,
              16,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: Obx(
                    () => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    // Black Button
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,

                    // Disabled Button
                    disabledBackgroundColor:
                    Colors.black54,
                    disabledForegroundColor:
                    Colors.white,

                    // Smooth Rounded Corners
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    elevation: 0,
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.submitContact,
                  child: controller.isLoading.value
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    TranslationKeys.sendMessage.tr,
                    style: AppTextStyles.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,

      iconTheme: const IconThemeData(
        color: AppColors.foreground,
      ),

      leading: IconButton(
        onPressed: () {
          if (Get.key.currentState?.canPop() ?? false) {
            Get.back();
          } else {
            AppNavigator.offAll('/');
          }
        },
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppColors.foreground,
        ),
        tooltip: TranslationKeys.back.tr,
      ),

      title: Text(
        TranslationKeys.contactUs.tr,
        style: AppTextStyles.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.foreground,
          ),
        ),

        const SizedBox(height: 10),

        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,

          style: AppTextStyles.poppins(
            fontSize: 15,
            color: AppColors.foreground,
          ),

          cursorColor: AppColors.accent,

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: AppTextStyles.poppins(
              color: AppColors.mutedForeground,
            ),

            // Normal Border
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.borderGray,
              ),
            ),

            // Enabled Border
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.borderGray,
              ),
            ),

            // Focused Border
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.accent,
                width: 2,
              ),
            ),

            // Error Border
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
              ),
            ),

            // Focused Error Border
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),

            filled: true,

            fillColor: AppColors.background,

            contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }
}