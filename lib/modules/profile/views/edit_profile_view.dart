import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';

import '../../KDTDiamondLoader.dart';
import '../../fade_slide_in.dart';
import '../controllers/edit_profile_controller.dart';
import '../controllers/profile_controller.dart';

class EditProfilePage extends GetView<EditProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,

        // ================= APP BAR =================
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.foreground,
              size: 20,
            ),
          ),
          title: Text(
            "Edit Profile",
            style: AppTextStyles.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.foreground,
            ),
          ),
        ),

        // ================= BODY =================
        body: SafeArea(
          child: Stack(
            children: [
              // ================= FORM =================
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: FadeSlideIn(
                  duration: const Duration(milliseconds: 400),
                  slideOffset: 15,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= PROFILE CARD =================
                      _buildProfileHeaderCard(),

                      const SizedBox(height: 30),

                      // ================= FORM FIELDS =================
                      Obx(
                            () => _buildLabelTextField(
                          label: "First Name",
                          controller: controller.firstNameController,
                          error: controller.firstNameError.value,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Obx(
                            () => _buildLabelTextField(
                          label: "Last Name",
                          controller: controller.lastNameController,
                          error: controller.lastNameError.value,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Obx(
                            () => _buildLabelTextField(
                          label: "Email Address",
                          controller: controller.emailController,
                          enabled: controller.isEmailEditable,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _buildMobileField(),

                      // Bottom fixed button ke liye extra space
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // ================= LOADER OVERLAY =================
              Obx(() {
                if (!controller.isInitialLoading.value) {
                  return const SizedBox.shrink();
                }

                return Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      color: Colors.white.withOpacity(0.85),
                      child: const Center(
                        child: DiamondLoader(),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // ============================================================
        // FIXED SAVE PROFILE BUTTON
        // ============================================================
        bottomNavigationBar: Obx(() {
          return SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                10,
                20,
                16,
              ),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.foreground,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                    "Save Profile",
                    style: AppTextStyles.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER CARD
  // ============================================================

  Widget _buildProfileHeaderCard() {
    final profileController = Get.find<ProfileController>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ================= PROFILE IMAGE =================
          Obx(() {
            final imageUrl = profileController.profileImage.value;
            final pickedFile = controller.pickedImageFile.value;

            return Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade100,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: pickedFile != null
                    ? Image.file(
                  pickedFile,
                  fit: BoxFit.cover,
                )
                    : (imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                )
                    : Image.asset(
                  'assets/shapes/logo.png',
                  fit: BoxFit.contain,
                  color: Colors.grey.shade300,
                )),
              ),
            );
          }),

          const SizedBox(width: 20),

          // ================= NAME / EMAIL / ACTIONS =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                      () => Text(
                    profileController.name.value,
                    style: AppTextStyles.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                Obx(
                      () => Text(
                    profileController.email.value,
                    style: AppTextStyles.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 12),

                Obx(() {
                  final isPicked =
                      controller.pickedImageFile.value != null;

                  final isUploading =
                      controller.isUploadingImage.value;

                  if (isUploading) {
                    return const SizedBox(
                      height: 32,
                      width: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.foreground,
                      ),
                    );
                  }

                  if (isPicked) {
                    return Row(
                      children: [
                        _buildActionButton(
                          label: "Save Photo",
                          onTap: controller.uploadProfileImage,
                          backgroundColor: AppColors.foreground,
                          textColor: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        _buildActionButton(
                          label: "Cancel",
                          onTap: controller.cancelImageSelection,
                          isBordered: true,
                        ),
                      ],
                    );
                  }

                  return Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      _buildActionButton(
                        icon: Icons.camera_alt_outlined,
                        label: "Change Photo",
                        onTap: controller.pickProfileImage,
                        isBordered: true,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _buildActionButton({
    IconData? icon,
    required String label,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    Color? backgroundColor,
    bool isBordered = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isBordered
              ? Border.all(
            color: Colors.grey.shade300,
          )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: iconColor ?? AppColors.foreground,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: textColor ?? AppColors.foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LABEL TEXT FIELD
  // ============================================================

  Widget _buildLabelTextField({
    required String label,
    required TextEditingController controller,
    String? error,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.foreground,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: AppTextStyles.poppins(
            fontSize: 14,
          ),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? Colors.white
                : Colors.grey.shade50,
            errorText: error,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.accent,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MOBILE FIELD
  // ============================================================

  Widget _buildMobileField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Mobile Number",
              style: AppTextStyles.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
            ),

            Obx(() {
              final isVerified =
                  controller.isMobileVerified.value &&
                      !controller.isVerificationRequired.value;

              return isVerified
                  ? Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF16A34A),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Verified",
                    style: AppTextStyles.poppins(
                      fontSize: 12,
                      color: const Color(0xFF16A34A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
                  : InkWell(
                onTap: controller.verifyMobile,
                child: Text(
                  "Verify",
                  style: AppTextStyles.poppins(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ],
        ),

        const SizedBox(height: 8),

        Obx(
              () => IntlPhoneField(
            controller: controller.mobileController,
            enabled: controller.isPhoneEditable,
            initialCountryCode:
            controller.selectedCountryISOCode.value,
            onCountryChanged: (country) {
              controller.onCountryChanged(
                country.code,
                '+${country.dialCode}',
              );
            },
            onChanged: (phone) {
              controller.checkMobileVerificationStatus();
            },
            cursorColor: AppColors.accent,
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: controller.isPhoneEditable
                  ? Colors.white
                  : Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
              ),
            ),
            style: AppTextStyles.poppins(
              fontSize: 14,
            ),
            dropdownTextStyle: AppTextStyles.poppins(
              fontSize: 14,
            ),
            flagsButtonPadding: const EdgeInsets.only(
              left: 8,
            ),
            showDropdownIcon: true,
            dropdownIconPosition: IconPosition.trailing,
          ),
        ),
      ],
    );
  }
}