import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_text_style.dart';

import 'package:kdt/widgets/kdt_shimmer.dart';
import '../../../utils/app_colors.dart';
import '../../Client_Review/widgets/testimonials_widget.dart';
import '../../KDTDiamondLoader.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../../daimond_card/controllers/daimond_card_controller.dart';
import '../../daimond_card/views/daimond_card_view.dart';
import '../../translations/Translation_key/translation_keys.dart';
import '../controllers/home_controller.dart';
import '../widgets/Best_Collection.dart';
import '../widgets/Collection.dart';
import '../widgets/Reels.dart';
import '../widgets/banner_widget.dart';
import '../widgets/collection_banner.dart';
import '../widgets/consultation_card.dart';
import '../widgets/feature_row.dart';
import '../widgets/shape_grid.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: Scaffold(
        backgroundColor: AppColors.app_back,
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value && controller.bestSellerDiamonds.isEmpty) {
              return _HomeShimmer();
            }

            return RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  controller.refreshHomeData(),
                  Get.find<DiamondCardController>().refreshDiamonds(),
                ]);
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final vm = _ViewModel(constraints.maxWidth);

                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                    // ---------------------------------------------------------
                    // BANNER
                    // ---------------------------------------------------------
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FadeSlideIn(
                          delay: const Duration(milliseconds: 0),
                          slideOffset: 18,
                          child: Column(
                            children: [
                              const BannerWidget(),
                              SizedBox(height: vm.sectionSpacing),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ---------------------------------------------------------
                    // FEATURE ROW
                    // ---------------------------------------------------------
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FadeSlideIn(
                          delay: const Duration(milliseconds: 80),
                          slideOffset: 18,
                          child: Column(
                            children: [
                              const FeatureRow(),
                              SizedBox(height: vm.sectionSpacing),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ---------------------------------------------------------
                    // SHAPE GRID
                    // ---------------------------------------------------------
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FadeSlideIn(
                          delay: const Duration(milliseconds: 160),
                          slideOffset: 18,
                          child: Column(
                            children: [
                              ShapeGrid(),
                              SizedBox(height: vm.sectionSpacing),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // ---------------------------------------------------------
                    // CollectionBanner
                    // ---------------------------------------------------------
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FadeSlideIn(
                          delay: const Duration(milliseconds: 160),
                          slideOffset: 18,
                          child: Column(
                            children: [
                              CollectionBanner(),
                              SizedBox(height: vm.sectionSpacing),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ---------------------------------------------------------
                    // ConsultationCard
                    // ---------------------------------------------------------
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FadeSlideIn(
                          delay: const Duration(milliseconds: 160),
                          slideOffset: 18,
                          child: Column(
                            children: [
                              ConsultationCard(),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ---------------------------------------------------------
                    // COLLECTIONS
                    // ---------------------------------------------------------
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FadeSlideIn(
                          delay: const Duration(milliseconds: 240),
                          slideOffset: 18,
                          child: Column(
                            children: [
                              CollectionsSection(),
                              SizedBox(
                                height: vm.sectionSpacing * 1.5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ---------------------------------------------------------
                    // BEST SELLERS
                    // ---------------------------------------------------------
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FadeSlideIn(
                          delay: const Duration(milliseconds: 320),
                          slideOffset: 18,
                          child: Column(
                            children: [
                              _buildBestSellersSection(vm),
                              SizedBox(
                                height: vm.sectionSpacing * 1.5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ---------------------------------------------------------
                    // COLLECTION BANNER / COLLECTION
                    // ---------------------------------------------------------
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FadeSlideIn(
                          delay: const Duration(milliseconds: 400),
                          slideOffset: 18,
                          child: Column(
                            children: [
                              const Collection(),
                              SizedBox(
                                height: vm.sectionSpacing * 1.2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ---------------------------------------------------------
                    // FEATURED DIAMONDS
                    // ---------------------------------------------------------
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FadeSlideIn(
                          delay: const Duration(milliseconds: 480),
                          slideOffset: 18,
                          child: Column(
                            children: [
                              _buildFeaturedDiamondsSection(vm),
                              SizedBox(
                                height: vm.sectionSpacing,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ---------------------------------------------------------
                    // REELS
                    // ---------------------------------------------------------
                    // SliverToBoxAdapter(
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 16),
                    //     child: FadeSlideIn(
                    //       delay: const Duration(milliseconds: 560),
                    //       slideOffset: 18,
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Text(
                    //             "EXPLORE OUR PIECES",
                    //             style: AppTextStyles.poppins(
                    //               color: AppColors.accent,
                    //               letterSpacing: 4,
                    //               fontSize: vm.labelSize,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //           ),
                    //           SizedBox(
                    //             height: vm.labelSpacing,
                    //           ),
                    //           Text(
                    //             "Watch Our Reels",
                    //             style: AppTextStyles.lora(
                    //               fontSize: vm.titleSize,
                    //               fontWeight: FontWeight.w500,
                    //               color: AppColors.foreground,
                    //             ),
                    //           ),
                    //           const SizedBox(height: 16),
                    //           const SizedBox(
                    //             height: 250,
                    //             child: WhatmoreReelsView(),
                    //           ),
                    //           SizedBox(
                    //             height: vm.sectionSpacing,
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),

                    // ---------------------------------------------------------
                    // TESTIMONIALS
                    // ---------------------------------------------------------
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FadeSlideIn(
                          delay: const Duration(milliseconds: 640),
                          slideOffset: 18,
                          child: const TestimonialsWidget(),
                        ),
                      ),
                    ),

                    // ---------------------------------------------------------
                    // BOTTOM SPACING
                    // ---------------------------------------------------------
                    SliverToBoxAdapter(
                      child: FadeSlideIn(
                        delay: const Duration(milliseconds: 700),
                        slideOffset: 10,
                        duration: const Duration(milliseconds: 500),
                        child: SizedBox(
                          height: vm.sectionSpacing,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }),
      ),
      ));
  }

  Widget _buildBestSellersSection(_ViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "OUR MOST LOVED DIAMONDS",
              style: AppTextStyles.poppins(
                color: AppColors.accent,
                letterSpacing: 4,
                fontSize: vm.labelSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              height: vm.labelSpacing,
            ),
            Text(
              "Best Sellers",
              style: TextStyle(
                fontSize: vm.titleSize,
                fontWeight: FontWeight.w400,
                color: AppColors.foreground,
              ),
            ),
          ],
        ),
        SizedBox(
          height: vm.cardSpacing,
        ),
        Obx(() {
          if (controller.bestSellerDiamonds.isEmpty &&
              controller.isLoading.value) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: DiamondLoader(size: 50),
              ),
            );
          }

          return DiamondCardView(
            isEmbedded: true,
            limit: 4,
            diamonds: controller.bestSellerDiamonds,
          );
        }),
        const SizedBox(height: 20),
        Center(
          child: OutlinedButton(
            onPressed: () {
              AppNavigator.to(
                "/navigation",
                arguments: {
                  "tab": 2,
                },
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              side: const BorderSide(
                color: AppColors.border,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              "VIEW ALL BEST SELLERS",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedDiamondsSection(_ViewModel vm) {
    final diamondController =
    Get.find<DiamondCardController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TranslationKeys.handSelected.tr,
                    style: AppTextStyles.poppins(
                      color: AppColors.accent,
                      letterSpacing: 4,
                      fontSize: vm.labelSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: vm.labelSpacing,
                  ),
                  Text(
                    TranslationKeys.featuredDiamonds.tr,
                    style: AppTextStyles.lora(
                      fontSize: vm.titleSize,
                      fontWeight: FontWeight.w500,
                      color: AppColors.foreground,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildViewAllButton(vm),
          ],
        ),
        SizedBox(
          height: vm.cardSpacing,
        ),
        Obx(() {
          if (diamondController.diamonds.isEmpty &&
              diamondController.isLoading.value) {
            return const SizedBox(
              height: 200,
              child: Center(
                child: DiamondLoader(size: 50),
              ),
            );
          }

          return const DiamondCardView(
            isEmbedded: true,
            enableLoadMore: false,
            limit: 4,
          );
        }),
      ],
    );
  }

  Widget _buildViewAllButton(_ViewModel vm) {
    return SizedBox(
      height: vm.buttonHeight,
      child: OutlinedButton(
        onPressed: () {
          AppNavigator.to(
            "/navigation",
            arguments: {
              "tab": 2,
            },
          );
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: vm.buttonHorizontalPadding,
          ),
          side: const BorderSide(
            color: AppColors.border,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              TranslationKeys.viewAll.tr,
              style: TextStyle(
                color: AppColors.foreground,
                fontSize: vm.buttonTextSize,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
            SizedBox(
              width: vm.buttonIconSpacing,
            ),
            Icon(
              Icons.arrow_forward,
              size: vm.buttonIconSize,
              color: AppColors.foreground,
            ),
          ],
        ),
      ),
    );
  }
}

class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double slideOffset;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 650),
    this.delay = Duration.zero,
    this.slideOffset = 20,
  });

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(curvedAnimation);

    _slide = Tween<Offset>(
      begin: Offset(
        0,
        widget.slideOffset / 100,
      ),
      end: Offset.zero,
    ).animate(curvedAnimation);

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }

    if (!mounted) return;

    await _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}

class _ViewModel {
  final double width;

  const _ViewModel(this.width);

  bool get isVerySmall => width < 380;

  bool get isMobile =>
      width >= 380 && width < 600;

  bool get isTablet =>
      width >= 600 && width < 1024;

  double get sectionSpacing =>
      isVerySmall
          ? 20
          : (isMobile
          ? 24
          : (isTablet
          ? 32
          : 40));

  double get cardSpacing =>
      isVerySmall
          ? 12
          : (isMobile
          ? 16
          : (isTablet
          ? 20
          : 24));

  double get labelSize =>
      isVerySmall
          ? 9
          : (isMobile
          ? 10
          : (isTablet
          ? 11
          : 12));

  double get labelSpacing =>
      isVerySmall
          ? 4
          : (isMobile
          ? 6
          : (isTablet
          ? 8
          : 10));

  double get titleSize =>
      isVerySmall
          ? 20
          : (isMobile
          ? 24
          : (isTablet
          ? 34
          : 42));

  double get buttonHeight =>
      isVerySmall
          ? 36
          : (isMobile
          ? 42
          : (isTablet
          ? 46
          : 50));

  double get buttonHorizontalPadding =>
      isVerySmall
          ? 12
          : (isMobile
          ? 14
          : (isTablet
          ? 20
          : 24));

  double get buttonTextSize =>
      isVerySmall
          ? 10
          : (isMobile
          ? 11
          : (isTablet
          ? 13
          : 14));

  double get buttonIconSize =>
      isVerySmall
          ? 12
          : (isMobile
          ? 14
          : (isTablet
          ? 16
          : 18));

  double get buttonIconSpacing =>
      isVerySmall
          ? 3
          : (isMobile
          ? 4
          : (isTablet
          ? 6
          : 8));
}

class _HomeShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final vm = _ViewModel(constraints.maxWidth);
        final width = constraints.maxWidth;
        final horizontalPadding = 20.0;

        // Banner Height calculation matching BannerWidget
        final bannerHeight = (width * 0.78).clamp(280.0, 420.0);

        // FeatureRow settings
        final isMobileFeature = width < 700;
        final featureCrossAxisCount = isMobileFeature ? 2 : 4;
        final featureHeight = isMobileFeature ? 180.0 : 90.0;

        // ShapeGrid settings
        final isVerySmallShape = width < 380;
        final isMobileShape = width >= 380 && width < 600;
        final isTabletShape = width >= 600 && width < 1024;
        final shapeCrossAxisCount = isVerySmallShape ? 3 : (isMobileShape ? 4 : (isTabletShape ? 5 : 6));
        final shapeGridHeight = isVerySmallShape ? 380.0 : (isMobileShape ? 300.0 : 250.0);

        // CollectionBanner settings
        final isMobileCollection = width < 768;
        final collectionHeight = isMobileCollection ? 500.0 : 320.0;

        return KdtShimmer(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Banner Shimmer
                KdtSkeleton(
                  height: bannerHeight,
                  width: double.infinity,
                  borderRadius: 18,
                ),
                SizedBox(height: vm.sectionSpacing),

                // 2. Feature Row Shimmer
                SizedBox(
                  height: featureHeight,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: featureCrossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: isMobileFeature ? 2.6 : 3.8,
                    ),
                    itemCount: 4,
                    itemBuilder: (_, __) => KdtSkeleton(borderRadius: 12),
                  ),
                ),
                SizedBox(height: vm.sectionSpacing),

                // 3. Shape Grid Shimmer
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KdtSkeleton(width: 200, height: 24, borderRadius: 4),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: shapeGridHeight,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: shapeCrossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: isVerySmallShape ? 0.72 : 0.82,
                        ),
                        itemCount: isVerySmallShape ? 9 : 12,
                        itemBuilder: (_, __) => KdtSkeleton(borderRadius: 14),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: vm.sectionSpacing),

                // 4. Collection Banner Shimmer
                SizedBox(
                  height: collectionHeight,
                  child: isMobileCollection
                      ? Column(
                    children: [
                      Expanded(child: KdtSkeleton(borderRadius: 12)),
                      const SizedBox(height: 16),
                      Expanded(child: KdtSkeleton(borderRadius: 12)),
                    ],
                  )
                      : Row(
                    children: [
                      Expanded(child: KdtSkeleton(borderRadius: 12)),
                      const SizedBox(width: 28),
                      Expanded(child: KdtSkeleton(borderRadius: 12)),
                    ],
                  ),
                ),
                SizedBox(height: vm.sectionSpacing),

                // 5. Best Sellers Section Shimmer
                Center(
                  child: Column(
                    children: [
                      KdtSkeleton(width: 180, height: 12, borderRadius: 2),
                      const SizedBox(height: 8),
                      KdtSkeleton(width: 220, height: 28, borderRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 340,
                  ),
                  itemCount: 4,
                  itemBuilder: (_, __) => const DiamondCardSkeleton(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
