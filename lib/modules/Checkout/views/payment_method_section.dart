// ============================================================
// FILE: widgets/payment_method_section.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/Setting_Cont.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../Payment_Summary/controllers/payment_confirmation_controller.dart';
import '../controllers/checkout_controller.dart';
import 'optimized_field.dart';
import 'section_header.dart';

class PaymentMethodSection extends StatelessWidget {
  const PaymentMethodSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CheckoutController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================================
        // PAYMENT METHOD SELECTION
        // ============================================================
        const SectionHeader(
          icon: Icons.payment_outlined,
          title: "Select Payment Method",
        ),
        const SizedBox(height: 18),
        const _PaymentMethodCard(),
        const SizedBox(height: 24),

        // ============================================================
        // BANK TRANSFER DETAILS
        // ============================================================
        const _BankTransferDetailsCard(),
        const SizedBox(height: 24),

        // ============================================================
        // RECEIPT UPLOAD SECTION
        // ============================================================
        _ReceiptUploadCard(controller: controller),
      ],
    );
  }
}

// ============================================================
// PAYMENT METHOD CARD
// ============================================================

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_outlined, color: AppColors.primaryDark, size: 20),
              const SizedBox(width: 10),
              Text(
                "Bank Transfer (Manual)",
                style: AppTextStyles.poppins(
                  fontSize: AppFontSizes.s14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Transfer directly to our bank account and upload proof of payment.",
            style: AppTextStyles.poppins(
              fontSize: AppFontSizes.s12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BANK TRANSFER DETAILS CARD
// ============================================================

class _BankTransferDetailsCard extends StatelessWidget {
  const _BankTransferDetailsCard();

  @override
  Widget build(BuildContext context) {
    final paymentController = Get.find<SettingsDataController>();
    return Obx(() {
      if (paymentController.isLoading.value && paymentController.settings.value == null) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightGray.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderGray),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bank Transfer Details",
              style: AppTextStyles.poppins(
                fontSize: AppFontSizes.s14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _BankDetailRow(label: "Bank:", value: paymentController.getBankName()),
            _BankDetailRow(label: "Account Name:", value: paymentController.getAccountName()),
            _BankDetailRow(label: "Account No:", value: paymentController.getAccountNumber()),
            _BankDetailRow(label: "Routing:", value: paymentController.getRoutingNumber()),
            _BankDetailRow(label: "SWIFT/BIC:", value: paymentController.getSwiftCode()),
          ],
        ),
      );
    });
  }
}

class _BankDetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _BankDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: AppTextStyles.poppins(
                fontSize: AppFontSizes.s13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.poppins(
                fontSize: AppFontSizes.s13,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// RECEIPT UPLOAD CARD
// ============================================================

class _ReceiptUploadCard extends StatelessWidget {
  final CheckoutController controller;
  const _ReceiptUploadCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Upload Payment Receipt",
            style: AppTextStyles.poppins(
              fontSize: AppFontSizes.s14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _ReceiptFormFields(controller: controller),
          const SizedBox(height: 8),
          _FileUploadSection(controller: controller),
        ],
      ),
    );
  }
}

// ============================================================
// RECEIPT FORM FIELDS (with Date Picker)
// ============================================================

class _ReceiptFormFields extends StatelessWidget {
  final CheckoutController controller;
  const _ReceiptFormFields({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        OptimizedField(
          title: "Transaction ID / UTR",
          controller: controller.transactionIdController,
          textInputAction: TextInputAction.next,
          hint: "Enter UTR or Reference No.",
          maxLength: 100,
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) {
              return "Please enter transaction ID";
            }
            if (v.length > 100) return "Transaction ID too long";
            return null;
          },
        ),

        OptimizedField(
          title: "Bank Name",
          controller: controller.bankNameController,
          textInputAction: TextInputAction.next,
          hint: "Bank Name",
          maxLength: 100,
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) {
              return "Please enter bank name";
            }
            if (v.length > 100) return "Bank name too long";
            return null;
          },
        ),

        OptimizedField(
          title: "Transfer Amount",
          controller: controller.transferAmountController,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          hint: "Amount transferred",
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) return "Please enter transfer amount";
            if (double.tryParse(v) == null) return "Enter valid amount";
            return null;
          },
        ),

        _DatePickerField(
          controller: controller.transferDateController,
          title: "Transfer Date",
          hint: "yyyy-mm-dd",
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please select transfer date";
            }
            return null;
          },
        ),
      ],
    );
  }
}

// ============================================================
// DATE PICKER FIELD
// ============================================================

class _DatePickerField extends FormField<String> {
  final TextEditingController controller;
  final String title;
  final String hint;

  _DatePickerField({
    required this.controller,
    required this.title,
    required this.hint,
    super.validator,
  }) : super(
          initialValue: controller.text,
          builder: (FormFieldState<String> state) {
            final hasError = state.hasError;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.poppins(
                      fontSize: AppFontSizes.s13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: state.context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(), // Disable future dates
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primaryDark,
                                onPrimary: AppColors.white,
                                onSurface: AppColors.textPrimary,
                              ),
                              dialogBackgroundColor: AppColors.white,
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (picked != null) {
                        // API format: yyyy-MM-dd
                        final String formattedDate =
                            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";

                        controller.text = formattedDate;
                        state.didChange(formattedDate);
                      }
                    },
                    borderRadius: BorderRadius.circular(2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: hasError ? AppColors.error : AppColors.borderGray,
                          width: hasError ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: hasError ? AppColors.error : AppColors.darkGray,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              controller.text.isEmpty ? hint : controller.text,
                              style: AppTextStyles.poppins(
                                fontSize: AppFontSizes.s14,
                                fontWeight: FontWeight.w400,
                                color: controller.text.isEmpty
                                    ? AppColors.darkGray
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: hasError ? AppColors.error : AppColors.darkGray,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        state.errorText ?? '',
                        style: AppTextStyles.poppins(
                          fontSize: AppFontSizes.s12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
}

// ============================================================
// FILE UPLOAD SECTION (Improved with Validation)
// ============================================================

class _FileUploadSection extends FormField<String> {
  final CheckoutController controller;

  _FileUploadSection({required this.controller})
      : super(
          validator: (value) {
            if (controller.receiptImagePath.value.isEmpty) {
              return "Please upload payment receipt image";
            }
            return null;
          },
          builder: (FormFieldState<String> state) {
            final hasError = state.hasError;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasError ? AppColors.error : AppColors.borderGray,
                      width: hasError ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.attach_file_outlined,
                            color: hasError ? AppColors.error : AppColors.darkGray,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Select Image (JPG, PNG, WEBP)",
                            style: AppTextStyles.poppins(
                              fontSize: AppFontSizes.s12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          await controller.pickReceiptImage();
                          state.didChange(controller.receiptImagePath.value);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Obx(() {
                          final hasFile = controller.receiptImagePath.value.isNotEmpty;
                          final fileName = controller.receiptImagePath.value.split('/').last;

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              color: hasFile
                                  ? AppColors.success.withOpacity(0.05)
                                  : AppColors.lightGray,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: hasFile
                                    ? AppColors.success
                                    : (hasError ? AppColors.error : AppColors.borderGray),
                                width: hasFile || hasError ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  hasFile ? Icons.check_circle : Icons.cloud_upload_outlined,
                                  color: hasFile
                                      ? AppColors.success
                                      : (hasError ? AppColors.error : AppColors.darkGray),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    hasFile ? fileName : "Select image (JPG, PNG, WEBP)",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.poppins(
                                      fontSize: hasFile ? AppFontSizes.s12 : AppFontSizes.s13,
                                      fontWeight: hasFile ? FontWeight.w500 : FontWeight.w400,
                                      color: hasFile
                                          ? AppColors.success
                                          : (hasError ? AppColors.error : AppColors.darkGray),
                                    ),
                                  ),
                                ),
                                if (hasFile) ...[
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      controller.receiptImagePath.value = '';
                                      state.didChange('');
                                    },
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: AppColors.darkGray,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      state.errorText ?? '',
                      style: AppTextStyles.poppins(
                        fontSize: AppFontSizes.s12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
}
