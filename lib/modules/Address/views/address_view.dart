import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:kdt/utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../address_model.dart';
import '../controllers/address_controller.dart';

class AddressView extends GetView<AddressController> {
  const AddressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          "Address",
          style: AppTextStyles.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.addresses.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.accent));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: controller.addresses.isEmpty
                  ? _buildEmptyState()
                  : _buildAddressList(),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.clearForm();
          _openAddressSheet(Get.context!);
        },
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Add Address",
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 56,
              color: AppColors.mutedForeground,
            ),
            const SizedBox(height: 12),
            Text(
              "No Addresses Saved",
              textAlign: TextAlign.center,
              style: AppTextStyles.lora(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add your first delivery address to enhance your shopping experience.",
              textAlign: TextAlign.center,
              style: AppTextStyles.lora(
                fontSize: 14,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList() {
    return RefreshIndicator(
      onRefresh: controller.getAddresses,
      color: AppColors.accent,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: controller.addresses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, index) {
          final address = controller.addresses[index];
          return _AddressCard(
            address: address,
            onEdit: () {
              controller.fillForm(address);
              _openAddressSheet(Get.context!);
            },
            onDelete: () => _confirmDelete(Get.context!, address),
            onSetDefault: () => controller.setAsDefault(address.id),
          );
        },
      ),
    );
  }

  void _openAddressSheet(BuildContext context) {
    final isEdit = controller.editingAddress.value != null;

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      isEdit ? "Edit Address" : "Add Address",
                      style: AppTextStyles.poppins(
                        fontSize: AppFontSizes.s20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.foreground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: controller.formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() => Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.lightGreen.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.accent.withOpacity(0.1)),
                              ),
                              child: TextButton.icon(
                                onPressed: controller.isLoading.value ? null : controller.getCurrentLocation,
                                icon: controller.isLoading.value
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
                                    : const Icon(Icons.my_location, size: 18, color: AppColors.accent),
                                label: Text(
                                  controller.isLoading.value ? "Fetching location..." : "Use current location",
                                  style: AppTextStyles.poppins(fontSize: AppFontSizes.s14, fontWeight: FontWeight.w600, color: AppColors.accent),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            )),
                        const SizedBox(height: 24),
                        _buildInputField(controller.fullNameController, "Full Name", "Enter your full name", validator: controller.fullNameValidator),
                        _buildPhoneField(),
                        Row(
                          children: [
                            Expanded(child: _buildInputField(controller.cityController, "City", "City", validator: controller.cityValidator)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildInputField(controller.zipCodeController, "Pincode", "Pincode", keyboardType: TextInputType.number, validator: controller.zipCodeValidator)),
                          ],
                        ),
                        _buildInputField(controller.stateController, "State", "State", validator: controller.stateValidator),
                        _buildInputField(controller.streetController, "Address (House No, Building, Street)", "Enter detailed address", validator: controller.streetValidator),

                        Obx(() => CheckboxListTile(
                              value: controller.isDefault.value,
                              onChanged: (v) => controller.isDefault.value = v ?? false,
                              title: Text("Set as default address", style: AppTextStyles.poppins(fontSize: AppFontSizes.s14, fontWeight: FontWeight.w500)),
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: AppColors.accent,
                              checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            )),

                        const SizedBox(height: 24),
                        Obx(() => ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () async {
                                      await controller.saveAddress();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.foreground,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 56),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      isEdit ? "Update Address" : "Save Address",
                                      style: AppTextStyles.poppins(fontSize: AppFontSizes.s16, fontWeight: FontWeight.w700),
                                    ),
                            )),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Phone Number", style: AppTextStyles.poppins(fontSize: AppFontSizes.s14, fontWeight: FontWeight.w600, color: AppColors.foreground)),
        const SizedBox(height: 8),
        Obx(() => IntlPhoneField(
          key: ValueKey(controller.selectedCountryIso.value),
          controller: controller.phoneController,
          cursorColor: AppColors.accent,
          initialCountryCode: controller.selectedCountryIso.value,
          keyboardType: TextInputType.number,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          disableLengthCheck: false,

          onCountryChanged: (country) {
            controller.selectedCountryCode.value = '+${country.dialCode}';
            controller.selectedCountryFlag.value = country.flag;
            controller.selectedCountryIso.value = country.code;
          },

          onChanged: (phone) {
            controller.phoneError.value = '';
          },

          validator: (value) {
            if (value == null || value.number.isEmpty) {
              return "Please enter your phone number";
            }
            return null;
          },

          style: AppTextStyles.poppins(
            fontSize: AppFontSizes.s14,
            fontWeight: FontWeight.w500,
          ),

          decoration: InputDecoration(
            counterText: "",
            hintText: "Enter phone number",
            hintStyle: AppTextStyles.poppins(
              fontSize: AppFontSizes.s14,
              color: AppColors.mutedForeground,
            ),
            errorStyle: AppTextStyles.poppins(
              fontSize: AppFontSizes.s12,
              color: AppColors.error,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.accent,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: AppColors.lightGray.withOpacity(0.3),
          ),
          dropdownTextStyle: AppTextStyles.poppins(
            fontSize: AppFontSizes.s14,
            fontWeight: FontWeight.w600,
            color: AppColors.foreground,
          ),
          dropdownIconPosition: IconPosition.trailing,
          showCountryFlag: true,
        )),
        Obx(() {
          if (controller.phoneError.value.isEmpty) {
            return const SizedBox.shrink();
          }

          return Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text(
              controller.phoneError.value,
              style: AppTextStyles.poppins(
                fontSize: AppFontSizes.s12,
                color: AppColors.error,
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, String hint, {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.poppins(fontSize: AppFontSizes.s14, fontWeight: FontWeight.w600, color: AppColors.foreground)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.poppins(fontSize: AppFontSizes.s14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.poppins(fontSize: AppFontSizes.s14, color: AppColors.mutedForeground),
            errorStyle: AppTextStyles.poppins(fontSize: AppFontSizes.s12, color: AppColors.error),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.error, width: 1)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
            filled: true,
            fillColor: AppColors.lightGray.withOpacity(0.3),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _confirmDelete(BuildContext context, AddressModel address) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Delete Address?",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to remove this address? This action cannot be undone.",
                textAlign: TextAlign.center,
                style: AppTextStyles.poppins(
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: AppColors.foreground,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.deleteAddress(address.id);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Delete",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: address.isDefault ? AppColors.accent.withOpacity(0.5) : AppColors.border,
          width: address.isDefault ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      address.fullName,
                      style: AppTextStyles.poppins(
                        fontSize: AppFontSizes.s16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.foreground,
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Default",
                          style: AppTextStyles.poppins(
                            fontSize: AppFontSizes.s10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                offset: const Offset(0, 40),
                color: Colors.white,
                surfaceTintColor: Colors.white,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    height: 40,
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 18, color: AppColors.foreground),
                        const SizedBox(width: 12),
                        Text(
                          "Edit Address",
                          style: AppTextStyles.poppins(
                            fontSize: AppFontSizes.s14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(height: 1),
                  PopupMenuItem(
                    value: 'delete',
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    height: 40,
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        const SizedBox(width: 12),
                        Text(
                          "Delete",
                          style: AppTextStyles.poppins(
                            fontSize: AppFontSizes.s14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.more_vert, size: 18, color: AppColors.foreground),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 14, color: AppColors.mutedForeground),
              const SizedBox(width: 6),
              Text(
                address.phone,
                style: AppTextStyles.poppins(
                  fontSize: AppFontSizes.s13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "${address.street}, ${address.city}, ${address.state} - ${address.zipCode}",
            style: AppTextStyles.poppins(
              fontSize: AppFontSizes.s13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (!address.isDefault) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            InkWell(
              onTap: onSetDefault,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Text(
                      "Set as primary address",
                      style: AppTextStyles.poppins(
                        fontSize: AppFontSizes.s13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
