import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kdt/utils/app_colors.dart';

import '../../Loader/Helper/Loader_helper.dart';
import '../../translations/Translation_controllers/language_controller.dart';
import '../../translations/Translation_key/translation_keys.dart';

class CollectionBanner extends StatelessWidget {
  const CollectionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 768;

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
              vertical: 20,
            ),
            child: isMobile
                ? Column(
              children: [
                _buildCollectionCard(isGreen: true),
                const SizedBox(height: 16),
                _buildCollectionCard(isGreen: false),
              ],
            )
                : Row(
              children: [
                Expanded(
                  child: _buildCollectionCard(isGreen: true),
                ),
                const SizedBox(width: 28),
                Expanded(
                  child: _buildCollectionCard(isGreen: false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollectionCard({
    required bool isGreen,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmall = constraints.maxWidth < 400;
        final bool isVerySmall = constraints.maxWidth < 320;

        final ResponsiveSizes sizes = ResponsiveSizes(
          isSmall: isSmall,
          isVerySmall: isVerySmall,
        );

        return Container(
          height: sizes.height,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.background,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                Image.asset(
                  isGreen
                      ? 'assets/shapes/lab-grown.webp'
                      : 'assets/shapes/natural.jpg',
                  fit: BoxFit.cover,
                ),

                // Dark overlay for better text visibility
                Container(
                  color: isGreen
                      ? Colors.black.withOpacity(0.4)
                      : Colors.black.withOpacity(0.3),
                ),

                // Content
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: sizes.horizontalPadding,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 350,
                      ),
                      child: GetBuilder<LanguageController>(
                        builder: (langController) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // COLLECTION Label
                              _buildCollectionLabel(
                                isGreen: isGreen,
                                fontSize: sizes.labelSize,
                              ),

                              SizedBox(
                                height: sizes.spacingSmall,
                              ),

                              // Title
                              _buildTitle(
                                isGreen: isGreen,
                                fontSize: sizes.titleSize,
                              ),

                              SizedBox(
                                height: sizes.spacingMedium,
                              ),

                              // Subtitle
                              _buildSubtitle(
                                isGreen: isGreen,
                                fontSize: sizes.subtitleSize,
                              ),

                              SizedBox(
                                height: sizes.spacingLarge,
                              ),

                              // CTA Button
                              _buildCTA(
                                isGreen: isGreen,
                                fontSize: sizes.ctaSize,
                                iconSize: sizes.iconSize,
                                isSmall: isSmall,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollectionLabel({
    required bool isGreen,
    required double fontSize,
  }) {
    return Text(
      TranslationKeys.collection.tr,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        letterSpacing: 5,
        fontWeight: FontWeight.w500,
      ).copyWith(
        fontSize: fontSize,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTitle({
    required bool isGreen,
    required double fontSize,
  }) {
    return Text(
      isGreen
          ? TranslationKeys.labGrownDiamonds.tr
          : TranslationKeys.naturalDiamonds.tr,
      textAlign: TextAlign.center,
      style: GoogleFonts.lora(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: Colors.white,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitle({
    required bool isGreen,
    required double fontSize,
  }) {
    return Text(
      isGreen
          ? TranslationKeys.labGrownSubtitle.tr
          : TranslationKeys.naturalSubtitle.tr,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        height: 1.5,
        color: Colors.white.withOpacity(0.9),
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCTA({
    required bool isGreen,
    required double fontSize,
    required double iconSize,
    required bool isSmall,
  }) {
    final double underlineWidth = isSmall ? 145 : 180;

    return InkWell(
      onTap: () {
        AppNavigator.offAll(
          "/navigation",
          arguments: {
            "tab": 2,
            "labGrown": isGreen,
          },
        );
      },

      // Smooth rounded tap area
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        child: GetBuilder<LanguageController>(
          builder: (langController) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      TranslationKeys.exploreCollection.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: iconSize,
                      color: Colors.white,
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Container(
                  width: underlineWidth,
                  height: 1,
                  color: Colors.white,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ================================================================
// Responsive Sizes
// ================================================================

class ResponsiveSizes {
  final bool isSmall;
  final bool isVerySmall;

  ResponsiveSizes({
    required this.isSmall,
    required this.isVerySmall,
  });

  double get height => isSmall ? 240 : 320;

  double get horizontalPadding => isSmall ? 20 : 40;

  double get labelSize =>
      isVerySmall ? 9 : (isSmall ? 11 : 14);

  double get titleSize =>
      isVerySmall ? 20 : (isSmall ? 24 : 38);

  double get subtitleSize =>
      isVerySmall ? 11 : (isSmall ? 13 : 16);

  double get ctaSize =>
      isVerySmall ? 11 : (isSmall ? 13 : 16);

  double get iconSize =>
      isVerySmall ? 14 : (isSmall ? 16 : 18);

  double get spacingSmall =>
      isVerySmall ? 10 : (isSmall ? 14 : 22);

  double get spacingMedium =>
      isVerySmall ? 8 : (isSmall ? 12 : 18);

  double get spacingLarge =>
      isVerySmall ? 16 : (isSmall ? 22 : 30);
}