import 'package:kdt/modules/fade_slide_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kdt/utils/app_decorations.dart';
import 'package:kdt/utils/app_text_style.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/kdt_shimmer.dart';
import '../../KDTDiamondLoader.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../../No_data.dart';
import '../../Profile & Settings/currency_price_text.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../controllers/daimond_card_controller.dart';
import '../diamond_model.dart';

class DiamondCardView extends StatefulWidget {
  final bool isEmbedded;
  final bool enablesearch;
  final bool useFilters;
  final bool enableScroll;
  final int sortIndex;
  final VoidCallback? onClearFilters;
  final DiamondCardController? controller;
  final int? limit;
  final List<DiamondModel>? diamonds;
  final bool enableLoadMore;

  const DiamondCardView({
    super.key,
    this.isEmbedded = false,
    this.enablesearch = false,
    this.enableScroll = false,
    this.useFilters = false,
    this.sortIndex = 0,
    this.onClearFilters,
    this.controller,
    this.limit,
    this.diamonds,
    this.enableLoadMore = false,
  });

  @override
  State<DiamondCardView> createState() => _DiamondCardViewState();
}

class _DiamondCardViewState extends State<DiamondCardView> {
  late int? _displayLimit = widget.limit;

  @override
  void initState() {
    super.initState();
    _displayLimit = widget.limit;
  }

  @override
  void didUpdateWidget(covariant DiamondCardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.limit != widget.limit) {
      _displayLimit = widget.limit;
    }
  }

  String _formatImageUrl(String path) {
    if (path.isEmpty) return "";
    if (path.startsWith('http')) return path;
    if (path.startsWith('assets/')) return path;
    const String baseUrl = "https://www.kdtdiamond.com";
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return "$baseUrl$cleanPath";
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final vm = _ViewModel(constraints.maxWidth);
            final controller = widget.controller ?? Get.find<DiamondCardController>();
            return Obx(() {
              // Proper loading check for both direct list and controller list
              final bool isMainLoading = controller.isLoading.value;
              final bool listIsEmpty = widget.diamonds != null 
                  ? widget.diamonds!.isEmpty 
                  : (widget.useFilters ? controller.filteredList.isEmpty : controller.diamonds.isEmpty);

              if (isMainLoading && listIsEmpty) {
                return KdtShimmer(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.limit ?? 4,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: vm.crossAxisCount,
                      crossAxisSpacing: vm.gridSpacing,
                      mainAxisSpacing: vm.gridSpacing,
                      mainAxisExtent: vm.cardHeight,
                    ),
                    itemBuilder: (context, index) => const DiamondCardSkeleton(),
                  ),
                );
              }
              
              final List<DiamondModel> sourceList;

              if (widget.diamonds != null) {
                sourceList = widget.diamonds!;
              } else if (widget.enablesearch &&
                  controller.searchText.value.isNotEmpty) {
                sourceList = controller.searchOnlyDiamonds;
              } else if (widget.useFilters) {
                sourceList = controller.filteredList;
              } else {
                sourceList = controller.diamonds;
              }

              final list = _applySort(sourceList, widget.sortIndex);

              if (list.isEmpty) {
                return _buildEmptyState(context, controller, vm);
              }

              return _buildGridWithLoadMore(list, controller, vm);
            });
          },
        ),
      ),
    );
  }

  List<DiamondModel> _applySort(List<DiamondModel> source, int sortIndex) {
    final list = List<DiamondModel>.from(source);
    switch (sortIndex) {
      case 1:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 2:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 3:
        list.sort((a, b) => b.carat.compareTo(a.carat));
        break;
      default:
        break;
    }
    return list;
  }

  Widget _buildEmptyState(BuildContext context, DiamondCardController controller, _ViewModel vm) {
    final hasFilters = controller.selectedShapes.isNotEmpty ||
        controller.selectedCertifications.isNotEmpty ||
        controller.labGrownFilter.value != null ||
        controller.selectedType.value.isNotEmpty ||
        controller.selectedCuts.isNotEmpty ||
        controller.selectedColors.isNotEmpty ||
        controller.selectedClarities.isNotEmpty ||
        controller.minCarat.value > 0 ||
        controller.maxCarat.value < 999999999.0;

    if (widget.useFilters || hasFilters) {
      return SizedBox(
        height: vm.emptyStateHeight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "No diamonds found",
                style: AppTextStyles.lora(
                  fontSize: vm.emptyTitleSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: vm.emptySpacing),
              Text(
                "Try adjusting your filters.",
                style: AppTextStyles.poppins(
                  fontSize: vm.emptySubtitleSize,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: vm.emptyButtonSpacing),
              OutlinedButton(
                onPressed: () {
                  if (widget.onClearFilters != null) {
                    widget.onClearFilters!();
                  } else {
                    controller.clearAllFilters();
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF0A4B34), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: EdgeInsets.symmetric(
                    horizontal: vm.buttonPadding,
                    vertical: vm.buttonVerticalPadding,
                  ),
                ),
                child: Text(
                  "Clear All Filters",
                  style: TextStyle(
                    color: const Color(0xFF0A4B34),
                    fontSize: vm.buttonTextSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const Center(child: NoDataFoundWidget());
  }

  Widget _buildGridWithLoadMore(List<DiamondModel> list, DiamondCardController controller, _ViewModel vm) {
    final effectiveLimit = _displayLimit ?? list.length;
    final displayList = list.take(effectiveLimit).toList();
    final canShowMoreLocally = widget.limit != null && displayList.length < list.length;
    final canLoadMoreFromServer = controller.hasMore.value &&
        controller.diamonds.length >= controller.limit &&
        !widget.useFilters &&
        !(widget.enablesearch && controller.searchText.value.isNotEmpty);
    final showLoadMoreButton = widget.enableLoadMore && (canShowMoreLocally || canLoadMoreFromServer);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGrid(displayList, controller, vm),
        if (showLoadMoreButton) ...[
          SizedBox(height: vm.gridSpacing * 1.5),
          _buildLoadMoreButton(controller, canShowMoreLocally),
        ],
      ],
    );
  }

  Widget _buildLoadMoreButton(DiamondCardController controller, bool canShowMoreLocally) {
    return Obx(() {
      final isBusy = controller.isLoading.value;
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: isBusy
              ? null
              : () async {
            if (canShowMoreLocally) {
              setState(() {
                _displayLimit = (_displayLimit ?? 0) + (widget.limit ?? 8);
              });
            }
            if (!canShowMoreLocally && controller.hasMore.value) {
              await controller.loadMore();
              setState(() {
                _displayLimit = (_displayLimit ?? 0) + (widget.limit ?? 8);
              });
            }
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF0A4B34), width: 1.2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: isBusy
              ? const SizedBox(height: 18, width: 18, child: DiamondLoader(size: 20))
              : Text(
            "Load More",
            style: AppTextStyles.poppins(
              color: const Color(0xFF0A4B34),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildGrid(List<DiamondModel> displayList, DiamondCardController controller, _ViewModel vm) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: widget.isEmbedded || widget.enableLoadMore,
      physics: widget.enableScroll
          ? const BouncingScrollPhysics()
          : ((widget.isEmbedded || widget.enableLoadMore)
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics()),
      itemCount: displayList.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: vm.crossAxisCount,
        crossAxisSpacing: vm.gridSpacing,
        mainAxisSpacing: vm.gridSpacing,
        mainAxisExtent: vm.cardHeight,
      ),
      itemBuilder: (context, index) {
        final diamond = displayList[index];
        return FadeSlideIn(
          delay: Duration(milliseconds: index < 6 ? index * 80 : 0),
          duration: const Duration(milliseconds: 700),
          slideOffset: 20,
          child: InkWell(
            borderRadius: BorderRadius.circular(vm.cardRadius),
            onTap: () => AppNavigator.to("/diamonds-details", arguments: diamond.id),
            child: _buildDiamondCard(diamond: diamond, controller: controller, vm: vm),
          ),
        );
      },
    );
  }

  Widget _buildDiamondCard({
    required DiamondModel diamond,
    required DiamondCardController controller,
    required _ViewModel vm,
  }) {
    final pricePerCarat = diamond.carat > 0 ? (diamond.price / diamond.carat) : 0;
    final wishlistController = Get.find<WishlistController>();
    final avgRating = (diamond.averageRating ?? 0).toDouble();
    final roundedRating = avgRating == 0 ? '-' : avgRating.toStringAsFixed(1);

    return Container(
      decoration: AppDecorations.cardDecoration(
        color: AppColors.cardBg,
        radius: vm.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(diamond, wishlistController, vm),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(vm.contentPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          diamond.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.lora(
                            fontSize: vm.titleSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (avgRating > 0) ...[
                        const SizedBox(width: 6),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, size: 16, color: AppColors.rating),
                            const SizedBox(width: 2),
                            Text(
                              roundedRating,
                              style: AppTextStyles.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  fontSize: 10
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: vm.tinySpacing),
                  Text(
                    "${diamond.carat.toStringAsFixed(2)} Ct • ${diamond.cut} • ${diamond.color} • ${diamond.clarity}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.poppins(
                      fontSize: vm.smallTextSize,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkGray,
                    ),
                  ),
                  SizedBox(height: vm.tinySpacing),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${diamond.certification} ${diamond.certNumber}",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTextStyles.poppins(color: AppColors.giaBlue, fontSize: 8),
                        ),
                      ),
                      SizedBox(width: vm.smallSpacing),
                      Expanded(
                        child: Text(
                          "${diamond.measurements.length} × ${diamond.measurements.width} mm",
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: AppTextStyles.poppins(
                            fontSize: vm.smallTextSize,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CurrencyPriceText(
                        usdAmount: diamond.price.toDouble(),
                        style: AppTextStyles.lora(
                          fontSize: vm.priceSize + 4,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (diamond.originalPrice > diamond.price)
                            CurrencyPriceText(
                              usdAmount: diamond.originalPrice.toDouble(),
                              style: AppTextStyles.poppins(
                                fontSize: 12,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          const SizedBox(width: 4),
                          CurrencyPriceText(
                            usdAmount: pricePerCarat.toDouble(),
                            suffix: "/ct",
                            style: AppTextStyles.poppins(
                              fontSize: vm.pricePerCaratSize,
                              color: AppColors.darkGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(DiamondModel diamond, WishlistController wishlistController, _ViewModel vm) {
    final imageUrl = _formatImageUrl(diamond.image);
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(vm.cardRadius),
        topRight: Radius.circular(vm.cardRadius),
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(1),
                child: Hero(
                  tag: 'diamond_${diamond.id}',
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) => Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Image.asset('assets/shapes/logo.png', fit: BoxFit.contain),
                    ),
                  )
                      : Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Image.asset('assets/shapes/logo.png', fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            if (diamond.isLabGrown)
              Positioned(
                top: vm.badgeTop,
                left: vm.badgeLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF111111), borderRadius: BorderRadius.circular(1)),
                  child: Text(
                    "Lab-Grown",
                    style: AppTextStyles.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500, height: 1),
                  ),
                ),
              ),
            Positioned(
              top: diamond.isLabGrown ? vm.badgeTop + 22 : vm.badgeTop,
              left: vm.badgeLeft,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: vm.badgeHorizontalPadding, vertical: vm.badgeVerticalPadding),
                decoration: const BoxDecoration(color: Color(0xFF005B45)),
                child: Text(
                  diamond.certification,
                  style: AppTextStyles.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: vm.badgeTextSize),
                ),
              ),
            ),
            if (diamond.discountPercent > 0)
              Positioned(
                right: 3,
                bottom: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFE5EDEA), border: Border.all(color: const Color(0xFFB8DCCF)), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    "SAVE ${diamond.discountPercent}%",
                    style: AppTextStyles.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF005B45)),
                  ),
                ),
              ),
            Positioned(
              top: vm.favTop,
              right: vm.favRight,
              child: Obx(() {
                final isFav = wishlistController.isInWishlist(diamond.id);
                return GestureDetector(
                  onTap: () => wishlistController.toggleWishlist(diamond),
                  child: Container(
                    padding: EdgeInsets.all(vm.favPadding),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                    child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? AppColors.accent : Colors.grey, size: vm.favIconSize),
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

class _ViewModel {
  final double width;
  const _ViewModel(this.width);

  bool get isVerySmall => width < 380;
  bool get isMobile => width >= 380 && width < 600;
  bool get isTablet => width >= 600 && width < 1024;

  int get crossAxisCount => (isVerySmall || isMobile) ? 2 : (isTablet ? 3 : 4);
  double get gridSpacing => isVerySmall ? 8 : (isMobile ? 10 : 12);

  double get cardWidth =>
      (width - (crossAxisCount - 1) * gridSpacing) / crossAxisCount;

  double get contentHeight => isVerySmall ? 125 : (isMobile ? 135 : 148);

  double get cardHeight => cardWidth + contentHeight;
  double get cardRadius => AppDecorations.cardRadius;
  double get contentPadding => isVerySmall ? 6 : (isMobile ? 8 : 10);
  double get tinySpacing => isVerySmall ? 2 : (isMobile ? 3 : 4);
  double get smallSpacing => isVerySmall ? 4 : (isMobile ? 6 : 8);
  double get titleSize => isVerySmall ? 14 : (isMobile ? 16 : 18);
  double get smallTextSize => isVerySmall ? 8 : (isMobile ? 9 : 10);
  double get priceSize => isVerySmall ? 16 : (isMobile ? 17 : 18);
  double get pricePerCaratSize => isVerySmall ? 10 : 11;
  double get badgeTop => isVerySmall ? 6 : (isMobile ? 8 : 10);
  double get badgeLeft => isVerySmall ? 6 : (isMobile ? 8 : 10);
  double get badgeHorizontalPadding => isVerySmall ? 4 : 5;
  double get badgeVerticalPadding => isVerySmall ? 1 : 2;
  double get badgeTextSize => isVerySmall ? 9 : (isMobile ? 10 : 11);
  double get favTop => isVerySmall ? 6 : (isMobile ? 8 : 10);
  double get favRight => isVerySmall ? 6 : (isMobile ? 8 : 10);
  double get favPadding => isVerySmall ? 4 : (isMobile ? 5 : 6);
  double get favIconSize => isVerySmall ? 16 : (isMobile ? 18 : 20);
  double get emptyStateHeight => isVerySmall ? 350 : (isMobile ? 380 : 420);
  double get emptyTitleSize => isVerySmall ? 22 : (isMobile ? 24 : 26);
  double get emptySubtitleSize => isVerySmall ? 13 : (isMobile ? 14 : 15);
  double get emptySpacing => isVerySmall ? 8 : 10;
  double get emptyButtonSpacing => isVerySmall ? 16 : (isMobile ? 20 : 24);
  double get buttonPadding => isVerySmall ? 12 : 14;
  double get buttonVerticalPadding => isVerySmall ? 8 : 10;
  double get buttonTextSize => isVerySmall ? 12 : 13;
}
