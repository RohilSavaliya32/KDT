import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kdt/modules/wishlist/wishlist_model.dart' as wishlist;

import '../../../utils/app_colors.dart';
import '../Loader/Helper/Loader_helper.dart';
import 'controllers/wishlist_controller.dart';

class WishlistDiamondCard extends StatelessWidget {
  final wishlist.WishlistItem diamond;
  final WishlistController controller;

  const WishlistDiamondCard({
    super.key,
    required this.diamond,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final _ViewModel vm = _ViewModel(constraints.maxWidth);
        return _buildCard(vm);
      },
    );
  }

  Widget _buildCard(_ViewModel vm) {
    final id = diamond.id;
    final title = diamond.title;
    final image = diamond.image;
    final price = diamond.price.toDouble();
    final carat = diamond.carat.toDouble();
    final cut = diamond.cut;
    final color = diamond.color;
    final clarity = diamond.clarity;
    final certification = diamond.certification;
    final certNumber = diamond.certNumber;

    final width = diamond.measurements.width.toDouble();
    final length = diamond.measurements.length.toDouble();
    final pricePerCarat = carat > 0 ? (price / carat) : 0;

    final avgRating = (diamond.averageRating ?? 0).toDouble();
    final roundedRating = avgRating == 0 ? '-' : avgRating.toStringAsFixed(1);

    final titleStyle = GoogleFonts.lora(
      fontSize: vm.titleSize,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );

    final bodyStyle = GoogleFonts.poppins(
      fontSize: vm.smallTextSize,
      fontWeight: FontWeight.w500,
      color: AppColors.darkGray,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(vm.cardRadius),
      onTap: () {
        AppNavigator.to(
          "/diamonds-details",
          arguments: id,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(vm.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(vm),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(vm.contentPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: titleStyle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              roundedRating,
                              style: bodyStyle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: vm.tinySpacing),
                    Text(
                      "$cut Cut • $color Color • $clarity Clarity",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: bodyStyle,
                    ),
                    SizedBox(height: vm.tinySpacing),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            certNumber,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: bodyStyle.copyWith(
                              color: AppColors.giaBlue,
                            ),
                          ),
                        ),
                        SizedBox(width: vm.smallSpacing),
                        Expanded(
                          child: Text(
                            "${length.toStringAsFixed(0)} × ${width.toStringAsFixed(0)} mm",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: bodyStyle,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "\$${price.toStringAsFixed(0)}",
                          style: GoogleFonts.poppins(
                            fontSize: vm.priceSize,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkGray,
                          ),
                        ),
                        SizedBox(height: vm.tinySpacing),
                        Text(
                          "\$${pricePerCarat.toStringAsFixed(0)}/ct",
                          style: GoogleFonts.poppins(
                            fontSize: vm.pricePerCaratSize,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkGray,
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
      ),
    );
  }

  Widget _buildImageSection(_ViewModel vm) {
    final id = diamond.id;
    final image = diamond.image;
    final certification = diamond.certification;

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
                child: image.isNotEmpty
                    ? Image.network(
                  image,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Image.asset(
                        'assets/shapes/logo.png',
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                )
                    : Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Image.asset(
                    'assets/shapes/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: vm.badgeTop,
              left: vm.badgeLeft,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: vm.badgeHorizontalPadding,
                  vertical: vm.badgeVerticalPadding,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF005B45),
                ),
                child: Text(
                  certification,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: vm.badgeTextSize,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Positioned(
              top: vm.favTop,
              right: vm.favRight,
              child: Obx(() {
                final isFav = controller.isInWishlist(id);

                return GestureDetector(
                  onTap: () async {
                    await controller.removeFromWishlist(id);
                  },
                  child: Container(
                    padding: EdgeInsets.all(vm.favPadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? AppColors.accent : Colors.grey,
                      size: vm.favIconSize,
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

class _ViewModel {
  final double width;

  const _ViewModel(this.width);

  bool get isVerySmall => width < 380;
  bool get isMobile => width >= 380 && width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;

  double get cardRadius {
    if (isVerySmall) return 14;
    if (isMobile) return 16;
    return 20;
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
}
