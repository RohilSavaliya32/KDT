import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kdt/modules/fade_slide_in.dart';
import 'package:kdt/widgets/kdt_shimmer.dart';

import '../../../data/Setting_Cont.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/AppointmentDialog.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../KDTDiamondLoader.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../../Profile & Settings/currency_price_text.dart';
import '../../Review/Model/Review_Model.dart';
import '../../Review/Review_Controller/Review_Controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../home/widgets/feature_row.dart';
import '../../login/views/login_view.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../translations/Translation_key/translation_keys.dart';
import '../controllers/DiamondDetailView_controller.dart';

class DiamondDetailView extends StatefulWidget {
  const DiamondDetailView({super.key});

  @override
  State<DiamondDetailView> createState() => _DiamondDetailViewState();
}

class _DiamondDetailViewState extends State<DiamondDetailView> {
  late final DiamondDetailViewController controller;
  String? _initialId;

  @override
  void initState() {
    super.initState();

    _initialId = _extractIdFromArgs(Get.arguments);
    controller = Get.find<DiamondDetailViewController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        final reviewController = Get.find<ReviewController>();
        final authController = Get.find<AuthController>();

        reviewController.setCurrentUserId(
          authController.userId ?? '',
        );
      } catch (_) {}
    });
  }

  String? _extractIdFromArgs(dynamic arguments) {
    if (arguments is String) return arguments;
    if (arguments is Map) {
      final value = arguments['id'] ?? arguments['diamondId'];
      return value?.toString();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: _buildAppBar(context),
        body: _buildBody(context),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.foreground),
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            Get.back();
          } else {
            AppNavigator.offAll(AppRoutes.navigation);
          }
        },
      ),
      title: Text(
        TranslationKeys.diamondDetails.tr,
        style: AppTextStyles.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
      ),
      centerTitle: true,
      actions: [
        Obx(
          () => IconButton(
            icon: Icon(
              controller.isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: controller.isWishlisted
                  ? AppColors.accent
                  : AppColors.foreground,
            ),
            onPressed: controller.toggleWishlist,
          ),
        ),
        Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(
                Icons.share_outlined,
                color: AppColors.foreground,
              ),
              onPressed: () {
                final renderBox = context.findRenderObject() as RenderBox?;
                final sharePositionOrigin = renderBox != null
                    ? renderBox.localToGlobal(Offset.zero) & renderBox.size
                    : null;

                controller.shareDiamond(sharePositionOrigin);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: DiamondLoader());
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return _buildErrorView(context);
      }

      if (controller.diamond.value == null) {
        return Center(
          child: Text(
            TranslationKeys.noDiamondDataFound.tr,
            style: AppTextStyles.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.darkGray,
            ),
          ),
        );
      }

      return FadeSlideIn(
        key: ValueKey(controller.diamond.value?.id ?? 'body'),
        duration: const Duration(milliseconds: 500),
        slideOffset: 15,
        child: _DiamondDetailBody(
          controller: controller,
          initialId: _initialId,
        ),
      );
    });
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: AppTextStyles.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                final id = Get.arguments is String
                    ? Get.arguments as String
                    : (Get.arguments is Map
                        ? (Get.arguments['id'] ?? Get.arguments['diamondId'])
                            ?.toString()
                        : null);
                if (id != null && id.isNotEmpty) {
                  controller.loadDiamond(id);
                }
              },
              child: Text(
                TranslationKeys.tryAgain.tr,
                style: AppTextStyles.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiamondDetailBody extends StatelessWidget {
  const _DiamondDetailBody({
    required this.controller,
    this.initialId,
  });

  final DiamondDetailViewController controller;
  final String? initialId;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: Obx(() {
        final diamond = controller.diamond.value;
        if (diamond == null) return const SizedBox.shrink();

        final images = controller.images;

        final screenSize = MediaQuery.of(context).size;
        final imageBoxHeight = (screenSize.width * 0.6).clamp(240.0, 360.0);

        final reviewController = Get.find<ReviewController>();
        final authController = Get.find<AuthController>();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(
                context,
                images,
                imageBoxHeight,
              ),
              const SizedBox(height: 24),
              _buildHeaderSection(context, diamond, reviewController),
              const SizedBox(height: 20),
              _buildSpecSection(context, diamond),
              const SizedBox(height: 20),
              _buildCertificateSection(context, diamond),
              const SizedBox(height: 20),
              _buildAddToCartButton(context),
              const SizedBox(height: 16),
              _buildContactSection(context),
              const SizedBox(height: 24),
              const FeatureRow(),
              const SizedBox(height: 24),
              _SpecTabsSection(
                diamond: diamond,
                controller: controller,
                reviewController: reviewController,
                authController: authController,
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildImageSection(
      BuildContext context, List<String> images, double imageBoxHeight) {
    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: imageBoxHeight,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: AppColors.lightGray.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: images.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Image.asset('assets/shapes/logo.png',
                              fit: BoxFit.contain),
                        )
                      : PageView.builder(
                          key: const PageStorageKey("diamond_images"),
                          controller: controller.imagePageController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: images.length,
                          onPageChanged: (index) {
                            if (controller.imagePageController.page ==
                                index.toDouble()) {
                              controller.selectedImageIndex.value = index;
                            }
                          },
                          itemBuilder: (context, index) {
                            return _buildDiamondImage(
                              images[index],
                              key: ValueKey(images[index]),
                              useHero: index == 0,
                            );
                          },
                        ),
                ),
              ),
            ),
            if (controller.diamond.value?.isLabGrown ?? false)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Lab-Grown",
                    style: AppTextStyles.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (images.length > 1)
          Obx(() {
            final safeIndex = controller.selectedImageIndex.value
                .clamp(0, images.length - 1);

            return SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final isSelected = safeIndex == index;
                  return GestureDetector(
                    onTap: () async {
                      if (controller.selectedImageIndex.value == index) return;

                      controller.selectedImageIndex.value = index;

                      await controller.imagePageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeInOutCubic,
                      );
                    },
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 10),
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.borderGray,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: _buildDiamondImage(images[index],
                            key: ValueKey('thumb_${index}_${images[index]}'),
                            useHero: false),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
      ],
    );
  }

  Widget _buildHeaderSection(
      BuildContext context, dynamic diamond, ReviewController reviewController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.diamondTitle,
                    style: AppTextStyles.lora(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    controller.subtitleText,
                    style: AppTextStyles.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.darkGray,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CurrencyPriceText(
                  usdAmount: diamond.price.toDouble(),
                  style: AppTextStyles.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                  ),
                ),
                CurrencyPriceText(
                  usdAmount: diamond.carat == 0
                      ? 0
                      : diamond.price.toDouble() / diamond.carat.toDouble(),
                  suffix: "/ct",
                  style: AppTextStyles.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          final reviews = reviewController.reviews;
          final reviewCount = reviews.length;

          if (reviewCount == 0) {
            return const SizedBox.shrink();
          }

          final avgRating =
              reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                  reviewCount;

          return Row(
            children: [
              ...List.generate(5, (index) {
                final starValue = index + 1;
                IconData icon;
                if (avgRating >= starValue) {
                  icon = Icons.star;
                } else if (avgRating >= starValue - 0.5) {
                  icon = Icons.star_half;
                } else {
                  icon = Icons.star_border;
                }
                return Icon(icon, size: 18, color: AppColors.starColor);
              }),
              const SizedBox(width: 8),
              Text(
                avgRating.toStringAsFixed(1),
                style: AppTextStyles.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '($reviewCount)',
                style: AppTextStyles.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSpecSection(BuildContext context, dynamic diamond) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSpecItem(
                context,
                "CTS",
                "${diamond.carat} ct",
              ),
              _buildSpecItem(
                context,
                TranslationKeys.color.tr.toUpperCase(),
                diamond.color,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSpecItem(
                context,
                TranslationKeys.clarity.tr.toUpperCase(),
                diamond.clarity,
              ),
              _buildSpecItem(
                context,
                TranslationKeys.cutGrade.tr.toUpperCase(),
                diamond.cut,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateSection(BuildContext context, dynamic diamond) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.workspace_premium_outlined,
                size: 30, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diamond.certification.isNotEmpty
                      ? diamond.certification
                      : TranslationKeys.certifiedDiamond.tr,
                  style: AppTextStyles.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${TranslationKeys.report.tr} #${diamond.certNumber}',
                  style: AppTextStyles.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: controller.viewCertificate,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderGray),
                      borderRadius: BorderRadius.circular(4),
                      color: AppColors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_outlined,
                            color: AppColors.foreground, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          TranslationKeys.viewCertificate.tr,
                          style: AppTextStyles.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Obx(() {
        final diamond = controller.diamond.value;

        final isOutOfStock =
            diamond == null || diamond.stockStatus != "In Stock";

        return ElevatedButton(
          onPressed: isOutOfStock || controller.alreadyInCart
              ? null
              : controller.addToCart,
          style: ElevatedButton.styleFrom(
            backgroundColor: isOutOfStock
                ? AppColors.disabledGray
                : controller.alreadyInCart
                    ? AppColors.disabledGray
                    : AppColors.primaryDark,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Text(
            isOutOfStock
                ? "Out of Stock"
                : controller.alreadyInCart
                    ? TranslationKeys.addedToCart.tr
                    : TranslationKeys.addToCart.tr,
            style: AppTextStyles.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _contactBox(
                context: context,
                title: TranslationKeys.whatsapp.tr,
                onTap: controller.openWhatsApp,
                iconWidget: SvgPicture.asset(
                  "assets/icon/2.svg",
                  height: 22,
                  width: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _contactBox(
                context: context,
                title: TranslationKeys.kakaoTalk.tr,
                onTap: () {
                  final settings = Get.find<SettingsDataController>().contact;
                  if (settings != null) {
                    controller.openKakao(settings);
                  }
                },
                iconWidget: SvgPicture.asset(
                  "assets/icon/1.svg",
                  height: 22,
                  width: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _contactBox(
                context: context,
                title: TranslationKeys.wechat.tr,
                onTap: () {
                  final settings = Get.find<SettingsDataController>().contact;
                  if (settings != null) {
                    controller.openWechat(settings);
                  }
                },
                iconWidget: SvgPicture.asset(
                  "assets/icon/3.svg",
                  height: 22,
                  width: 22,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildPhoneCallSection(context),
        const SizedBox(height: 12),
        _buildAppointmentButton(context),
      ],
    );
  }

  Widget _buildPhoneCallSection(BuildContext context) {
    return InkWell(
      onTap: controller.makePhoneCall,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderGray),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.phone_outlined,
              size: 20,
              color: AppColors.foreground,
            ),
            const SizedBox(width: 8),
            Text(
              "${TranslationKeys.callUs.tr}:",
              style: AppTextStyles.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Obx(() {
                if (controller.phoneNumbers.isEmpty) {
                  return Text(
                    TranslationKeys.noNumber.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  );
                }

                final index = controller.selectedNumber.value.clamp(
                  0,
                  controller.phoneNumbers.length - 1,
                );

                return Text(
                  controller.phoneNumbers[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                );
              }),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: controller.changeNumber,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.swap_horiz,
                  size: 20,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentButton(BuildContext context) {
    return InkWell(
      onTap: () =>
          showDialog(context: context, builder: (_) => AppointmentDialog()),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month_outlined,
                color: AppColors.white, size: 20),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                TranslationKeys.bookInStoreAppointment.tr,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiamondImage(String src, {Key? key, bool useHero = false}) {
    final diamondId = controller.diamond.value?.id ?? '';

    Widget image;
    if (src.startsWith('assets/')) {
      image = Image.asset(
        src,
        key: key,
        fit: BoxFit.fill,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: src,
        key: key,
        fit: BoxFit.fill,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => const KdtShimmer(
          child: KdtSkeleton(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 0,
          ),
        ),
        errorWidget: (context, url, error) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Image.asset('assets/shapes/logo.png', fit: BoxFit.contain),
        ),
      );
    }

    // Fix: Only apply Hero if diamondId matches the initialId intended for this page.
    // This prevents Hero tag collisions when multiple DiamondDetailViews share a controller (GetX lazyPut).
    if (useHero && diamondId.isNotEmpty && (initialId == null || diamondId == initialId)) {
      return Hero(
        tag: 'diamond_$diamondId',
        child: image,
      );
    }
    
    return image;
  }

  Widget _buildSpecItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

// Helper Widgets
Widget _contactBox({
  required BuildContext context,
  Widget? iconWidget,
  required String title,
  VoidCallback? onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 82,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget ?? const SizedBox(),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.foreground,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _trustBadgeItem(BuildContext context, IconData icon, String label) {
  return Column(
    children: [
      Icon(icon, size: 26, color: AppColors.iconGray),
      const SizedBox(height: 8),
      Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.iconGray,
        ),
      ),
    ],
  );
}

class _SpecTabsSection extends StatefulWidget {
  const _SpecTabsSection({
    required this.diamond,
    required this.controller,
    required this.reviewController,
    required this.authController,
  });

  final dynamic diamond;
  final DiamondDetailViewController controller;
  final ReviewController reviewController;
  final AuthController authController;

  @override
  State<_SpecTabsSection> createState() => _SpecTabsSectionState();
}

class _SpecTabsSectionState extends State<_SpecTabsSection> {
  int _selectedTab = 0;
  bool _showReviewEditor = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTabBar(context),
        const Divider(height: 1),
        const SizedBox(height: 20),
        _buildTabContent(context),
        const SizedBox(height: 32),
        _buildReviewsTab(context),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _tabButton(context, 0, TranslationKeys.fullSpecifications.tr),
          _tabButton(context, 1, TranslationKeys.certification.tr),
          _tabButton(context, 2, TranslationKeys.shippingAndReturns.tr),
        ],
      ),
    );
  }

  Widget _tabButton(BuildContext context, int index, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        margin: const EdgeInsets.only(right: 22),
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primaryDark : AppColors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.poppins(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected ? AppColors.textPrimary : AppColors.darkGray,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    switch (_selectedTab) {
      case 0:
        return _buildFullSpecifications(context);
      case 1:
        return _buildCertificationTab(context);
      case 2:
        return _buildShippingReturnsTab(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFullSpecifications(BuildContext context) {
    final diamond = widget.diamond;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.diamondDetails.tr,
          style: AppTextStyles.lora(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 6),
        _buildDetailRow(context, TranslationKeys.sku.tr, diamond.sku),
        _buildDetailRow(
          context,
          TranslationKeys.shape.tr,
          diamond.shape.isNotEmpty
              ? '${diamond.shape[0].toUpperCase()}${diamond.shape.substring(1)}'
              : '',
        ),
        _buildDetailRow(
            context, TranslationKeys.caratWeight.tr, '${diamond.carat.toInt()} ct'),
        _buildDetailRow(context, TranslationKeys.color.tr, diamond.color),
        _buildDetailRow(context, TranslationKeys.clarity.tr, diamond.clarity),
        _buildDetailRow(context, TranslationKeys.cutGrade.tr, diamond.cut),
        const SizedBox(height: 20),
        Text(
          TranslationKeys.additionalDetails.tr,
          style: AppTextStyles.lora(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 6),
        _buildDetailRow(
          context,
          TranslationKeys.measurements.tr,
          '${diamond.measurements.depth.toInt()} x ${diamond.measurements.width.toInt()} x ${diamond.measurements.length.toInt()} mm',
        ),
        _buildDetailRow(context, TranslationKeys.depthPercent.tr,
            '${diamond.depthPercent.toInt()}%'),
        _buildDetailRow(context, TranslationKeys.tablePercent.tr,
            '${diamond.tablePercent.toInt()}%'),
        _buildDetailRow(context, TranslationKeys.polish.tr, diamond.polish),
        _buildDetailRow(context, TranslationKeys.symmetry.tr, diamond.symmetry),
        _buildDetailRow(
            context, TranslationKeys.fluorescence.tr, diamond.fluorescence),
      ],
    );
  }

  Widget _buildCertificationTab(BuildContext context) {
    final diamond = widget.diamond;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.workspace_premium_outlined,
                size: 30, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TranslationKeys.giaCertificate.tr,
                  style: AppTextStyles.lora(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  TranslationKeys.certificationDescription.tr,
                  style: AppTextStyles.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${TranslationKeys.report.tr} #${diamond.certNumber}',
                  style: AppTextStyles.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: widget.controller.viewCertificate,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderGray),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_outlined,
                            size: 18, color: AppColors.foreground),
                        const SizedBox(width: 8),
                        Text(
                          TranslationKeys.viewCertificate.tr,
                          style: AppTextStyles.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingReturnsTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.freeInsuredShipping.tr,
          style: AppTextStyles.lora(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          TranslationKeys.shippingDescription.tr,
          style: AppTextStyles.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          TranslationKeys.dayReturnsTitle.tr,
          style: AppTextStyles.lora(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          TranslationKeys.returnsDescription.tr,
          style: AppTextStyles.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          TranslationKeys.securePackaging.tr,
          style: AppTextStyles.lora(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          TranslationKeys.packagingDescription.tr,
          style: AppTextStyles.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTab(BuildContext context) {
    final diamondId = widget.diamond.id.toString();
    final reviewController = widget.reviewController;
    final authController = widget.authController;

    return Obx(() {
      final isLoggedIn = authController.isLoggedIn.value;
      final isEditing = reviewController.isEditing;
      final currentUserId = authController.userId ?? '';
      final hasUserReview =
          reviewController.reviews.any((r) => r.userId == currentUserId);
      final myReview = reviewController.myReview;
      final reviewCount = reviewController.reviews.length;

      final reviewsToShow = (isEditing && myReview != null)
          ? reviewController.reviews
              .where((r) => r.id.toString() != myReview.id.toString())
              .toList()
          : reviewController.reviews;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${TranslationKeys.customerReviews.tr} ',
                        style: AppTextStyles.lora(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: '($reviewCount)',
                        style: AppTextStyles.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  if (!isLoggedIn) {
                    showLoginModalDialog(context);
                    return;
                  }

                  if (!_showReviewEditor &&
                      !isEditing &&
                      hasUserReview &&
                      myReview != null) {
                    reviewController.startEditReview(myReview);
                  }

                  setState(() {
                    _showReviewEditor = !_showReviewEditor;
                    if (!_showReviewEditor && isEditing) {
                      reviewController.cancelEdit();
                    }
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderGray),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: Text(
                  (_showReviewEditor || isEditing)
                      ? TranslationKeys.cancel.tr
                      : (hasUserReview
                          ? TranslationKeys.editYourReview.tr
                          : TranslationKeys.writeAReview.tr),
                  style: AppTextStyles.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_showReviewEditor || isEditing) ...[
            _buildReviewEditor(
              context: context,
              reviewController: reviewController,
              diamondId: diamondId,
              title: isEditing
                  ? TranslationKeys.editReview.tr
                  : TranslationKeys.yourRating.tr,
              buttonText: isEditing
                  ? TranslationKeys.updateReview.tr
                  : TranslationKeys.submitReview.tr,
            ),
            const SizedBox(height: 20),
          ],
          if (reviewController.isLoading.value)
            const Center(child: CircularProgressIndicator())
          else if (reviewsToShow.isEmpty && !isEditing && !_showReviewEditor)
            _buildEmptyReviewsView(context)
          else
            Column(
                children: reviewsToShow
                    .map((review) => _buildReviewItem(context, review))
                    .toList()),
        ],
      );
    });
  }

  Widget _buildEmptyReviewsView(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            TranslationKeys.noReviewsYet.tr,
            style: AppTextStyles.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            TranslationKeys.beTheFirstToReview.tr,
            textAlign: TextAlign.center,
            style: AppTextStyles.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(BuildContext context, ReviewModel review) {
    final reviewerName = (review.user?.name ?? '').trim().isNotEmpty
        ? review.user!.name.trim()
        : 'Anonymous';
    final initial =
        reviewerName.isNotEmpty ? reviewerName[0].toUpperCase() : 'A';
    final profileImageUrl = review.user?.image ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.borderGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.lightGray,
                backgroundImage: profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: profileImageUrl.isEmpty
                    ? Text(
                        initial,
                        style: AppTextStyles.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewerName,
                      style: AppTextStyles.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.createdAt != null
                          ? DateFormat('MMM dd, yyyy').format(review.createdAt!)
                          : '',
                      style: AppTextStyles.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final starValue = index + 1.0;
              IconData icon;

              if (review.rating >= starValue) {
                icon = Icons.star;
              } else if (review.rating >= starValue - 0.5) {
                icon = Icons.star_half;
              } else {
                icon = Icons.star_border;
              }

              return Icon(
                icon,
                size: 18,
                color: AppColors.starColor,
              );
            }),
          ),
          if (review.comment.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: AppTextStyles.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: AppTextStyles.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.darkGray,
              ),
            ),
          ),
          Text(
            ':',
            style: AppTextStyles.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewEditor({
    required BuildContext context,
    required ReviewController reviewController,
    required String diamondId,
    required String title,
    required String buttonText,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.lightGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Write a review",
            style: AppTextStyles.lora(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Rating",
            style: AppTextStyles.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final rating = reviewController.selectedRating.value;
            return Row(
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return GestureDetector(
                  onTap: () {
                    reviewController.selectedRating.value = starIndex.toDouble();
                  },
                  child: Icon(
                    rating >= starIndex ? Icons.star : Icons.star_border,
                    color: AppColors.starColor,
                    size: 32,
                  ),
                );
              }),
            );
          }),
          const SizedBox(height: 20),
          Text(
            "Review (Optional)",
            style: AppTextStyles.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: reviewController.commentController,
            maxLines: 4,
            style: AppTextStyles.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.foreground,
            ),
            cursorColor: AppColors.accent,
            decoration: InputDecoration(
              hintText: "What did you like or dislike?",
              hintStyle: AppTextStyles.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.darkGray,
              ),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  reviewController.cancelEdit();
                  setState(() => _showReviewEditor = false);
                },
                child: Text(
                  TranslationKeys.cancel.tr,
                  style: AppTextStyles.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(() {
                final isSubmitting = reviewController.isSubmitting.value;
                return ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final success = await reviewController.submitReview(diamondId);
                          if (success) {
                            setState(() => _showReviewEditor = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.foreground,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          "Submit",
                          style: AppTextStyles.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}