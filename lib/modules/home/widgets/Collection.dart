import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';

import '../../Loader/Helper/Loader_helper.dart';
import '../../Profile & Settings/currency_price_text.dart';
import '../../settings/controllers/settings_controller.dart';
import '../controllers/home_controller.dart';

// hello
class Collection extends StatefulWidget {
  const Collection({super.key});

  @override
  State<Collection> createState() => _CollectionState();
}

class _CollectionState extends State<Collection> {
  static const double _itemExtent = 146.0;
  static const double _scrollAmount = _itemExtent * 2;

  late final ScrollController _scrollController;

  bool _isRecentering = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_isRecentering) return;
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (!position.hasContentDimensions) return;

    final maxExtent = position.maxScrollExtent;

    if (maxExtent <= 0) return;

    final currentOffset = position.pixels;

    if (currentOffset < maxExtent * 0.10 ||
        currentOffset > maxExtent * 0.90) {
      _recenterList(maxExtent);
    }
  }

  void _recenterList(double maxExtent) {
    if (!_scrollController.hasClients) return;

    _isRecentering = true;

    final middleOffset = maxExtent / 2;

    _scrollController.jumpTo(
      middleOffset.clamp(
        0.0,
        maxExtent,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isRecentering = false;
    });
  }

  void _scroll(bool forward) {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (!position.hasContentDimensions) return;

    final currentOffset = position.pixels;

    final targetOffset = forward
        ? currentOffset + _scrollAmount
        : currentOffset - _scrollAmount;

    _scrollController.animateTo(
      targetOffset.clamp(
        0.0,
        position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  String _formatImageUrl(String path) {
    final cleanPath = path.trim();

    if (cleanPath.isEmpty) return '';

    final lower = cleanPath.toLowerCase();

    if (lower == 'null' ||
        lower == 'undefined' ||
        lower == 'n/a') {
      return '';
    }

    if (cleanPath.startsWith('http://') ||
        cleanPath.startsWith('https://')) {
      return cleanPath;
    }

    if (cleanPath.startsWith('assets/')) {
      return cleanPath;
    }

    final normalizedPath =
    cleanPath.startsWith('/') ? cleanPath : '/$cleanPath';

    if (normalizedPath == '/' ||
        normalizedPath.trim().length < 3) {
      return '';
    }

    return 'https://www.kdtdiamond.com$normalizedPath';
  }

  Widget _buildFallbackLogo() {
    return Image.asset(
      'assets/shapes/logo.png',
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProductImage(String imageUrl) {
    final formattedUrl = _formatImageUrl(imageUrl);

    if (formattedUrl.isEmpty) {
      return _buildFallbackLogo();
    }

    if (formattedUrl.startsWith('assets/')) {
      return Image.asset(
        formattedUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackLogo();
        },
      );
    }

    return CachedNetworkImage(
      imageUrl: formattedUrl,
      fit: BoxFit.contain,
      memCacheWidth: 260,
      maxWidthDiskCache: 260,
      placeholder: (context, url) => _buildFallbackLogo(),
      errorWidget: (context, url, error) {
        return _buildFallbackLogo();
      },
      httpHeaders: const {
        'User-Agent': 'Mozilla/5.0',
        'Referer': 'https://kdtdiamond.com/',
      },
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 600;

        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 10,
          ),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            // Soft warm background
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),

            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),

            // Main section shadow
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.08),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: isSmall
              ? Column(
            children: [
              _buildBanner(height: 230),
              _buildProductSection(),
            ],
          )
              : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 43,
                child: _buildBanner(),
              ),
              Expanded(
                flex: 57,
                child: _buildProductSection(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBanner({double? height}) {
    final controller = Get.find<SettingsController>();

    return Obx(() {
      final homeSettings = controller.settings.value?.home;

      final title =
          homeSettings?.promoBannerTitle ?? 'Best\nSeller';

      final rawImageUrl = homeSettings?.promoBannerImage;

      final formattedBannerUrl =
      rawImageUrl == null
          ? ''
          : _formatImageUrl(rawImageUrl);

      final hasImage = formattedBannerUrl.isNotEmpty;

      return Stack(
        children: [
          Container(
            height: height ?? double.infinity,
            width: double.infinity,
            color: Colors.white,
            child: hasImage
                ? CachedNetworkImage(
              imageUrl: formattedBannerUrl,
              fit: BoxFit.cover,

              memCacheWidth: 900,
              maxWidthDiskCache: 900,

              placeholder: (context, url) => Padding(
                padding: const EdgeInsets.all(40),
                child: Image.asset(
                  'assets/shapes/hero.jpg',
                  fit: BoxFit.contain,
                ),
              ),

              errorWidget: (context, url, error) {
                return Padding(
                  padding: const EdgeInsets.all(40),
                  child: Image.asset(
                    'assets/shapes/hero.jpg',
                    fit: BoxFit.contain,
                  ),
                );
              },

              httpHeaders: const {
                'User-Agent': 'Mozilla/5.0',
                'Referer': 'https://kdtdiamond.com/',
              },
            )
                : Padding(
              padding: const EdgeInsets.all(40),
              child: Image.asset(
                'assets/shapes/hero.jpg',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Darker overlay for better premium look
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    hasImage
                        ? Colors.black.withOpacity(0.16)
                        : Colors.transparent,
                    hasImage
                        ? Colors.black.withOpacity(0.62)
                        : Colors.black.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),

          // Banner Content
          Positioned(
            left: 22,
            right: 22,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.replaceAll('\\n', '\n'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.lora(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: hasImage
                        ? AppColors.white
                        : AppColors.foreground,
                    height: 1.05,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'RAW BRILLIANT',
                  style: AppTextStyles.poppins(
                    fontSize: 10,
                    color: hasImage
                        ? AppColors.white.withOpacity(0.92)
                        : AppColors.mutedForeground,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            right: 22,
            child: _buildRibbonBadge(),
          ),
        ],
      );
    });
  }

  Widget _buildRibbonBadge() {
    return CustomPaint(
      painter: RibbonPainter(
        color: AppColors.accent,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          8,
          12,
          8,
          16,
        ),
        child: Text(
          'NEW\nCOLLECTION',
          textAlign: TextAlign.center,
          style: AppTextStyles.poppins(
            fontSize: 8,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
            height: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildProductSection() {
    final controller = Get.find<HomeController>();

    return Obx(() {
      final products = controller.bestSellerDiamonds;

      if (products.isEmpty) {
        return const SizedBox(
          height: 190,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.accent,
              ),
            ),
          ),
        );
      }

      final itemCount = products.length * 3;

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          18,
          20,
          18,
          18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 194,
              child: ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  vertical: 2,
                ),
                itemCount: itemCount,
                cacheExtent: 300,
                physics: const BouncingScrollPhysics(),

                separatorBuilder: (_, __) {
                  return const SizedBox(width: 14);
                },

                itemBuilder: (context, index) {
                  final diamond =
                  products[index % products.length];

                  return _buildProductItem(
                    id: diamond.id,
                    imageUrl: diamond.image,
                    price: diamond.price,
                    description: diamond.title,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                _buildCircleIconButton(
                  Icons.arrow_back_ios_new_rounded,
                  onTap: () => _scroll(false),
                ),

                const SizedBox(width: 10),

                _buildCircleIconButton(
                  Icons.arrow_forward_ios_rounded,
                  onTap: () => _scroll(true),
                ),

                const Spacer(),

                _buildShopNowButton(),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProductItem({
    required String id,
    required String imageUrl,
    required double price,
    required String description,
  }) {
    return InkWell(
      onTap: () {
        AppNavigator.to(
          '/navigation',
          arguments: {
            'tab': 2,
          },
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 122,
              width: 130,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),

                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                ),

                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.07),
                    blurRadius: 14,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: _buildProductImage(imageUrl),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CurrencyPriceText(
                usdAmount: price,
                style: AppTextStyles.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.foreground,
                ),
              ),
            ),

            const SizedBox(height: 2),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.poppins(
                  fontSize: 10,
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleIconButton(
      IconData icon, {
        VoidCallback? onTap,
      }) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,

            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),

            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 14,
            color: AppColors.foreground,
          ),
        ),
      ),
    );
  }

  Widget _buildShopNowButton() {
    return InkWell(
      onTap: () {
        AppNavigator.to(
          '/navigation',
          arguments: {
            'tab': 2,
          },
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(10),

          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          'Shop Now',
          style: AppTextStyles.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

class RibbonPainter extends CustomPainter {
  final Color color;

  RibbonPainter({
    required this.color,
  });

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()..color = color;

    final path = Path()
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(
        size.width / 2,
        size.height - 10,
      )
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(
      CustomPainter oldDelegate,
      ) {
    return false;
  }
}