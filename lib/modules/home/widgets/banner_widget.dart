import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kdt/utils/app_colors.dart';
import '../../../data/Setting_Cont.dart';
import '../../../modules/Loader/Helper/Loader_helper.dart';
import '../../../modules/translations/Translation_key/translation_keys.dart';

class BannerWidget extends StatefulWidget {
  const BannerWidget({super.key});

  @override
  State<BannerWidget> createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget>
    with AutomaticKeepAliveClientMixin {
  late final PageController _pageController;
  Timer? _timer;
  int _currentIndex = 0;
  bool _isAnimating = false;
  bool _isImageLoading = false;
  List<String> _cachedImages = [];
  final Map<int, bool> _imageLoadedStatus = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializePageController();

    final settingsController = Get.find<SettingsDataController>();

    // Listen to settings changes to trigger initial preload and slide
    ever(settingsController.settings, (settings) {
      if (settings != null && _cachedImages.isEmpty) {
        _preloadImages().then((_) {
          if (mounted) _startAutoSlide();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (settingsController.settings.value != null) {
        await _preloadImages();
        if (mounted) {
          _startAutoSlide();
        }
      }
    });
  }

  void _initializePageController() {
    final savedIndex = PageStorage.of(context)?.readState(
      context,
      identifier: "banner_page",
    ) as int? ?? 0;
    _currentIndex = savedIndex;
    _pageController = PageController(
      initialPage: _currentIndex,
      keepPage: true,
    );
  }

  @override
  void didUpdateWidget(covariant BannerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _timer?.cancel();

    final settingsController = Get.find<SettingsDataController>();
    final images = _getBannerImages(settingsController);

    // If the banner images changed, re-preload before resuming auto-slide
    // so we never show/slide-to an image that hasn't finished loading.
    if (!_listEquals(images, _cachedImages)) {
      _preloadImages().then((_) {
        if (mounted) _startAutoSlide();
      });
    } else {
      _startAutoSlide();
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _startAutoSlide() {
    _timer?.cancel();

    final settingsController = Get.find<SettingsDataController>();
    final images = _getBannerImages(settingsController);

    if (images.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 4), (_) async {
      if (!mounted || !_pageController.hasClients || _isAnimating) return;

      final nextIndex = (_currentIndex + 1) % images.length;

      // Never advance until the target image is fully loaded.
      // Current image stays on screen while this awaits.
      if (_imageLoadedStatus[nextIndex] != true) {
        await _precacheImage(images[nextIndex]);
        if (!mounted) return;
        _imageLoadedStatus[nextIndex] = true;
      }

      await _slideToPage(nextIndex, images);
    });
  }

  Future<void> _slideToPage(int index, List<String> images) async {
    if (_isAnimating) return;
    _isAnimating = true;

    try {
      // Double-guard: ensure target image is loaded before any visual change.
      if (_imageLoadedStatus[index] != true) {
        await _precacheImage(images[index]);
        if (!mounted) {
          _isAnimating = false;
          return;
        }
        _imageLoadedStatus[index] = true;
      }

      if (!mounted || !_pageController.hasClients) {
        _isAnimating = false;
        return;
      }

      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );

      if (mounted) {
        setState(() => _currentIndex = index);
        _savePageIndex(index);
      }
    } catch (e) {
      // Skip if animation fails
    } finally {
      _isAnimating = false;
    }
  }

  String _formatImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    if (path.startsWith('assets/')) return path;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return 'https://www.kdtdiamond.com$cleanPath';
  }

  Future<void> _precacheImage(String imagePath) async {
    try {
      final formatted = _formatImageUrl(imagePath);
      if (formatted.startsWith('http')) {
        await precacheImage(
          NetworkImage(
            formatted,
            headers: const {
              'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Referer': 'https://kdtdiamond.com/',
            },
          ),
          context,
        ).timeout(const Duration(seconds: 10));
      } else {
        await precacheImage(AssetImage(formatted), context);
      }
    } catch (_) {
      // Silently handle preload/timeout failures
    }
  }
  Future<void> _preloadImages() async {
    if (_isImageLoading) return;
    _isImageLoading = true;

    try {
      final settingsController = Get.find<SettingsDataController>();
      final images = _getBannerImages(settingsController);
      _cachedImages = images;

      // Initialize image loaded status
      _imageLoadedStatus.clear();
      for (int i = 0; i < images.length; i++) {
        _imageLoadedStatus[i] = false;
      }

      // Load all images with a maximum of 2 concurrent loads
      final List<Future> loadingFutures = [];
      for (int i = 0; i < images.length; i++) {
        loadingFutures.add(_precacheImage(images[i]).then((_) {
          _imageLoadedStatus[i] = true;
        }).catchError((_) {
          _imageLoadedStatus[i] = false;
        }));

        // Limit concurrent loads to 2
        if (loadingFutures.length >= 2 || i == images.length - 1) {
          await Future.wait(loadingFutures);
          loadingFutures.clear();
        }
      }
    } finally {
      _isImageLoading = false;
    }
  }

  List<String> _getBannerImages(SettingsDataController controller) {
    return controller.home?.bannerImages ?? [];
  }

  void _savePageIndex(int index) {
    PageStorage.of(context)?.writeState(
      context,
      index,
      identifier: "banner_page",
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      final settingsController = Get.find<SettingsDataController>();
      final images = _getBannerImages(settingsController);

      return LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isCompact = width < 360;
          final horizontalPadding = isCompact ? 16.0 : 24.0;
          final verticalPadding = isCompact ? 16.0 : 24.0;
          final bannerHeight = (width * 0.78).clamp(280.0, 420.0);

          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: Container(
              width: double.infinity,
              height: bannerHeight,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF7F7F7),
                    Color(0xFFEDEDED),
                    Color(0xFFF9F9F9),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImageSlider(images, width),
                    _buildOverlayContent(
                      isCompact: isCompact,
                      horizontalPadding: horizontalPadding,
                      verticalPadding: verticalPadding,
                      width: width,
                    ),
                    if (images.length > 1) _buildDotsIndicator(images.length),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildImageSlider(List<String> images, double width) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return PageView.builder(
      key: const PageStorageKey("banner_slider"),
      controller: _pageController,
      itemCount: images.length,
      onPageChanged: (index) {
        if (!mounted) return;
        setState(() => _currentIndex = index);
        _savePageIndex(index);

        // Preload next image in advance (for manual swipes)
        final nextIndex = (index + 1) % images.length;
        if (_imageLoadedStatus[nextIndex] != true) {
          _precacheImage(images[nextIndex]).then((_) {
            if (mounted) {
              _imageLoadedStatus[nextIndex] = true;
            }
          });
        }
      },
      itemBuilder: (context, index) {
        final imagePath = _formatImageUrl(images[index]);
        final isNetworkImage = imagePath.startsWith('http');

        if (isNetworkImage) {
          return Image.network(
            imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            headers: const {
              'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Referer': 'https://kdtdiamond.com/',
            },
            errorBuilder: (context, error, stackTrace) {
              // Debug ke liye print rakho, baad mein hata dena
              debugPrint('Banner image failed: $imagePath -> $error');
              return const SizedBox.shrink();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                if (_imageLoadedStatus[index] != true) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _imageLoadedStatus[index] = true;
                      });
                    }
                  });
                }
                return child;
              }
              return _buildLoadingPlaceholder(width);
            },
          );
        }

        return Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildDefaultImage() {
    return Image.asset(
      "assets/shapes/hero.jpg",
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildLoadingPlaceholder(double width) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.foreground.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayContent({
    required bool isCompact,
    required double horizontalPadding,
    required double verticalPadding,
    required double width,
  }) {
    final titleSize = isCompact ? 22.0 : 28.0;
    final bodySize = isCompact ? 12.0 : 13.5;
    final labelSize = isCompact ? 9.5 : 11.0;
    final settingsController = Get.find<SettingsDataController>();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildLabel(labelSize),
          const SizedBox(height: 6),
          _buildTitle(
            settingsController.getHeroTitle(),
            titleSize,
            width,
          ),
          const SizedBox(height: 10),
          _buildDescription(
            settingsController.getHeroSubtitle(),
            bodySize,
            width,
          ),
          const SizedBox(height: 18),
          _buildButtons(isCompact, settingsController),
        ],
      ),
    );
  }

  Widget _buildLabel(double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        TranslationKeys.exceptionalQuality.tr,
        style: GoogleFonts.poppins(
          color: AppColors.background,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTitle(String title, double fontSize, double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        title,
        style: GoogleFonts.lora(
          color: AppColors.background,
          fontSize: fontSize,
          height: 1.1,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.5,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDescription(String description, double fontSize, double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
      child: Text(
        description,
        style: TextStyle(
          color: AppColors.background,
          fontSize: fontSize,
          height: 1.5,
          letterSpacing: 0.3,
          fontWeight: FontWeight.w400,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDotsIndicator(int count) {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(count, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentIndex == index ? 22 : 8,
              height: 6,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? AppColors.foreground
                    : Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildButtons(bool isCompact, SettingsDataController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 0 : 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: _buildShopButton(
              isCompact: isCompact,
              buttonText: controller.getheroButtonText(),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: _buildLearnMoreButton(isCompact: isCompact),
          ),
        ],
      ),
    );
  }

  Widget _buildShopButton({
    required bool isCompact,
    required String buttonText,
  }) {
    return ElevatedButton(
      onPressed: () {
        AppNavigator.to("/navigation", arguments: {"tab": 2});
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.foreground,
        foregroundColor: AppColors.background,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 20,
          vertical: isCompact ? 10 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        minimumSize: Size(0, isCompact ? 36 : 42),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              buttonText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isCompact ? 11 : 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_forward,
            size: isCompact ? 14 : 16,
            color: AppColors.background,
          ),
        ],
      ),
    );
  }

  Widget _buildLearnMoreButton({required bool isCompact}) {
    return OutlinedButton(
      onPressed: () {
        AppNavigator.to("/diamond-education");
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.85),
        foregroundColor: Colors.black,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 20,
          vertical: isCompact ? 10 : 12,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        minimumSize: Size(0, isCompact ? 36 : 42),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          TranslationKeys.learnMore.tr,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isCompact ? 11 : 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}