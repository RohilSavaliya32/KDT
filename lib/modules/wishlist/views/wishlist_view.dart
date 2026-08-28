import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/modules/fade_slide_in.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../../Profile & Settings/currency_price_text.dart';
import '../../translations/Translation_key/translation_keys.dart';
import '../controllers/wishlist_controller.dart';

class WishlistView extends StatefulWidget {
  const WishlistView({super.key});

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  final WishlistController controller =
  Get.find<WishlistController>();

  // Load More state
  static const int _pageSize = 10;
  int _displayLimit = _pageSize;

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
          onRefresh: () async {
            setState(() {
              _displayLimit = _pageSize;
            });

            await controller.loadWishlist();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final _ViewModel vm =
              _ViewModel(constraints.maxWidth);

              return Obx(
                    () => _buildBody(vm),
              );
            },
          ),
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
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppColors.foreground,
          size: 20,
        ),
        onPressed: () => Get.back(),
        padding: const EdgeInsets.only(left: 12),
        splashRadius: 20,
      ),
      title: Text(
        TranslationKeys.myWishlist.tr,
        style: AppTextStyles.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.foreground,
      ),
    );
  }

  Widget _buildBody(_ViewModel vm) {
    // ================= LOADING =================
    if (controller.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
        ),
      );
    }

    // ================= ERROR =================
    if (controller.errorMessage.value.isNotEmpty) {
      return FadeSlideIn(
        duration: const Duration(milliseconds: 500),
        slideOffset: 15,
        child: _EmptyOrErrorState(
          icon: Icons.error_outline,
          title: TranslationKeys.somethingWentWrong.tr,
          subtitle: controller.errorMessage.value,
          buttonText: TranslationKeys.retry.tr,
          onButtonTap: controller.loadWishlist,
          vm: vm,
        ),
      );
    }

    final wishlistDiamonds =
        controller.wishlistedDiamonds;

    // ================= EMPTY =================
    if (wishlistDiamonds.isEmpty) {
      return FadeSlideIn(
        duration: const Duration(milliseconds: 500),
        slideOffset: 15,
        child: _EmptyOrErrorState(
          icon: Icons.favorite_border,
          title: TranslationKeys.wishlistEmpty.tr,
          subtitle:
          TranslationKeys.wishlistEmptySubtitle.tr,
          buttonText:
          TranslationKeys.exploreDiamonds.tr,
          onButtonTap: () {
            AppNavigator.offAll(
              "/navigation",
              arguments: {"tab": 2},
            );
          },
          vm: vm,
        ),
      );
    }

    // Clamp display limit
    if (_displayLimit > wishlistDiamonds.length &&
        _displayLimit != _pageSize) {
      _displayLimit = wishlistDiamonds.length;
    }

    final effectiveLimit =
    _displayLimit.clamp(
      0,
      wishlistDiamonds.length,
    );

    final displayList =
    wishlistDiamonds.take(effectiveLimit).toList();

    final showLoadMore =
        effectiveLimit < wishlistDiamonds.length;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(vm.gridPadding),
      child: FadeSlideIn(
        duration: const Duration(milliseconds: 500),
        slideOffset: 15,
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                vm.crossAxisCount,
                crossAxisSpacing:
                vm.gridSpacing,
                mainAxisSpacing:
                vm.gridSpacing,
                mainAxisExtent:
                vm.cardHeight,
              ),
              itemCount: displayList.length,
              itemBuilder: (context, index) {
                final diamond =
                displayList[index];

                return _WishlistDiamondCard(
                  diamond: diamond,
                  controller: controller,
                  vm: vm,
                );
              },
            ),

            if (showLoadMore) ...[
              const SizedBox(height: 16),
              _buildLoadMoreButton(),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOAD MORE
  // ============================================================

  Widget _buildLoadMoreButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _displayLimit += _pageSize;
          });
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: AppColors.accent,
            width: 1.2,
          ),
          foregroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
          ),
        ),
        child: Text(
          "Load More",
          style: AppTextStyles.poppins(
            color: AppColors.accent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// WISHLIST DIAMOND CARD
// ============================================================

class _WishlistDiamondCard extends StatelessWidget {
  final dynamic diamond;
  final WishlistController controller;
  final _ViewModel vm;

  const _WishlistDiamondCard({
    required this.diamond,
    required this.controller,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler:
        const TextScaler.linear(1.0),
        boldText: false,
      ),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(vm.cardRadius),
        onTap: () {
          AppNavigator.to(
            "/diamonds-details",
            arguments: diamond.id,
          );
        },
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    final pricePerCarat =
    diamond.carat > 0
        ? (diamond.price / diamond.carat)
        : 0;

    final avgRating =
    (diamond.averageRating ?? 0).toDouble();

    final roundedRating =
    avgRating == 0
        ? '-'
        : avgRating.toStringAsFixed(1);

    final titleStyle = AppTextStyles.lora(
      fontSize: vm.titleSize,
      fontWeight: FontWeight.w500,
      color: AppColors.foreground,
    );

    final bodyStyle = AppTextStyles.poppins(
      fontSize: vm.smallTextSize,
      fontWeight: FontWeight.w500,
      color: AppColors.darkGray,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius:
        BorderRadius.circular(vm.cardRadius),
        boxShadow: [
          BoxShadow(
            color:
            AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _buildImageSection(),

          Expanded(
            child: Padding(
              padding:
              EdgeInsets.all(vm.contentPadding),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          diamond.title,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style: titleStyle,
                        ),
                      ),

                      // Rating
                      if (avgRating > 0) ...[
                        const SizedBox(width: 6),

                        Row(
                          mainAxisSize:
                          MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color:
                              AppColors.rating,
                            ),

                            const SizedBox(width: 2),

                            Text(
                              roundedRating,
                              style:
                              AppTextStyles.poppins(
                                fontWeight:
                                FontWeight.w600,
                                color:
                                AppColors.foreground,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),

                  SizedBox(
                    height: vm.tinySpacing,
                  ),

                  Text(
                    "${diamond.cut} Cut • "
                        "${diamond.color} Color • "
                        "${diamond.clarity} Clarity",
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: bodyStyle,
                  ),

                  SizedBox(
                    height: vm.tinySpacing,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          diamond.certNumber,
                          overflow:
                          TextOverflow.ellipsis,
                          maxLines: 1,
                          style:
                          AppTextStyles.poppins(
                            color:
                            AppColors.giaBlue,
                            fontSize: 8,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: vm.smallSpacing,
                      ),

                      Expanded(
                        child: Text(
                          "${diamond.measurements.length} × "
                              "${diamond.measurements.width} mm",
                          overflow:
                          TextOverflow.ellipsis,
                          maxLines: 1,
                          style: bodyStyle,
                        ),
                      ),
                    ],
                  ),

                  const Divider(
                    height: 16,
                    color: AppColors.divider,
                  ),

                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          CurrencyPriceText(
                            usdAmount:
                            diamond.price.toDouble(),
                            style:
                            AppTextStyles.lora(
                              fontSize:
                              vm.priceSize + 4,
                              fontWeight:
                              FontWeight.w500,
                              color:
                              AppColors.foreground,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: vm.tinySpacing,
                      ),

                      Row(
                        children: [
                          if (diamond.originalPrice >
                              diamond.price)
                            CurrencyPriceText(
                              usdAmount: diamond
                                  .originalPrice
                                  .toDouble(),
                              style:
                              AppTextStyles.poppins(
                                fontSize: 12,
                                color:
                                AppColors.darkGray,
                                decoration:
                                TextDecoration
                                    .lineThrough,
                              ),
                            ),
                        ],
                      ),

                      SizedBox(
                        height: vm.tinySpacing,
                      ),

                      CurrencyPriceText(
                        usdAmount:
                        pricePerCarat.toDouble(),
                        suffix: "/ct",
                        style:
                        AppTextStyles.poppins(
                          fontSize:
                          vm.pricePerCaratSize,
                          color:
                          AppColors.darkGray,
                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft:
        Radius.circular(vm.cardRadius),
        topRight:
        Radius.circular(vm.cardRadius),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Padding(
                padding:
                const EdgeInsets.all(1),
                child: Image.network(
                  diamond.image,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return const Icon(
                      Icons.diamond_outlined,
                      size: 80,
                      color:
                      AppColors.mutedForeground,
                    );
                  },
                ),
              ),
            ),

            // ==================================================
            // LAB GROWN BADGE
            // ==================================================

            if (diamond.isLabGrown)
              Positioned(
                top: vm.badgeTop,
                left: vm.badgeLeft,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color:
                    AppColors.primaryDark,
                    borderRadius:
                    BorderRadius.circular(1),
                  ),
                  child: Text(
                    "Lab-Grown",
                    style:
                    AppTextStyles.poppins(
                      color:
                      AppColors.white,
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w500,
                      height: 1,
                    ),
                  ),
                ),
              ),

            // ==================================================
            // CERTIFICATION BADGE
            // ==================================================

            Positioned(
              top: diamond.isLabGrown
                  ? vm.badgeTop + 22
                  : vm.badgeTop,
              left: vm.badgeLeft,
              child: Container(
                padding:
                EdgeInsets.symmetric(
                  horizontal:
                  vm.badgeHorizontalPadding,
                  vertical:
                  vm.badgeVerticalPadding,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                ),
                child: Text(
                  diamond.certification,
                  style:
                  AppTextStyles.poppins(
                    color: AppColors.white,
                    fontWeight:
                    FontWeight.bold,
                    fontSize:
                    vm.badgeTextSize,
                  ),
                ),
              ),
            ),

            // ==================================================
            // DISCOUNT BADGE
            // ==================================================

            if (diamond.discountPercent > 0)
              Positioned(
                right: 3,
                bottom: 3,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color:
                    AppColors.lightGreen,
                    border: Border.all(
                      color:
                      AppColors.accentDisabled,
                    ),
                    borderRadius:
                    BorderRadius.circular(4),
                  ),
                  child: Text(
                    "SAVE ${diamond.discountPercent}%",
                    style:
                    AppTextStyles.poppins(
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w700,
                      color:
                      AppColors.accent,
                    ),
                  ),
                ),
              ),

            // ==================================================
            // WISHLIST BUTTON
            // ==================================================

            Positioned(
              top: vm.favTop,
              right: vm.favRight,
              child: Obx(() {
                final isFav =
                controller.isInWishlist(
                  diamond.id,
                );

                return GestureDetector(
                  onTap: () async {
                    await controller
                        .removeFromWishlist(
                      diamond.id,
                    );
                  },
                  child: Container(
                    padding:
                    EdgeInsets.all(
                      vm.favPadding,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      AppColors.white,
                      shape:
                      BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                          AppColors.black
                              .withOpacity(
                              0.12),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      isFav
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: isFav
                          ? AppColors.accent
                          : AppColors.iconGray,
                      size:
                      vm.favIconSize,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY / ERROR STATE
// ============================================================

class _EmptyOrErrorState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onButtonTap;
  final _ViewModel vm;

  const _EmptyOrErrorState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onButtonTap,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler:
        const TextScaler.linear(1.0),
        boldText: false,
      ),
      child: Center(
        child: Padding(
          padding:
          const EdgeInsets.all(24),
          child: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              Icon(
                icon,
                size:
                vm.emptyIconSize,
                color:
                AppColors.mutedForeground,
              ),

              SizedBox(
                height: vm.emptySpacing,
              ),

              Text(
                title,
                style:
                AppTextStyles.lora(
                  fontSize:
                  vm.emptyTitleSize,
                  fontWeight:
                  FontWeight.w700,
                  color:
                  AppColors.foreground,
                ),
                textAlign:
                TextAlign.center,
              ),

              SizedBox(
                height:
                vm.emptySubtitleSpacing,
              ),

              Text(
                subtitle,
                style:
                AppTextStyles.poppins(
                  fontSize:
                  vm.emptySubtitleSize,
                  color:
                  AppColors.mutedForeground,
                ),
                textAlign:
                TextAlign.center,
              ),

              SizedBox(
                height:
                vm.emptyButtonSpacing,
              ),

              SizedBox(
                width:
                vm.buttonWidth,
                height:
                vm.buttonHeight,
                child:
                ElevatedButton(
                  onPressed:
                  onButtonTap,
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    AppColors.accent,
                    foregroundColor:
                    AppColors.white,
                    elevation: 0,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                          3),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style:
                    AppTextStyles.poppins(
                      fontSize:
                      vm.buttonTextSize,
                      fontWeight:
                      FontWeight.w500,
                      color:
                      AppColors.white,
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
}

// ============================================================
// RESPONSIVE VIEW MODEL
// ============================================================

class _ViewModel {
  final double width;

  const _ViewModel(this.width);

  bool get isVerySmall => width < 380;

  bool get isMobile =>
      width >= 380 && width < 600;

  bool get isTablet =>
      width >= 600 && width < 1024;

  bool get isDesktop =>
      width >= 1024;

  int get crossAxisCount {
    if (isVerySmall) return 2;
    if (isMobile) return 2;
    if (isTablet) return 3;

    return 4;
  }

  double get gridSpacing {
    if (isVerySmall) return 8;
    if (isMobile) return 10;

    return 12;
  }

  double get gridPadding {
    if (isVerySmall) return 8;
    if (isMobile) return 10;

    return 12;
  }

  double get cardHeight {
    if (isVerySmall) return 324;
    if (isMobile) return 344;
    if (isTablet) return 444;

    return 445;
  }

  double get cardRadius {
    if (isVerySmall) return 14;
    if (isMobile) return 16;

    return 20;
  }

  double get emptyIconSize {
    if (isVerySmall) return 48;
    if (isMobile) return 56;
    if (isTablet) return 60;

    return 64;
  }

  double get emptySubtitleSpacing {
    if (isVerySmall) return 6;
    if (isMobile) return 8;

    return 10;
  }

  double get buttonWidth {
    if (isVerySmall) return 160;
    if (isMobile) return 180;

    return 200;
  }

  double get buttonHeight {
    if (isVerySmall) return 40;
    if (isMobile) return 44;

    return 48;
  }

  double get contentPadding {
    if (isVerySmall) return 6;
    if (isMobile) return 8;

    return 10;
  }

  double get tinySpacing {
    if (isVerySmall) return 2;
    if (isMobile) return 3;

    return 4;
  }

  double get smallSpacing {
    if (isVerySmall) return 4;
    if (isMobile) return 6;

    return 8;
  }

  double get titleSize {
    if (isVerySmall) return 14;
    if (isMobile) return 16;
    if (isTablet) return 18;

    return 18;
  }

  double get smallTextSize {
    if (isVerySmall) return 8;
    if (isMobile) return 9;

    return 10;
  }

  double get priceSize {
    if (isVerySmall) return 16;
    if (isMobile) return 17;

    return 18;
  }

  double get pricePerCaratSize {
    if (isVerySmall) return 10;
    if (isMobile) return 10;

    return 11;
  }

  double get badgeTop {
    if (isVerySmall) return 6;
    if (isMobile) return 8;

    return 10;
  }

  double get badgeLeft {
    if (isVerySmall) return 6;
    if (isMobile) return 8;

    return 10;
  }

  double get badgeHorizontalPadding {
    if (isVerySmall) return 4;
    if (isMobile) return 4;

    return 5;
  }

  double get badgeVerticalPadding {
    if (isVerySmall) return 1;
    if (isMobile) return 2;

    return 2;
  }

  double get badgeTextSize {
    if (isVerySmall) return 9;
    if (isMobile) return 10;

    return 11;
  }

  double get favTop {
    if (isVerySmall) return 6;
    if (isMobile) return 8;

    return 10;
  }

  double get favRight {
    if (isVerySmall) return 6;
    if (isMobile) return 8;

    return 10;
  }

  double get favPadding {
    if (isVerySmall) return 4;
    if (isMobile) return 5;

    return 6;
  }

  double get favIconSize {
    if (isVerySmall) return 16;
    if (isMobile) return 18;

    return 20;
  }

  double get emptyStateHeight {
    if (isVerySmall) return 350;
    if (isMobile) return 380;

    return 420;
  }

  double get emptyTitleSize {
    if (isVerySmall) return 22;
    if (isMobile) return 24;
    if (isTablet) return 26;

    return 28;
  }

  double get emptySubtitleSize {
    if (isVerySmall) return 13;
    if (isMobile) return 14;
    if (isTablet) return 15;

    return 16;
  }

  double get emptySpacing {
    if (isVerySmall) return 8;
    if (isMobile) return 10;

    return 12;
  }

  double get emptyButtonSpacing {
    if (isVerySmall) return 16;
    if (isMobile) return 20;

    return 24;
  }

  double get buttonPadding {
    if (isVerySmall) return 12;
    if (isMobile) return 14;

    return 16;
  }

  double get buttonVerticalPadding {
    if (isVerySmall) return 8;
    if (isMobile) return 10;

    return 12;
  }

  double get buttonTextSize {
    if (isVerySmall) return 12;
    if (isMobile) return 13;

    return 14;
  }
}