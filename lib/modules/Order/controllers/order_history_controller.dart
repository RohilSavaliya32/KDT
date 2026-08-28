import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kdt/core/storage/api_constants.dart';

import '../../../core/storage/secure_storage.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../OrderModel.dart';
import '../views/order_history_view.dart' hide OrderDetailsView;
import '../views/order_details_view.dart';

class OrderHistoryController extends GetxController {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final RxBool isLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final Rxn<OrderModel> selectedOrder = Rxn<OrderModel>();

  @override
  void onInit() {
    super.onInit();
    fetchOrders(refresh: true);
  }

  Future<void> fetchOrders({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      orders.clear();
    }

    try {
      if (orders.isEmpty) {
        isLoading.value = true;
      } else {
        isMoreLoading.value = true;
      }

      errorMessage.value = '';

      final token = await SecureStorage.getToken();

      final response = await _dio.get(
        '/orders/myorders',
        queryParameters: {
          'page': currentPage.value,
        },
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      final raw = response.data;

      if (raw is Map<String, dynamic>) {
        final dataList = (raw['data'] as List? ?? [])
            .map(
              (e) => OrderModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
            .toList();

        orders.addAll(dataList);

        final meta = raw['meta'];
        if (meta is Map) {
          totalPages.value = _toInt(meta['totalPages'], fallback: 1);
        } else {
          totalPages.value = 1;
        }

        if (currentPage.value < totalPages.value) {
          currentPage.value++;
        }
      }
    } on DioException catch (e) {
      errorMessage.value = _extractDioMessage(e);
    } catch (_) {
      errorMessage.value = 'Order load nahi hua. Please try again.';
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    await fetchOrders(refresh: true);
  }

  Future<bool> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    try {
      final token = await SecureStorage.getToken();

      final response = await _dio.put(
        '/orders/$orderId/cancel',
        data: {
          if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
        },
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      final raw = response.data;
      OrderModel? updatedOrder;

      if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        if (data is Map) {
          updatedOrder = OrderModel.fromJson(Map<String, dynamic>.from(data));
        } else if (raw['id'] != null) {
          updatedOrder = OrderModel.fromJson(raw);
        }
      }

      final index = orders.indexWhere((o) => o.id == orderId);

      if (updatedOrder != null) {
        if (index != -1) {
          orders[index] = updatedOrder;
        }
        selectedOrder.value = updatedOrder;
      } else if (index != -1) {
        final localUpdated = orders[index].copyWith(
          status: 'Cancelled',
          cancellationReason: reason,
          cancelledAt: DateTime.now().toUtc().toIso8601String(),
          cancelledBy: 'USER',
          updatedAt: DateTime.now().toUtc().toIso8601String(),
        );
        orders[index] = localUpdated;
        selectedOrder.value = localUpdated;
      }

      await fetchOrders(refresh: true);
      return true;
    } on DioException catch (e) {
      errorMessage.value = _extractDioMessage(e);
      return false;
    } catch (_) {
      errorMessage.value = 'Cancel order failed. Please try again.';
      return false;
    }
  }

  void openOrderDetails(OrderModel order) {
    selectedOrder.value = order;
    AppNavigator.toWidget(
      OrderDetailsView(
        order: order,
        onViewDiamond: (OrderItemModel item) {
          final diamondId = item.id;

          if (diamondId.isEmpty) {
            Get.snackbar(
              'Error',
              'Diamond details not available',
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }
          AppNavigator.to("/diamonds-details", arguments: diamondId);
        },
      ),
    );
  }

  String shortOrderNumber(String id) {
    final clean = id.replaceAll('-', '').toUpperCase();
    return clean.length >= 8 ? clean.substring(0, 8) : clean;
  }

  String formatDate(String? value) {
    if (value == null || value.isEmpty) return '-';
    final dt = DateTime.parse(value).toLocal();
    return DateFormat('M/d/yyyy, h:mm:ss a').format(dt);
  }

  String formatCurrency(num? value) {
    final amount = (value ?? 0).toDouble();
    return '\$${NumberFormat('#,##0', 'en_US').format(amount)}';
  }

  Color statusColor(String? status) {
    final s = (status ?? '').toLowerCase().trim();

    if (s.contains('cancel')) {
      return const Color(0xFFE74C3C); // Red
    }

    if (s.contains('awaiting')) {
      return const Color(0xFFF39C12); // Orange
    }

    // Payment Processing (Blue)
    if (s.contains('payment processing')) {
      return const Color(0xFF2980B9);
    }

    // Processing (Purple)
    if (s == 'processing' || s.contains('processing')) {
      return const Color(0xFF8B5CF6);
    }

    if (s.contains('paid') ||
        s.contains('completed') ||
        s.contains('shipped') ||
        s.contains('delivered')) {
      return const Color(0xFF0F5B45); // Green
    }

    return const Color(0xFF7F8C8D); // Grey
  }

  IconData statusIcon(String? status) {
    final s = (status ?? '').toLowerCase();
    if (s.contains('cancel')) return Icons.cancel_outlined;
    if (s.contains('awaiting')) return Icons.access_time;
    if (s.contains('paid') || s.contains('completed')) {
      return Icons.check_circle_outline;
    }
    if (s.contains('shipped') || s.contains('delivered')) {
      return Icons.local_shipping_outlined;
    }
    return Icons.info_outline;
  }

  String _extractDioMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (e.message != null && e.message!.isNotEmpty) {
      return e.message!;
    }
    return 'Network error';
  }

  int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
