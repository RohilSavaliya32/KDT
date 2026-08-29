import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';
import 'package:file_picker/file_picker.dart';
import '../Payment_Summary/Payment_Api_Service.dart';
import 'controllers/order_history_controller.dart';
import 'OrderModel.dart';

class PaymentProofDialog extends StatefulWidget {
  final OrderModel order;
  const PaymentProofDialog({super.key, required this.order});

  @override
  State<PaymentProofDialog> createState() => _PaymentProofDialogState();
}

class _PaymentProofDialogState extends State<PaymentProofDialog> {
  final _formKey = GlobalKey<FormState>();
  final _utrController = TextEditingController();
  final _bankController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  String? _screenshotPath;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController.text = (widget.order.displayTotal ?? widget.order.total ?? 0).toString();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF005234),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() => _screenshotPath = result.files.single.path);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_screenshotPath == null) {
      Get.snackbar("Required", "Please upload a payment receipt screenshot", 
        backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.TOP);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiService = PaymentConfirmationApiService();
      
      await apiService.submitPaymentProof(
        orderId: widget.order.id,
        screenshotPath: _screenshotPath!,
        utrNumber: _utrController.text.trim(),
        bankName: _bankController.text.trim(),
        amount: _amountController.text.trim(),
        transferDate: _dateController.text.trim(),
      );

      Get.find<OrderHistoryController>().refreshOrders();
      Get.back();
      Get.snackbar("Success", "Payment proof submitted successfully", 
        backgroundColor: const Color(0xFF005234), colorText: Colors.white, snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar("Error", e.toString(), backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text("Submit Payment Proof", 
                        style: AppTextStyles.lora(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.foreground)),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: AppColors.mutedForeground),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Enter transaction details and upload a screenshot/receipt of your transfer.", 
                  style: AppTextStyles.poppins(fontSize: 14, color: AppColors.mutedForeground)),
                const SizedBox(height: 24),
                
                _buildFieldLabel("Transaction ID / UTR *"),
                _buildTextField(
                  controller: _utrController,
                  hint: "Enter UTR or Ref No.",
                  validator: (v) => (v == null || v.isEmpty) ? "UTR number is required" : null,
                ),
                const SizedBox(height: 16),
                
                _buildFieldLabel("Bank Name *"),
                _buildTextField(
                  controller: _bankController,
                  hint: "Enter Bank Name",
                  validator: (v) => (v == null || v.isEmpty) ? "Bank name is required" : null,
                ),
                const SizedBox(height: 16),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel("Amount *"),
                          _buildTextField(
                            controller: _amountController,
                            hint: "Amount",
                            keyboardType: TextInputType.number,
                            validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel("Transfer Date *"),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: AbsorbPointer(
                              child: _buildTextField(
                                controller: _dateController,
                                hint: "YYYY-MM-DD",
                                suffixIcon: const Icon(Icons.calendar_month_outlined, size: 20, color: Color(0xFF005234)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildFieldLabel("Payment Proof Screenshot *"),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFF9FAFB),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_upload_outlined, color: Color(0xFF005234), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _screenshotPath != null ? _screenshotPath!.split('/').last : "Choose file",
                            style: AppTextStyles.poppins(
                              fontSize: 14, 
                              color: _screenshotPath != null ? AppColors.foreground : AppColors.mutedForeground
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_screenshotPath != null)
                          const Icon(Icons.check_circle, color: Colors.green, size: 18),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005234),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("Submit Payment Proof", 
                          style: AppTextStyles.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppTextStyles.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.foreground)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: AppTextStyles.poppins(fontSize: 14, color: AppColors.foreground),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.poppins(fontSize: 14, color: AppColors.mutedForeground),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF005234), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent)),
      ),
    );
  }
}
