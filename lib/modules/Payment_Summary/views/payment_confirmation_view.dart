import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_text_style.dart';
import '../../../utils/app_colors.dart';
import '../controllers/payment_confirmation_controller.dart';

class PaymentConfirmationView  extends GetView<PaymentConfirmationController> {
  const PaymentConfirmationView ({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
        boldText: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildSuccessHeader(),
                  const SizedBox(height: 8),
                  _buildOrderIdSection(),
                  const SizedBox(height: 30),
                  _buildPaymentProofCard(),
                  const SizedBox(height: 30),
                  _buildVerificationMessage(),
                  const SizedBox(height: 35),
                  _buildGoToOrdersButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== APP BAR ====================
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(
        color: AppColors.foreground,
      ),
      leading: IconButton(
        onPressed: () => Get.offAllNamed("/navigation", arguments: {"tab": 3}),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppColors.foreground,
        ),
      ),
      title: Text(
        "Payment Confirmation",
        style: AppTextStyles.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
      ),
    );
  }

  // ==================== SUCCESS HEADER ====================
  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.lightgreen,
        ),
        child: const Center(
          child: Icon(
            Icons.check,
            color: Color(0xFF16A34A),
            size: 34,
          ),
        ),
      ),
        const SizedBox(height: 12),
        Text(
          "Order Placed!",
          style: AppTextStyles.lora(
            fontSize: 25,
            fontWeight: FontWeight.w400,
            color: Colors.green,
          ),
        ),
      ],
    );
    }

  // ==================== ORDER ID SECTION ====================
  Widget _buildOrderIdSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: RichText(
        text: TextSpan(
          text: "Your Order ID is: ",
          style: AppTextStyles.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),          children: [
            TextSpan(
              text: "#${controller.orderId.value.split('-').first}",
              style: AppTextStyles.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PAYMENT PROOF CARD ====================
  Widget _buildPaymentProofCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: Colors.grey.shade700,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                "Payment Proof Submitted",
                style: AppTextStyles.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              // _buildStatusChip(),
            ],
          ),
          const Divider(height: 30),

          // Bank Name
          _buildDetailRow(
            label: "Bank Name:",
            value: controller.bankName.value,
          ),

          // UTR/Transaction ID
          _buildDetailRow(
            label: "UTR/Transaction ID:",
            value: controller.utrNumber.value,
          ),

          // Amount
          _buildDetailRow(
            label: "Amount:",
            value: "${controller.currency.value} ${controller.amount.value}",
          ),

          // Transfer Date
          _buildDetailRow(
            label: "Transfer Date:",
            value: controller.transferDate.value,
          ),
        ],
      ),
    );
  }

  // ==================== STATUS CHIP ====================
  Widget _buildStatusChip() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: controller.getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: controller.getStatusColor().withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            controller.getStatusIcon(),
            color: controller.getStatusColor(),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            controller.getStatusText(),
            style: AppTextStyles.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: controller.getStatusColor(),
            ),
          ),
        ],
      ),
    ));
  }

  // ==================== DETAIL ROW ====================
  Widget _buildDetailRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 14),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTextStyles.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),            ),
          ),
        ],
      ),
    );
  }

  // ==================== VERIFICATION MESSAGE ====================
  Widget _buildVerificationMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightgreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.accent,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Our team will verify the bank transfer details. Once verified, your order status will be updated, and we will notify you.",
              style: AppTextStyles.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== GO TO ORDERS BUTTON ====================
  Widget _buildGoToOrdersButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: controller.goToMyOrders,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          "Go to My Orders",
          style: AppTextStyles.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }


}