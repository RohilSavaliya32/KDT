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
        splashRadius: 20,
      ),
      title: Text(
        TranslationKeys.myAddresses.tr,
        style: AppTextStyles.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.foreground,
      ),
      actions: [
        IconButton(
          onPressed: () {
            controller.clearForm();
            _openAddressSheet(Get.context!);
          },
          icon: const Icon(
            Icons.add,
            color: AppColors.accent,
          ),
        ),
      ],
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

      if (error.isNotEmpty) {
        return _EmptyOrErrorState(
          icon: Icons.error_outline,
          title: TranslationKeys.somethingWentWrong.tr,
          subtitle: error,
          buttonText: TranslationKeys.retry.tr,
          onButtonTap: controller.getAddresses,
        );
      }

      if (controller.addresses.isEmpty) {
        return _EmptyOrErrorState(
          icon: Icons.location_off_outlined,
          title: TranslationKeys.noAddressesFound.tr,
          subtitle: TranslationKeys.addFirstAddress.tr,
          buttonText: TranslationKeys.addAddress.tr,
          onButtonTap: () {
            controller.clearForm();
            _openAddressSheet(Get.context!);
          },
        );
      }

      return RefreshIndicator(
        color: AppColors.accent,
        onRefresh: controller.getAddresses,
        child: FadeSlideIn(
          duration: const Duration(milliseconds: 500),
          slideOffset: 15,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final address = controller.addresses[index];

              return _AddressCard(
                address: address,
                onEdit: () {
                  controller.fillForm(address);
                  _openAddressSheet(Get.context!);
                },
                onDelete: () =>
                    _confirmDelete(Get.context!, address),
              );
            },
          ),
        ),
      );
    });
  }

  void _openAddressSheet(BuildContext context) {
    final isEdit = controller.editingAddress.value != null;

    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(22),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.10),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Form(
          key: controller.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.borderGray,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  isEdit
                      ? TranslationKeys.updateAddress.tr
                      : TranslationKeys.addAddress.tr,
                  style: AppTextStyles.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),

                const SizedBox(height: 16),

                _Field(
                  controller: controller.fullNameController,
                  label: TranslationKeys.fullName.tr,
                  icon: Icons.person_outline,
                  validator: controller.fullNameValidator,
                  onFieldSubmitted: (_) => _focusNextNode(
                    context,
                    controller.streetController,
                  ),
                ),

                _Field(
                  controller: controller.phoneController,
                  label: TranslationKeys.phoneNumber.tr,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: controller.phoneValidator,
                  onFieldSubmitted: (_) => _focusNextNode(
                    context,
                    controller.streetController,
                  ),
                ),

                _Field(
                  controller: controller.streetController,
                  label: TranslationKeys.street.tr,
                  icon: Icons.home_outlined,
                  validator: controller.streetValidator,
                  onFieldSubmitted: (_) => _focusNextNode(
                    context,
                    controller.cityController,
                  ),
                ),

                _Field(
                  controller: controller.cityController,
                  label: TranslationKeys.city.tr,
                  icon: Icons.location_city_outlined,
                  validator: controller.cityValidator,
                  onFieldSubmitted: (_) => _focusNextNode(
                    context,
                    controller.stateController,
                  ),
                ),

                _Field(
                  controller: controller.stateController,
                  label: TranslationKeys.state.tr,
                  icon: Icons.map_outlined,
                  validator: controller.stateValidator,
                  onFieldSubmitted: (_) => _focusNextNode(
                    context,
                    controller.countryController,
                  ),
                ),

                _Field(
                  controller: controller.countryController,
                  label: TranslationKeys.country.tr,
                  icon: Icons.flag_outlined,
                  validator: controller.countryValidator,
                  onFieldSubmitted: (_) => _focusNextNode(
                    context,
                    controller.zipCodeController,
                  ),
                ),

                _Field(
                  controller: controller.zipCodeController,
                  label: TranslationKeys.zipCode.tr,
                  icon: Icons.local_post_office_outlined,
                  keyboardType: TextInputType.number,
                  validator: controller.zipCodeValidator,
                  onFieldSubmitted: (_) =>
                      _focusNextNode(context, null),
                ),

                const SizedBox(height: 8),

                Obx(
                      () => CheckboxListTile(
                    value: controller.isDefault.value,
                    onChanged: (v) {
                      controller.isDefault.value = v ?? false;
                    },
                    activeColor: AppColors.accent,
                    checkColor: AppColors.white,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity:
                    ListTileControlAffinity.leading,
                    title: Text(
                      TranslationKeys.setAsDefaultAddress.tr,
                      style: AppTextStyles.poppins(
                        color: AppColors.foreground,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Obx(
                      () => SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                        await controller.saveAddress();

                        if (Get.isBottomSheetOpen ?? false) {
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor:
                        AppColors.accentDisabled,
                        disabledForegroundColor:
                        AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                          : Text(
                        isEdit
                            ? TranslationKeys.updateAddress.tr
                            : TranslationKeys.saveAddress.tr,
                        style: AppTextStyles.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      enableDrag: true,
      isDismissible: true,
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

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.background,
      shadowColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.mutedForeground,
                  size: 22,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.fullName,
                              style: AppTextStyles.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.foreground,
                              ),
                              overflow:
                              TextOverflow.ellipsis,
                            ),
                          ),

                          if (address.isDefault)
                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightGreen,
                                borderRadius:
                                BorderRadius.circular(999),
                                border: Border.all(
                                  color:
                                  AppColors.accentDisabled,
                                ),
                              ),
                              child: Text(
                                TranslationKeys.defaultText.tr,
                                style: AppTextStyles.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        address.phone,
                        style: AppTextStyles.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              address.street,
              style: AppTextStyles.poppins(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              '${address.city}, ${address.state}',
              style: AppTextStyles.poppins(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              '${address.country} - ${address.zipCode}',
              style: AppTextStyles.poppins(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                    ),
                    label: Text(
                      TranslationKeys.edit.tr,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                    ),
                    label: Text(
                      TranslationKeys.delete.tr,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const _Field({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        textInputAction: TextInputAction.next,
        style: AppTextStyles.poppins(
          color: AppColors.foreground,
          fontSize: 15,
        ),
        cursorColor: AppColors.accent,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.poppins(
            color: AppColors.mutedForeground,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.iconGray,
          ),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          errorStyle: AppTextStyles.poppins(
            color: AppColors.error,
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.accent,
              width: 1.4,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 1.4,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.error,
            ),
          ),
        ),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 52,
                color: AppColors.mutedForeground,
              ),

              const SizedBox(height: 12),

              Text(
                title,
                style: AppTextStyles.lora(
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
                  fontSize: 14,
                  color: AppColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: onButtonTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.foreground,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
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