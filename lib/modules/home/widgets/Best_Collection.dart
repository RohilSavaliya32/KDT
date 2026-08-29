import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kdt/utils/app_text_style.dart';
import '../../../data/Setting_Cont.dart';
import '../../../data/models/settings/home_settings_model.dart';
import '../../../utils/app_colors.dart';
import '../../Loader/Helper/Loader_helper.dart';

class CollectionsSection extends StatelessWidget {
  const CollectionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;
    final isTablet = screenWidth >= 700 && screenWidth < 1200;
    final settingsController = Get.find<SettingsDataController>();

    return Obx(() {
      final HomeSettingsModel? settings = settingsController.home;

      if (settings == null) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 0,
          vertical: isMobile ? 30.0 : 40.0,
        ),
        child: Column(
          children: [
            Text(
              "KDT Collections",
              style: AppTextStyles.lora(
                fontSize: isMobile ? 28.0 : 34.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Explore our newly launched collection",
              style: AppTextStyles.poppins(
                color: Colors.grey,
                fontSize: isMobile ? 14.0 : 16.0,
              ),
            ),
            const SizedBox(height: 30),
            isMobile
                ? _mobileLayout(settings, screenWidth)
                : isTablet
                ? _tabletLayout(settings, screenWidth)
                : _desktopLayout(settings, screenWidth),
          ],
        ),
      );
    });
  }

  // Desktop Layout (Large screens: 1200+)
  Widget _desktopLayout(HomeSettingsModel settings, double screenWidth) {
    final cardHeight = screenWidth < 1400 ? 400.0 : 470.0;

    return SizedBox(
      height: cardHeight,
      child: Row(
          children: [
            Expanded(
              flex: 4,
              child: _responsiveCard(
                settings.collectionsLeftImage ?? "",
                "Sub 50k",
                height: cardHeight,
                fontSize: screenWidth < 1400 ? 32.0 : 38.0,
                textAlignment: Alignment.bottomLeft,
                textPadding: const EdgeInsets.only(
                  bottom: 32,
                  left: 24,
                ),

                // Screenshot jaisa very dark black
                overlayColor: AppColors.black.withOpacity(0.68),
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                    child: _responsiveCard(
                      settings.collectionsTopRightImage ?? "",
                      settings.collectionsTopRightText?.isNotEmpty == true
                          ? settings.collectionsTopRightText!
                          : "Stunning Every Ear",
                      height: (cardHeight - 20) / 2,
                      fontSize: screenWidth < 1400 ? 20.0 : 24.0,
                      textAlignment: Alignment.bottomLeft,
                      textPadding: const EdgeInsets.only(
                        bottom: 20,
                        left: 20,
                      ),

                      // Screenshot jaisa light dark/grey tone
                      overlayColor: AppColors.black.withOpacity(0.12),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: _responsiveCard(
                      settings.collectionsBottomRightImage ?? "",
                      settings.collectionsBottomRightText?.isNotEmpty == true
                          ? settings.collectionsBottomRightText!
                          : "18Kt Jewellery",
                      height: (cardHeight - 20) / 2,
                      fontSize: screenWidth < 1400 ? 20.0 : 24.0,
                      textAlignment: Alignment.bottomLeft,
                      textPadding: const EdgeInsets.only(
                        bottom: 20,
                        left: 20,
                      ),

                      // Screenshot jaisa strong green
                      overlayColor: AppColors.accent.withOpacity(0.72),
                    ),
                  ),
                ],
              ),
            ),
          ],
      ),
    );
  }

  // Tablet Layout (Medium screens: 700-1200)
  Widget _tabletLayout(HomeSettingsModel settings, double screenWidth) {
    return Column(
      children: [
        SizedBox(
          height: 300.0,
          child: _responsiveCard(
            settings.collectionsLeftImage ?? "",
            "Sub 50k",
            height: 300.0,
            fontSize: 34.0,
            textAlignment: Alignment.bottomLeft,
            textPadding: const EdgeInsets.only(bottom: 24, left: 24),
            overlayColor: AppColors.black.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 220.0,
                child: _responsiveCard(
                  settings.collectionsTopRightImage ?? "",
                  settings.collectionsTopRightText?.isNotEmpty == true
                      ? settings.collectionsTopRightText!
                      : "Stunning Every Ear",
                  height: 220.0,
                  fontSize: 20.0,
                  textAlignment: Alignment.bottomLeft,
                  textPadding: const EdgeInsets.only(bottom: 16, left: 16),
                  overlayColor: AppColors.black.withOpacity(0.2),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 220.0,
                child: _responsiveCard(
                  settings.collectionsBottomRightImage ?? "",
                  settings.collectionsBottomRightText?.isNotEmpty == true
                      ? settings.collectionsBottomRightText!
                      : "18Kt Jewellery",
                  height: 220.0,
                  fontSize: 20.0,
                  textAlignment: Alignment.bottomLeft,
                  textPadding: const EdgeInsets.only(bottom: 16, left: 16),
                  overlayColor: AppColors.accent.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Mobile Layout (Small screens: <700)
  Widget _mobileLayout(HomeSettingsModel settings, double screenWidth) {
    final cardHeight = screenWidth < 400 ? 200.0 : 250.0;
    final smallCardHeight = screenWidth < 400 ? 150.0 : 180.0;

    return Column(
      children: [
        SizedBox(
          height: cardHeight,
          child: _responsiveCard(
            settings.collectionsLeftImage ?? "",
            "Sub 50k",
            height: cardHeight,
            fontSize: screenWidth < 400 ? 28.0 : 32.0,
            textAlignment: Alignment.bottomLeft,
            textPadding: const EdgeInsets.only(bottom: 16, left: 16),
            overlayColor: AppColors.black.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: smallCardHeight,
          child: _responsiveCard(
            settings.collectionsTopRightImage ?? "",
            settings.collectionsTopRightText?.isNotEmpty == true
                ? settings.collectionsTopRightText!
                : "Stunning Every Ear",
            height: smallCardHeight,
            fontSize: screenWidth < 400 ? 18.0 : 20.0,
            textAlignment: Alignment.bottomLeft,
            textPadding: const EdgeInsets.only(bottom: 12, left: 16),
            overlayColor: AppColors.black.withOpacity(0.2),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: smallCardHeight,
          child: _responsiveCard(
            settings.collectionsBottomRightImage ?? "",
            settings.collectionsBottomRightText?.isNotEmpty == true
                ? settings.collectionsBottomRightText!
                : "18Kt Jewellery",
            height: smallCardHeight,
            fontSize: screenWidth < 400 ? 18.0 : 20.0,
            textAlignment: Alignment.bottomLeft,
            textPadding: const EdgeInsets.only(bottom: 12, left: 16),
            overlayColor: AppColors.accent.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // Unified Responsive Card
  Widget _responsiveCard(
      String imageUrl,
      String title, {
        required double height,
        required double fontSize,
        required Alignment textAlignment,
        required EdgeInsets textPadding,
        Color? overlayColor,
      }) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholderCard(title, height, fontSize);
    }

    final String cleanUrl = imageUrl.trim();

    return InkWell(
      onTap: () {
        AppNavigator.to("/navigation", arguments: {"tab": 2});
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: cleanUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.grey,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    _buildPlaceholderCard(title, height, fontSize),
                httpHeaders: {
                  'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                  'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
                  'Accept-Language': 'en-US,en;q=0.9',
                  'Referer': 'https://kdtdiamond.com/',
                },
              ),
              // Color overlay
              Container(
                decoration: BoxDecoration(
                  color: overlayColor ?? AppColors.black.withOpacity(0.4),
                ),
              ),
              // Title
              Align(
                alignment: textAlignment,
                child: Padding(
                  padding: textPadding,
                  child: Text(
                    title,
                    textAlign: TextAlign.left,
                    style: AppTextStyles.lora(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
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

  // Placeholder Card
  Widget _buildPlaceholderCard(String title, double height, double fontSize) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade500,
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Icon(
                  Icons.image_outlined,
                  size: height * 0.2,
                  color: Colors.grey.shade200,
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: height * 0.08,
                left: 16,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    fontFamily: "PlayfairDisplay",
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