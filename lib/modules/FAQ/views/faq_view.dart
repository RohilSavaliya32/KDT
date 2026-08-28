import 'package:kdt/modules/fade_slide_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../translations/Translation_key/translation_keys.dart';
import '../controllers/faq_controller.dart';

class FaqView extends GetView<FaqController> {
  const FaqView({super.key});

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
        body: SafeArea(
          child: FadeSlideIn(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;

                return Obx(
                      () =>
                  controller.faqs.isEmpty
                      ? const _EmptyState()
                      : _FaqList(
                    faqs: controller.faqs,
                    screenWidth: screenWidth,
                  ),
                );
              }),
          ),
        ),
      ),
    );
  }

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
        onPressed: () => Get.back(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppColors.foreground,
        ),
      ),
      title: Text(
        TranslationKeys.faqs.tr,
        style: AppTextStyles.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
        boldText: false,
      ),
      child: Center(
        child: Text(
          TranslationKeys.noFaqsAvailable.tr,
          style: AppTextStyles.poppins(
            fontSize: 16,
            color: AppColors.mutedForeground,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// FAQ LIST
// ============================================================

class _FaqList extends StatelessWidget {
  final List<Map<String, dynamic>> faqs;
  final double screenWidth;

  const _FaqList({
    required this.faqs,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final horizontalPadding =
    _getResponsiveHorizontalPadding(screenWidth);

    final verticalPadding =
    _getResponsiveVerticalPadding(screenWidth);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 760,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              ...faqs.map(
                    (faq) => _FaqItem(
                  question: faq['question'] ?? '',
                  answer: faq['answer'] ?? '',
                  screenWidth: screenWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getResponsiveHorizontalPadding(
      double width,
      ) {
    if (width < 360) return 12;
    if (width < 600) return 20;
    if (width < 900) return 30;
    return 40;
  }

  double _getResponsiveVerticalPadding(
      double width,
      ) {
    if (width < 360) return 12;
    if (width < 600) return 15;
    if (width < 900) return 20;
    return 25;
  }
}

// ============================================================
// FAQ ITEM
// ============================================================

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  final double screenWidth;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final questionSize =
    _getResponsiveQuestionFontSize(
      screenWidth,
    );

    final answerSize =
    _getResponsiveAnswerFontSize(
      screenWidth,
    );

    final horizontalPadding =
    _getResponsiveItemPadding(
      screenWidth,
    );

    final verticalPadding =
    _getResponsiveItemVerticalPadding(
      screenWidth,
    );

    final bottomMargin =
    _getResponsiveBottomMargin(
      screenWidth,
    );

    return Container(
      margin: EdgeInsets.only(
        bottom: bottomMargin,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
            AppColors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: AppColors.transparent,
          splashColor: AppColors.transparent,
          highlightColor: AppColors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          childrenPadding: EdgeInsets.only(
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: horizontalPadding + 4,
          ),
          collapsedIconColor: AppColors.accent,
          iconColor: AppColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            question,
            style: AppTextStyles.poppins(
              fontSize: questionSize,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
              height: 1.3,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 4,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  answer,
                  style: AppTextStyles.poppins(
                    fontSize: answerSize,
                    color: AppColors.mutedForeground,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getResponsiveQuestionFontSize(
      double width,
      ) {
    if (width < 360) return 14;
    if (width < 600) return 16;
    if (width < 900) return 17;
    return 19;
  }

  double _getResponsiveAnswerFontSize(
      double width,
      ) {
    if (width < 360) return 12;
    if (width < 600) return 14;
    if (width < 900) return 15;
    return 16;
  }

  double _getResponsiveItemPadding(
      double width,
      ) {
    if (width < 360) return 14;
    if (width < 600) return 18;
    if (width < 900) return 22;
    return 26;
  }

  double _getResponsiveItemVerticalPadding(
      double width,
      ) {
    if (width < 360) return 6;
    if (width < 600) return 8;
    if (width < 900) return 10;
    return 12;
  }

  double _getResponsiveBottomMargin(
      double width,
      ) {
    if (width < 360) return 10;
    if (width < 600) return 14;
    if (width < 900) return 16;
    return 18;
  }
}