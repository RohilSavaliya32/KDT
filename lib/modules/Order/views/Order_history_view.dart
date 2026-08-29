import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/modules/fade_slide_in.dart';
import 'package:kdt/utils/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_text_style.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../../translations/Translation_key/translation_keys.dart';
import '../controllers/order_history_controller.dart';
import '../order_card.dart';
import '../order_empty_state.dart';

class OrderHistoryView extends GetView<OrderHistoryController> {
  const OrderHistoryView({super.key});

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
        body: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.background,
          onRefresh: controller.refreshOrders,
          child: Obx(() {
            // ======================================================
            // INITIAL LOADING
            // ======================================================

            if (controller.isLoading.value && controller.orders.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                ),
              );
            }

            // ======================================================
            // ERROR STATE
            // ======================================================

            if (controller.errorMessage.value.isNotEmpty && controller.orders.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 150,
                  child: FadeSlideIn(
                    duration: const Duration(milliseconds: 500),
                    slideOffset: 15,
                    child: OrderEmptyState(
                      title: controller.errorMessage.value,
                      subtitle: TranslationKeys.pullToRefreshAndTryAgain.tr,
                      onRetry: controller.refreshOrders,
                    ),
                  ),
                ),
              );
            }

            // ======================================================
            // EMPTY STATE
            // ======================================================

            if (controller.orders.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 150,
                  child: FadeSlideIn(
                    duration: const Duration(milliseconds: 500),
                    slideOffset: 15,
                    child: OrderEmptyState(
                      title: TranslationKeys.noOrdersFound.tr,
                      subtitle: TranslationKeys.orderHistoryWillAppear.tr,
                      onRetry: controller.refreshOrders,
                    ),
                  ),
                ),
              );
            }

            // ======================================================
            // ORDER LIST
            // ======================================================

            return ListView.separated(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: controller.orders.length + (controller.isMoreLoading.value ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, index) {
                // ==================================================
                // LOAD MORE LOADER
                // ==================================================

                if (index >= controller.orders.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                      ),
                    ),
                  );
                }

                // ==================================================
                // ORDER CARD
                // ==================================================

                final order = controller.orders[index];

                return OrderCard(
                  order: order,
                  shortOrderNo: controller.shortOrderNumber(
                    order.id,
                  ),
                  formatDate: controller.formatDate,
                  statusColor: controller.statusColor(
                    order.status,
                  ),
                  statusIcon: controller.statusIcon(
                    order.status,
                  ),
                  onViewDetails: () => controller.openOrderDetails(
                    order,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.foreground,
      surfaceTintColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppColors.foreground,
          size: 20,
        ),
        onPressed: () {
          AppNavigator.offAll(
            AppRoutes.navigation,
            arguments: {
              "tab": 4,
            },
          );
        },
        padding: const EdgeInsets.only(left: 12),
        splashRadius: 20,
      ),
      title: Text(
        "Order History",
        style: AppTextStyles.lora(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
      ),
    );
  }
}