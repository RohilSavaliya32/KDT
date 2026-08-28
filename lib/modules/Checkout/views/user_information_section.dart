// ============================================================
// FILE: widgets/user_information_section.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Full name is required";
            }
            if (value.trim().length < 3) {
              return "Full name must be at least 3 characters";
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
            if (v.isEmpty) return "Email is required";
            if (!GetUtils.isEmail(v)) return "Please enter a valid email";
            return null;
          },
        ),
        OptimizedField(
          title: TranslationKeys.phoneNumber.tr,
          controller: controller.phoneController,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.phone,
          hint: "Enter your phone number",
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) return "Phone number is required";
            if (!RegExp(r'^[0-9+\s()-]{8,20}$').hasMatch(v)) {
              return "Please enter a valid phone number";
            }
            return null;
          },
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
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Street address is required";
            }
            if (value.trim().length < 5) {
              return "Street address is too short";
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "City is required";
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "State is required";
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
                  if (v.isEmpty) return "Zip code is required";
                  if (!RegExp(r'^[0-9]{4,10}$').hasMatch(v)) {
                    return "Please enter a valid zip code";
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Country is required";
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