import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/modules/Checkout/views/payment_method_section.dart';
import 'package:kdt/modules/Checkout/views/user_information_section.dart';
import 'package:kdt/modules/fade_slide_in.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../translations/Translation_key/translation_keys.dart';
import '../controllers/checkout_controller.dart';
import 'order_summary_section.dart';

class CheckoutView extends GetView<CheckoutController> {
  const CheckoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
        boldText: false,
      ),
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final isMobile = MediaQuery.of(Get.context!).size.width < 900;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.white,
      body: KeyboardDismisser(
        child: RefreshIndicator(
          onRefresh: controller.refreshPage,
          color: AppColors.primaryDark,
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: FadeSlideIn(
                        duration: const Duration(milliseconds: 500),
                        slideOffset: 15,
                        child: _buildContent(context, isMobile),
                      ),
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

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      toolbarHeight: 72,
      iconTheme: const IconThemeData(color: AppColors.primaryDark),
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.primaryDark),
        tooltip: 'Back',
      ),
      title: Text(
        TranslationKeys.checkout.tr,
        style: AppTextStyles.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isMobile) {
    return Obx(() {
      if (controller.isLoading.value && controller.savedAddresses.isEmpty) {
        return const SizedBox(
          height: 500,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return isMobile
          ? Column(
        children: [
          _buildFormContainer(context),
          const SizedBox(height: 20),
          _buildSummaryContainer(context),
        ],
      )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: _buildFormContainer(context)),
          const SizedBox(width: 28),
          Expanded(flex: 2, child: _buildSummaryContainer(context)),
        ],
      );
    });
  }

  Widget _buildFormContainer(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderGray),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const UserInformationSection(),
            const SizedBox(height: 14),
            const PaymentMethodSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderGray),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const OrderSummarySection(),
    );
  }
}

// ============================================================
// KEYBOARD DISMISSER
// ============================================================

class KeyboardDismisser extends StatelessWidget {
  final Widget child;
  const KeyboardDismisser({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}