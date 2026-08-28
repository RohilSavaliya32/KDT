import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kdt/modules/fade_slide_in.dart';
import 'package:kdt/utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../address_model.dart';
import '../controllers/address_controller.dart';
import '../../translations/Translation_key/translation_keys.dart';

class AddressView extends GetView<AddressController> {
  const AddressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.foreground,
      surfaceTintColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppColors.foreground,
          size: 20,
        ),
        onPressed: () => Get.back(),
        padding: const EdgeInsets.only(left: 12),
      ),
      title: Text(
        TranslationKeys.address.tr,
        style: AppTextStyles.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.foreground,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      final error = controller.errorMessage.value.trim();

      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.accent,
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: error.isNotEmpty
                ? _EmptyOrErrorState(
                    icon: Icons.error_outline,
                    title: TranslationKeys.somethingWentWrong.tr,
                    subtitle: error,
                    buttonText: TranslationKeys.retry.tr,
                    onButtonTap: controller.getAddresses,
                  )
                : controller.addresses.isEmpty
                    ? _EmptyOrErrorState(
                        icon: Icons.location_on_outlined,
                        title: "Koi address saved nahi hai",
                        subtitle: "Upar \"Add Address\" se apna pehla delivery address jodein",
                        buttonText: TranslationKeys.addAddress.tr,
                        onButtonTap: () {
                          controller.clearForm();
                          _openAddressSheet(Get.context!);
                        },
                      )
                    : RefreshIndicator(
                        color: AppColors.accent,
                        onRefresh: controller.getAddresses,
                        child: FadeSlideIn(
                          duration: const Duration(milliseconds: 500),
                          slideOffset: 15,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        ),
                      ),
          ),
        ],
      );
    });
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DELIVERY",
                  style: AppTextStyles.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mutedForeground,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Your Addresses",
                  style: AppTextStyles.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Saved addresses yahaan manage karein — add, edit ya default set karein.",
                  style: AppTextStyles.poppins(
                    fontSize: 14,
                    color: AppColors.mutedForeground,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              controller.clearForm();
              _openAddressSheet(Get.context!);
            },
            icon: const Icon(Icons.add, size: 18, color: Colors.white),
            label: const Text("Add Address"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  void _openAddressSheet(BuildContext context) {
    final isEdit = controller.editingAddress.value != null;

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
              child: Row(
                children: [
                  Text(
                    isEdit ? "Update Address" : "Add New Address",
                    style: AppTextStyles.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.foreground,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFF1F5F9)),

            Expanded(
              child: Form(
                key: controller.formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Button
                      OutlinedButton.icon(
                        onPressed: controller.getCurrentLocation,
                        icon: const Icon(Icons.near_me_outlined, size: 20),
                        label: const Text("Use my current location"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.foreground,
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: AppTextStyles.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Type Selector
                      Obx(() => Row(
                            children: [
                              _buildTypeOption("Home"),
                              const SizedBox(width: 12),
                              _buildTypeOption("Work"),
                              const SizedBox(width: 12),
                              _buildTypeOption("Other"),
                            ],
                          )),
                      const SizedBox(height: 24),

                      _Field(
                        controller: controller.fullNameController,
                        label: "Full name",
                        hint: "e.g. Sujal Savaliya",
                        isRequired: true,
                        validator: controller.fullNameValidator,
                      ),
                      _Field(
                        controller: controller.phoneController,
                        label: "Phone number",
                        hint: "+91 98765 43210",
                        isRequired: true,
                        keyboardType: TextInputType.phone,
                        validator: controller.phoneValidator,
                      ),
                      _Field(
                        controller: controller.streetController,
                        label: "Flat / House / Building",
                        hint: "Flat, house no., building",
                        isRequired: true,
                        validator: controller.streetValidator,
                      ),
                      _Field(
                        controller: controller.cityController,
                        label: "City",
                        hint: "Surat",
                        isRequired: true,
                        validator: controller.cityValidator,
                      ),
                      _Field(
                        controller: controller.stateController,
                        label: "State",
                        hint: "Gujarat",
                        isRequired: true,
                        validator: controller.stateValidator,
                      ),
                      _Field(
                        controller: controller.zipCodeController,
                        label: "Pincode",
                        hint: "395007",
                        isRequired: true,
                        keyboardType: TextInputType.number,
                        validator: controller.zipCodeValidator,
                      ),

                      const SizedBox(height: 8),
                      Obx(() => CheckboxListTile(
                            value: controller.isDefault.value,
                            onChanged: (v) => controller.isDefault.value = v ?? false,
                            title: Text(
                              "Set as default address",
                              style: AppTextStyles.poppins(
                                fontSize: 14,
                                color: AppColors.foreground,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: const Color(0xFF0F172A),
                          )),

                      const SizedBox(height: 24),
                      Obx(() => ElevatedButton(
                            onPressed: controller.isLoading.value ? null : controller.saveAddress,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    isEdit ? "Update Address" : "Save Address",
                                    style: AppTextStyles.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          )),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildTypeOption(String type) {
    final isSelected = controller.selectedType.value == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setAddressType(type),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE2E8F0) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            type,
            style: AppTextStyles.poppins(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  }

  void _focusNextNode(
      BuildContext context,
      TextEditingController? nextController,
      ) {
    if (nextController != null) {
      FocusScope.of(context).nextFocus();
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  void _confirmDelete(
      BuildContext context,
      AddressModel address,
      ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        title: Text(
          TranslationKeys.deleteAddress.tr,
          style: AppTextStyles.poppins(
            color: AppColors.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          TranslationKeys.deleteAddressConfirmation.tr,
          style: AppTextStyles.poppins(
            color: AppColors.foreground,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              TranslationKeys.cancel.tr,
              style: AppTextStyles.poppins(
                color: AppColors.foreground,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.deleteAddress(address.id);
            },
            child: Text(
              TranslationKeys.delete.tr,
              style: AppTextStyles.poppins(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
    final typeIcon = address.type.toLowerCase() == 'work' ? Icons.work_outline : Icons.home_outlined;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: address.isDefault ? const Color(0xFF64748B) : const Color(0xFFE2E8F0),
          width: address.isDefault ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTag(address.type.isNotEmpty ? address.type : 'Home', typeIcon),
                if (address.isDefault) ...[
                  const SizedBox(width: 8),
                  _buildTag("Default", Icons.check, isDefault: true),
                ],
                const Spacer(),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF64748B)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 20, color: Color(0xFF64748B)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: address.fullName,
                    style: AppTextStyles.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.foreground,
                    ),
                  ),
                  TextSpan(
                    text: " · ${address.phone}",
                    style: AppTextStyles.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${address.street}, ${address.city}, ${address.state} — ${address.zipCode}",
              style: AppTextStyles.poppins(
                fontSize: 14,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            if (!address.isDefault) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onSetDefault,
                child: Text(
                  "Set as default",
                  style: AppTextStyles.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, IconData icon, {bool isDefault = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0F172A)),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool isRequired;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: AppTextStyles.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                if (isRequired)
                  TextSpan(
                    text: " *",
                    style: AppTextStyles.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: AppTextStyles.poppins(
              fontSize: 15,
              color: const Color(0xFF0F172A),
            ),
            cursorColor: const Color(0xFF0F172A),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.poppins(
                fontSize: 15,
                color: const Color(0xFF94A3B8),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrErrorState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onButtonTap;

  const _EmptyOrErrorState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      duration: const Duration(milliseconds: 500),
      slideOffset: 15,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 64,
                color: const Color(0xFF64748B),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: AppTextStyles.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.foreground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTextStyles.poppins(
                  fontSize: 15,
                  color: const Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (buttonText.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onButtonTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonText,
                      style: AppTextStyles.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}