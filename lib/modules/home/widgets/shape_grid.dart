import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_text_style.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/app_colors.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../../translations/Translation_controllers/language_controller.dart';
import '../../translations/Translation_key/translation_keys.dart';

class ShapeGrid extends StatelessWidget {
  ShapeGrid({super.key});

  final List<Map<String, String>> shapes = const [
    {"name": "Oval", "image": "assets/shapes/oval.png"},
    {"name": "Round", "image": "assets/shapes/round.png"},
    {"name": "Emerald", "image": "assets/shapes/emerald.png"},
    {"name": "Marquise", "image": "assets/shapes/marquise.png"},
    {"name": "Radiant", "image": "assets/shapes/radiant.png"},
    {"name": "Pear", "image": "assets/shapes/pear.png"},
    {"name": "Heart", "image": "assets/shapes/heart.png"},
    {"name": "Princess", "image": "assets/shapes/princess.png"},
    {"name": "Cushion", "image": "assets/shapes/cushion.png"},
  ];

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
                padding: EdgeInsets.symmetric(horizontal: vm.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(vm),
                    SizedBox(height: vm.titleSpacing),
                    _buildGrid(vm),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTitle(_ViewModel vm) {
    return Text(
      TranslationKeys.shopDiamondsByShape.tr,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.lora(
        fontSize: vm.titleSize,
        fontWeight: FontWeight.w500,
        color: AppColors.foreground,
      ),
    );
  }

  Widget _buildGrid(_ViewModel vm) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shapes.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: vm.crossAxisCount,
        childAspectRatio: vm.childAspectRatio,
        crossAxisSpacing: vm.gridSpacing,
        mainAxisSpacing: vm.gridSpacing,
      ),
      itemBuilder: (context, index) {
        return _buildShapeCard(
          context: context,
          shape: shapes[index],
          index: index,
          vm: vm,
        );
      },
    );
  }

  Widget _buildShapeCard({
    required BuildContext context,
    required Map<String, String> shape,
    required int index,
    required _ViewModel vm,
  }) {
    return InkWell(
      onTap: () async {
        print("SHAPE CLICKED => $index");

        AppNavigator.offAll(
          AppRoutes.navigation,
          arguments: {
            "tab": 2,
            "selectedShapeIndex": index,
          },
        );
      },
      borderRadius: BorderRadius.circular(vm.cardBorderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(vm.cardBorderRadius),
          border: Border.all(
            color: const Color(0xFFDCDCDC),
            width: vm.borderWidth,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(vm.imagePadding),
                child: Image.asset(
                  shape["image"]!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.diamond,
                      size: vm.errorIconSize,
                      color: AppColors.foreground,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: vm.textHorizontalPadding,
              ),
              child: Text(
                _getTranslatedShapeName(shape["name"]!),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.poppins(
                  fontSize: vm.labelSize,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111111),
                ),
              ),
            ),
            SizedBox(height: vm.bottomSpacing),
          ],
        ),
      ),
    );
  }

  String _getTranslatedShapeName(String shapeName) {
    switch (shapeName) {
      case 'Oval':
        return TranslationKeys.shapeOval.tr;
      case 'Round':
        return TranslationKeys.shapeRound.tr;
      case 'Emerald':
        return TranslationKeys.shapeEmerald.tr;
      case 'Marquise':
        return TranslationKeys.shapeMarquise.tr;
      case 'Radiant':
        return TranslationKeys.shapeRadiant.tr;
      case 'Pear':
        return TranslationKeys.shapePear.tr;
      case 'Heart':
        return TranslationKeys.shapeHeart.tr;
      case 'Princess':
        return TranslationKeys.shapePrincess.tr;
      case 'Cushion':
        return TranslationKeys.shapeCushion.tr;
      default:
        return shapeName;
    }
  }
}

class _ViewModel {
  final double width;

  const _ViewModel(this.width);

  // Breakpoints
  bool get isVerySmall => width < 380;
  bool get isMobile => width >= 380 && width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;

  // Main Padding
  double get horizontalPadding {
    return 0;
  }

  // Title
  double get titleSize {
    if (isVerySmall) return 20;
    if (isMobile) return 24;
    if (isTablet) return 28;
    return 32;
  }

  double get titleSpacing {
    if (isVerySmall) return 14;
    if (isMobile) return 18;
    if (isTablet) return 22;
    return 24;
  }

  // Grid - Fixed 3 columns
  double get childAspectRatio {
    if (isVerySmall) return 0.72;
    if (isMobile) return 0.76;
    if (isTablet) return 0.80;
    return 0.82;
  }

  double get gridSpacing {
    if (isVerySmall) return 8;
    if (isMobile) return 10;
    if (isTablet) return 12;
    return 14;
  }

  // Card
  double get cardBorderRadius {
    if (isVerySmall) return 10;
    if (isMobile) return 14;
    if (isTablet) return 16;
    return 18;
  }

  double get borderWidth {
    if (isVerySmall) return 0.8;
    return 1.0;
  }

  // Image
  double get imagePadding {
    if (isVerySmall) return 6;
    if (isMobile) return 8;
    if (isTablet) return 10;
    return 12;
  }

  double get errorIconSize {
    if (isVerySmall) return 20;
    if (isMobile) return 24;
    if (isTablet) return 28;
    return 32;
  }

  // Label
  double get labelSize {
    if (isVerySmall) return 11;
    if (isMobile) return 12;
    if (isTablet) return 13;
    return 14;
  }

  double get textHorizontalPadding {
    if (isVerySmall) return 4;
    if (isMobile) return 6;
    return 8;
  }

  double get bottomSpacing {
    if (isVerySmall) return 4;
    if (isMobile) return 6;
    return 8;
  }

  int get crossAxisCount {
    if (isVerySmall) return 3;
    if (isMobile) return 4;
    if (isTablet) return 5;
    return 6;
  }
}
