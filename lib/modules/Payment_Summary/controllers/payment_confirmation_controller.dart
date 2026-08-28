import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../../Order/OrderModel.dart';
import '../../Order/controllers/order_history_controller.dart';

class PaymentConfirmationController extends GetxController {
  // Order details
  final RxString orderId = ''.obs;
  final RxString bankName = ''.obs;
  final RxString utrNumber = ''.obs;
  final RxDouble amount = 0.0.obs;
  final RxString transferDate = ''.obs;
  final RxString currency = 'USD'.obs;
  final RxString status = 'pending'.obs;

  @override
  void onInit() {
    super.onInit();
    _getArguments();
  }

  void _getArguments() {
    final args = Get.arguments;
    if (args is Map) {
      orderId.value = args['orderId']?.toString() ?? '';
      bankName.value = args['bankName']?.toString() ?? '';
      utrNumber.value = args['utrNumber']?.toString() ?? '';
      final amountArg = args['amount'];
      if (amountArg is num) {
        amount.value = amountArg.toDouble();
      } else {
        amount.value = double.tryParse(amountArg?.toString() ?? '0') ?? 0.0;
      }
      transferDate.value = args['transferDate']?.toString() ?? '';
      currency.value = args['currency']?.toString() ?? 'USD';
      status.value = args['status']?.toString() ?? 'pending';
    }
  }

  // Navigate to My Orders
  void goToMyOrders() {
    // Navigate to orders tab using AppNavigator for loader
    AppNavigator.offAll("/navigation", arguments: {"tab": 3});

    // Optional: Update order history controller if needed
    try {
      if (Get.isRegistered<OrderHistoryController>()) {
        final orderHistoryController = Get.find<OrderHistoryController>();
        // You can fetch and update the order here if needed
        orderHistoryController.fetchOrders();
      }
    } catch (e) {
      debugPrint("Error updating orders: $e");
    }
  }

  // Get status color based on status
  Color getStatusColor() {
    switch (status.value.toLowerCase()) {
      case 'verified':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // Get status icon based on status
  IconData getStatusIcon() {
    switch (status.value.toLowerCase()) {
      case 'verified':
      case 'completed':
        return Icons.verified;
      case 'pending':
        return Icons.pending_actions;
      case 'failed':
      case 'rejected':
        return Icons.error_outline;
      default:
        return Icons.pending_actions;
    }
  }

  // Get status text
  String getStatusText() {
    switch (status.value.toLowerCase()) {
      case 'verified':
        return 'Verified';
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending Verification';
      case 'failed':
        return 'Failed';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending Verification';
    }
  }
}
