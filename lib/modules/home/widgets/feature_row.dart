import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/app_colors.dart';
import '../../translations/Translation_controllers/language_controller.dart';
import '../../translations/Translation_key/translation_keys.dart';

class FeatureRow extends StatelessWidget {
  const FeatureRow({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final _ViewModel vm = _ViewModel(constraints.maxWidth);

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: GetBuilder<LanguageController>(
            builder: (langController) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: vm.horizontalPadding,
                  vertical: vm.verticalPadding,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 700;

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isMobile ? 2 : 4,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: isMobile ? 2.6 : 3.8,
                      children: [
                        _buildFeatureItem(
                          image: "assets/web/icons/certified-footer.png",
                          title: TranslationKeys.certifiedAuthentic.tr,
                          subtitle: TranslationKeys.giaIgiVerified.tr,
                          vm: vm,
                        ),

                        _buildFeatureItem(
                          image: "assets/web/icons/shipping-upper.png",
                          title: TranslationKeys.freeShipping.tr,
                          subtitle: TranslationKeys.worldwideInsured.tr,
                          vm: vm,
                        ),

                        _buildFeatureItem(
                          image: "assets/web/icons/secure-payment-lower.png",
                          title: TranslationKeys.lifetimeWarranty.tr,
                          subtitle: TranslationKeys.onAllDiamonds.tr,
                          vm: vm,
                        ),

                        _buildFeatureItem(
                          image: "assets/web/icons/return-footer.png",
                          title: TranslationKeys.dayReturns.tr,
                          subtitle: TranslationKeys.noQuestionsAsked.tr,
                          vm: vm,
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem({
    required String image,
    required String title,
    required String subtitle,
    required _ViewModel vm,
  }) {
    return SizedBox(
      width: vm.itemWidth + 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            image,
            width: vm.iconSize,
            height: vm.iconSize,
            fit: BoxFit.contain,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: vm.titleSize + 4,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: vm.subtitleSize + 3,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewModel {
  final double width;

  const _ViewModel(this.width);

  bool get isVerySmall => width < 400;
  bool get isMobile => width >= 400 && width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;

  double get horizontalPadding {
    return 0;
  }

  double get verticalPadding {
    if (isVerySmall) return 12;
    if (isMobile) return 16;
    if (isTablet) return 20;
    return 24;
  }

  double get itemWidth {
    if (isVerySmall) return 120;
    if (isMobile) return 135;
    if (isTablet) return 155;
    return 170;
  }

  double get itemHeight {
    if (isVerySmall) return 102;
    if (isMobile) return 116;
    if (isTablet) return 124;
    return 128;
  }

  double get itemSpacing {
    if (isVerySmall) return 8;
    if (isMobile) return 10;
    if (isTablet) return 12;
    return 10;
  }

  double get itemHorizontalPadding {
    if (isVerySmall) return 6;
    if (isMobile) return 8;
    if (isTablet) return 10;
    return 8;
  }

  double get itemVerticalPadding {
    if (isVerySmall) return 8;
    if (isMobile) return 10;
    if (isTablet) return 12;
    return 12;
  }

  double get iconSize {
    if (isVerySmall) return 36;
    if (isMobile) return 40;
    if (isTablet) return 44;
    return 46;
  }

  double get iconSpacing {
    if (isVerySmall) return 6;
    if (isMobile) return 8;
    if (isTablet) return 9;
    return 10;
  }

  double get subtitleSpacing {
    if (isVerySmall) return 2;
    if (isMobile) return 3;
    if (isTablet) return 4;
    return 4;
  }

  double get titleSize {
    if (isVerySmall) return 9;
    if (isMobile) return 10;
    if (isTablet) return 10.5;
    return 11;
  }

  double get subtitleSize {
    if (isVerySmall) return 7.5;
    if (isMobile) return 8;
    if (isTablet) return 8.5;
    return 9;
  }

  double get borderRadius {
    if (isVerySmall) return 12;
    if (isMobile) return 14;
    if (isTablet) return 16;
    return 18;
  }

  double get borderWidth {
    if (isVerySmall) return 0.8;
    if (isMobile) return 0.8;
    return 1;
  }
}