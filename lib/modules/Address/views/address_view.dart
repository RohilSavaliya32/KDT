import 'package:flutter/material.dart';
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
      Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
              child: Row(
                children: [
                  Text(
                    isEdit ? "Update Address" : "Add New Address",
                    style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const Divider(),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
                child: Form(
                  key: controller.formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Button
                      OutlinedButton.icon(
                        onPressed: controller.getCurrentLocation,
                        icon: const Icon(Icons.near_me_outlined, size: 18),
                        label: const Text("Use my current location"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.foreground,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: AppColors.border),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildInputField(controller.fullNameController, "Full name *", "Enter Full name", validator: controller.fullNameValidator),
                      _buildInputField(controller.phoneController, "Phone number *", "Enter phone number", keyboardType: TextInputType.phone, validator: controller.phoneValidator),
                      _buildInputField(controller.streetController, "Flat / House / Building *", "Enter Flat / House / Building", validator: controller.streetValidator),
                      _buildInputField(controller.cityController, "City *", "Enter City", validator: controller.cityValidator),
                      _buildInputField(controller.stateController, "State *", "Enter State", validator: controller.stateValidator),
                      _buildInputField(controller.zipCodeController, "Pincode *", "Enter Pincode", keyboardType: TextInputType.number, validator: controller.zipCodeValidator),

                      const SizedBox(height: 10),
                      Obx(() => CheckboxListTile(
                        value: controller.isDefault.value,
                        onChanged: (v) => controller.isDefault.value = v ?? false,
                        title: Text("Set as default address", style: AppTextStyles.poppins(fontSize: 14)),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppColors.accent,
                      )),

                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: controller.isLoading.value ? null : () async {
                          await controller.saveAddress();
                          if (Get.isBottomSheetOpen ?? false) Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: controller.isLoading.value 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(isEdit ? "Update Address" : "Save Address", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTypeOption(String type, IconData icon) {
    final isSelected = controller.selectedType.value == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setAddressType(type),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.lightGreen : AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.accent : AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? AppColors.accent : AppColors.iconGray),
              const SizedBox(width: 8),
              Text(type, style: GoogleFonts.inter(fontSize: 14, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppColors.accent : AppColors.iconGray)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, String hint, {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.foreground)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.poppins(fontSize: 14, color: AppColors.mutedForeground),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.accent, width: 1.2)),
            filled: true,
            fillColor: AppColors.white,
          ),
        ),
        const SizedBox(height: 16),
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
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: address.isDefault ? AppColors.accent : AppColors.border,
          width: address.isDefault ? 1.5 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar for default
              if (address.isDefault)
                Container(
                  width: 6,
                  color: AppColors.accent,
                ),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_getTypeIcon(address.type), size: 18, color: AppColors.iconGray),
                          const SizedBox(width: 8),
                          Text(
                            address.type.isNotEmpty ? address.type.toUpperCase() : 'HOME',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                          if (address.isDefault) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "DEFAULT",
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                onEdit();
                              } else if (value == 'delete') {
                                onDelete();
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                                    const Icon(Icons.edit_outlined, size: 18, color: AppColors.iconGray),
                                    const SizedBox(width: 12),
                                    Text(
                                      "Edit Address",
                                      style: AppTextStyles.poppins(
                                        fontSize: 14,
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
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.lightGray,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(Icons.more_vert, size: 18, color: AppColors.iconGray),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        address.fullName,
                        style: AppTextStyles.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.phone,
                        style: AppTextStyles.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${address.street}, ${address.city}, ${address.state} - ${address.zipCode}",
                        style: AppTextStyles.poppins(
                          fontSize: 13,
                          color: AppColors.mutedForeground,
                          height: 1.4,
                        ),
                      ),
                      if (!address.isDefault) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: AppColors.divider),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: onSetDefault,
                          child: Text(
                            "Set as primary address",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'work': return Icons.work_outline;
      case 'other': return Icons.location_on_outlined;
      default: return Icons.home_outlined;
    }
  }
}


