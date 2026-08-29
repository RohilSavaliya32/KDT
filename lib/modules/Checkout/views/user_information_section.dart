// ============================================================
// FILE: widgets/user_information_section.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../translations/Translation_key/translation_keys.dart';
import '../controllers/checkout_controller.dart';
import 'address_selector.dart';
import 'optimized_field.dart';
import 'section_header.dart';

class UserInformationSection extends StatelessWidget {
  const UserInformationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CheckoutController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================================
        // CONTACT INFORMATION SECTION
        // ============================================================
        const SectionHeader(
          icon: Icons.person_outline_rounded,
          title: "Contact Information",
        ),
        const SizedBox(height: 12),
        Divider(color: AppColors.borderGray),
        const SizedBox(height: 18),

        // ============================================================
        // ADDRESS SELECTOR (Quick Autofill)
        // ============================================================
        AddressSelector(controller: controller),

        // ============================================================
        // CONTACT FIELDS
        // ============================================================
        _buildContactFields(controller),

        const SizedBox(height: 14),

        // ============================================================
        // SHIPPING ADDRESS SECTION
        // ============================================================
        const SectionHeader(
          icon: Icons.local_shipping_outlined,
          title: "Shipping Address",
        ),
        const SizedBox(height: 18),

        // ============================================================
        // SHIPPING FIELDS
        // ============================================================
        _buildShippingFields(controller),
      ],
    );
  }

  // ============================================================
  // CONTACT FIELDS
  // ============================================================
  Widget _buildContactFields(CheckoutController controller) {
    return Column(
      children: [
        OptimizedField(
          title: TranslationKeys.fullName.tr,
          controller: controller.nameController,
          textInputAction: TextInputAction.next,
          hint: "Enter your full name",
          maxLength: 100,
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) {
              return "Please enter full name";
            }
            if (v.length < 3) {
              return "Full name must be at least 3 characters";
            }
            if (v.length > 100) {
              return "Full name cannot exceed 100 characters";
            }
            return null;
          },
        ),
        OptimizedField(
          title: TranslationKeys.emailAddress.tr,
          controller: controller.emailController,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          hint: "Enter your email",
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) return "Please enter email address";
            // Proper email validation regex
            final emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
            if (!emailRegex.hasMatch(v)) return "Please enter a valid email address";
            return null;
          },
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TranslationKeys.phoneNumber.tr,
              style: AppTextStyles.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => IntlPhoneField(
              key: ValueKey(controller.selectedCountryIso.value),
              controller: controller.phoneController,
              initialCountryCode: controller.selectedCountryIso.value,
              onCountryChanged: (country) {
                controller.updateCountry(
                  country.flag,
                  '+${country.dialCode}',
                  country.name,
                  country.code,
                );
              },
              cursorColor: AppColors.primaryDark,
              dropdownTextStyle: AppTextStyles.poppins(fontSize: 14),
              style: AppTextStyles.poppins(fontSize: 15),
              decoration: InputDecoration(
                hintText: "Enter your phone number",
                hintStyle: AppTextStyles.poppins(
                  color: AppColors.mutedForeground,
                  fontSize: 14,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.borderGray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.borderGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
              ),
              languageCode: "en",
              onChanged: (phone) {
                // Controller listener handles validation
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // SHIPPING FIELDS
  // ============================================================
  Widget _buildShippingFields(CheckoutController controller) {
    return Column(
      children: [
        OptimizedField(
          title: "Street Address",
          controller: controller.streetController,
          textInputAction: TextInputAction.next,
          hint: "Enter your street address",
          maxLength: 100,
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) {
              return "Please enter street address";
            }
            if (v.length < 5) {
              return "Street address is too short";
            }
            if (v.length > 100) {
              return "Street address cannot exceed 100 characters";
            }
            return null;
          },
        ),
        Row(
          children: [
            Expanded(
              child: OptimizedField(
                title: "City",
                controller: controller.cityController,
                textInputAction: TextInputAction.next,
                hint: "Enter your city",
                maxLength: 100,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) {
                    return "Please enter city";
                  }
                  if (v.length > 100) {
                    return "City name is too long";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: OptimizedField(
                title: "State",
                controller: controller.stateController,
                textInputAction: TextInputAction.next,
                hint: "Enter your state",
                maxLength: 100,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) {
                    return "Please enter state";
                  }
                  if (v.length > 100) {
                    return "State name is too long";
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: OptimizedField(
                title: "Zip Code",
                controller: controller.zipController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                hint: "Enter your zip code",
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) return "Please enter zip code";
                  // Proper zip code validation (e.g., 5-6 digits for many countries)
                  if (!RegExp(r'^[0-9]{4,10}$').hasMatch(v)) {
                    return "Enter a valid 4-10 digit zip code";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: OptimizedField(
                title: "Country",
                controller: controller.countryController,
                textInputAction: TextInputAction.done,
                hint: "Enter your country",
                maxLength: 100,
                validator: (value) {
                  final v = value?.trim() ?? '';
                  if (v.isEmpty) {
                    return "Please enter country";
                  }
                  if (v.length > 100) {
                    return "Country name is too long";
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}