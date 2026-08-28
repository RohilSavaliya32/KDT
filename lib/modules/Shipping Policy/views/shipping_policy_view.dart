import 'package:kdt/modules/fade_slide_in.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_text_style.dart';

import '../../../utils/app_colors.dart';
import '../../translations/Translation_key/translation_keys.dart';
import '../controllers/shipping_policy_controller.dart';

class ShippingPolicyView extends GetView<ShippingPolicyController> {
  const ShippingPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: Scaffold(
        backgroundColor: AppColors.appBack,
        appBar: AppBar(
          backgroundColor: AppColors.appBack,
          surfaceTintColor: AppColors.appBack,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(
            color: AppColors.foreground,
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.foreground,
              size: 20,
            ),
            onPressed: Get.back,
          ),
          title: Text(
            TranslationKeys.shippingPolicy.tr,
            style: AppTextStyles.poppins(
              fontSize: AppFontSizes.s18,
              fontWeight: FontWeight.w500,
              color: AppColors.foreground,
            ),
          ),
        ),
        body: SafeArea(
          child: FadeSlideIn(
            child: Obx(() {
              if (controller.settingsController.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Html(
                data: controller.shippingHtml,
                style: {
                  "body": Style(
                    color: AppColors.foreground,
                    fontSize: FontSize(AppFontSizes.s14),
                    lineHeight: LineHeight(1.6),
                  ),
                  "h1": Style(
                    color: AppColors.foreground,
                  ),
                  "h2": Style(
                    color: AppColors.foreground,
                  ),
                  "h3": Style(
                    color: AppColors.foreground,
                  ),
                  "p": Style(
                    color: AppColors.textSecondary,
                  ),
                  "li": Style(
                    color: AppColors.textSecondary,
                  ),
                  "a": Style(
                    color: AppColors.accent,
                  ),
                },
              ),
            );
          }),
        ),
      ),
    ),
    );
  }
}
