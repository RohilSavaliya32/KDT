import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';
import '../../data/Setting_Cont.dart';

class BankDetailsDialog extends StatelessWidget {
  const BankDetailsDialog({super.key});

  SettingsDataController get _settingsController => Get.find<SettingsDataController>();

  String _safeValue(String value) => value.trim().isNotEmpty ? value.trim() : 'N/A';

  @override
  Widget build(BuildContext context) {
    final bankName = _safeValue(_settingsController.getBankName());
    final accountName = _safeValue(_settingsController.getAccountName());
    final accountNumber = _safeValue(_settingsController.getAccountNumber());
    final routingNumber = _safeValue(_settingsController.getRoutingNumber());
    final swiftCode = _safeValue(_settingsController.getSwiftCode());

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                Text(
                  "Bank Transfer Details",
                  style: AppTextStyles.lora(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.foreground),
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
            Text(
              "Please transfer the total amount to our bank account and upload the receipt screenshot.",
              textAlign: TextAlign.center,
              style: AppTextStyles.poppins(fontSize: 14, color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildDetailRow("Bank Name", bankName, isLast: false),
                  _buildDetailRow("Account Name", accountName, isLast: false),
                  _buildDetailRow("Account Number", accountNumber, isLast: false),
                  _buildDetailRow("Routing Number", routingNumber, isLast: false),
                  _buildDetailRow("SWIFT Code", swiftCode, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005234),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Close", 
                  style: AppTextStyles.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTextStyles.poppins(fontSize: 14, color: AppColors.mutedForeground, fontWeight: FontWeight.w400),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.poppins(fontSize: 14, color: AppColors.foreground, fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
