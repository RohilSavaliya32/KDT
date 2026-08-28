import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_text_style.dart';
import '../../../utils/app_colors.dart';
import '../../translations/Translation_key/translation_keys.dart';
import '../controllers/diamond_education_controller.dart';

const Color _cardBorder = Color(0xFFEAEAEA);
const Color _accentBg = Color(0xFFE7EEEA);
const Color _accentBorder = Color(0xFFD6DDD7);

class _FontSizes {
  static const double heroTitle = 28;
  static const double sectionTitle = 24;
  static const double subtitleTitle = 20;
  static const double bodyLarge = 15;
  static const double bodyRegular = 14;
  static const double bodySmall = 13;
  static const double bodyExtraSmall = 12;
  static const double featureTitle = 16;
  static const double cardTitle = 17;
  static const double mobileHeroTitle = 24;
  static const double mobileSectionTitle = 22;
  static const double mobileBodyLarge = 14;
  static const double mobileBodyRegular = 13;
  static const double mobileBodySmall = 12;
  static const double xsHeroTitle = 20;
  static const double xsSectionTitle = 18;
  static const double xsBodyLarge = 12;
  static const double xsBodyRegular = 11;
  static const double xsBodySmall = 10;
}

class DiamondEducationView extends GetView<DiamondEducationController> {
  const DiamondEducationView({super.key});

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
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isMobile = width < 600;
              final isTablet = width >= 600 && width < 900;
              final isDesktop = width >= 900;
              final isExtraSmall = width < 380;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _HeroSection(
                      controller: controller,
                      isMobile: isMobile,
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                      isExtraSmall: isExtraSmall,
                    ),
                    _InfoSection(
                      controller: controller,
                      isLabGrown: true,
                      isMobile: isMobile,
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                      isExtraSmall: isExtraSmall,
                    ),
                    _FeatureRow(
                      features: controller.labFeatures,
                      isMobile: isMobile,
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                      isExtraSmall: isExtraSmall,
                    ),
                    _InfoSection(
                      controller: controller,
                      isLabGrown: false,
                      isMobile: isMobile,
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                      isExtraSmall: isExtraSmall,
                    ),
                    _ComparisonSection(
                      controller: controller,
                      isMobile: isMobile,
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                      isExtraSmall: isExtraSmall,
                    ),
                    _FourCsSection(
                      controller: controller,
                      isMobile: isMobile,
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                      isExtraSmall: isExtraSmall,
                    ),
                    _CertificationSection(
                      controller: controller,
                      isMobile: isMobile,
                      isTablet: isTablet,
                      isDesktop: isDesktop,
                      isExtraSmall: isExtraSmall,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.black),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: Get.back,
      ),
      title: Text(
        TranslationKeys.diamondEducation.tr,
        style: AppTextStyles.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final DiamondEducationController controller;
  final bool isMobile, isTablet, isDesktop, isExtraSmall;

  const _HeroSection({
    required this.controller,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.isExtraSmall,
  });

  double _getFontSize(double mobile, double tablet, double desktop) {
    if (isExtraSmall) return mobile * 0.85;
    if (isMobile) return mobile;
    if (isTablet) return (mobile + desktop) / 2;
    return desktop;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF5F4F0), Color(0xFFEBEAE4)],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isExtraSmall ? 16 : (isMobile ? 24 : 40),
        vertical: isExtraSmall ? 24 : (isMobile ? 40 : 60),
      ),
      child: Column(
        children: [
          Text(
            controller.heroTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.lora(
              fontSize: _getFontSize(
                _FontSizes.mobileHeroTitle,
                _FontSizes.mobileHeroTitle + 2,
                _FontSizes.heroTitle,
              ),
              fontWeight: FontWeight.w500,
              color: AppColors.foreground,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isExtraSmall ? 300 : (isMobile ? 500 : 720),
            ),
            child: Text(
              controller.heroDescription,
              textAlign: TextAlign.center,
              style: AppTextStyles.poppins(
                fontSize: _getFontSize(
                  isExtraSmall ? _FontSizes.xsBodyLarge : _FontSizes.mobileBodyLarge,
                  _FontSizes.mobileBodyLarge + 1,
                  _FontSizes.bodyLarge,
                ),
                height: 1.6,
                color: const Color(0xFF555555),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final DiamondEducationController controller;
  final bool isLabGrown;
  final bool isMobile, isTablet, isDesktop, isExtraSmall;

  const _InfoSection({
    required this.controller,
    required this.isLabGrown,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.isExtraSmall,
  });

  double _getFontSize(double mobile, double tablet, double desktop) {
    if (isExtraSmall) return mobile * 0.85;
    if (isMobile) return mobile;
    if (isTablet) return (mobile + desktop) / 2;
    return desktop;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;

    final title = isLabGrown ? controller.labGrownTitle : controller.naturalTitle;
    final description = isLabGrown ? controller.labGrownDescription : controller.naturalDescription;
    final image = isLabGrown ? controller.labGrownImage : controller.naturalImage;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isExtraSmall ? 16 : (isMobile ? 24 : 40),
        vertical: isExtraSmall ? 20 : (isMobile ? 28 : 40),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isExtraSmall ? 380 : 1180),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textBlock = _TextBlock(
                controller: controller,
                isLabGrown: isLabGrown,
                isMobile: isMobile,
                isTablet: isTablet,
                isDesktop: isDesktop,
                isExtraSmall: isExtraSmall,
              );
              final accentBox = Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD8E8DE)),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: AspectRatio(
                    aspectRatio: isExtraSmall ? 1.2 : 1,
                    child: Image.asset(image, fit: BoxFit.cover),
                  ),
                ),
              );

              if (isWide && !isExtraSmall) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 1, child: textBlock),
                      const SizedBox(width: 40),
                      Expanded(flex: 1, child: accentBox),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  textBlock,
                  SizedBox(height: isExtraSmall ? 16 : 24),
                  accentBox,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final DiamondEducationController controller;
  final bool isLabGrown;
  final bool isMobile, isTablet, isDesktop, isExtraSmall;

  const _TextBlock({
    required this.controller,
    required this.isLabGrown,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.isExtraSmall,
  });

  double _getFontSize(double mobile, double tablet, double desktop) {
    if (isExtraSmall) return mobile * 0.85;
    if (isMobile) return mobile;
    if (isTablet) return (mobile + desktop) / 2;
    return desktop;
  }

  @override
  Widget build(BuildContext context) {
    final title = isLabGrown ? controller.labGrownTitle : controller.naturalTitle;
    final description = isLabGrown ? controller.labGrownDescription : controller.naturalDescription;
    final iconPath = isLabGrown
        ? "assets/web/education/lab-grown.png"
        : "assets/web/education/natural-diamond.png";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: isExtraSmall ? 30 : (isMobile ? 36 : 42),
              height: isExtraSmall ? 30 : (isMobile ? 36 : 42),
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.lora(
                  fontSize: _getFontSize(
                    isExtraSmall ? _FontSizes.xsSectionTitle : _FontSizes.mobileSectionTitle,
                    _FontSizes.mobileSectionTitle + 1,
                    _FontSizes.sectionTitle,
                  ),
                  fontWeight: FontWeight.w500,
                  color: AppColors.foreground,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: AppTextStyles.poppins(
            fontSize: _getFontSize(
              isExtraSmall ? _FontSizes.xsBodyRegular : _FontSizes.mobileBodyRegular,
              _FontSizes.mobileBodyRegular + 0.5,
              _FontSizes.bodyRegular,
            ),
            height: 1.75,
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 24),
        if (isLabGrown) ...[
          Text(
            controller.methodsTitle,
            style: AppTextStyles.poppins(
              fontSize: _getFontSize(
                isExtraSmall ? _FontSizes.xsBodyRegular : _FontSizes.mobileBodyRegular,
                _FontSizes.mobileBodyRegular + 0.5,
                _FontSizes.bodyRegular,
              ),
              fontWeight: FontWeight.w500,
              color: AppColors.foreground,
            ),
          ),
          SizedBox(height: isExtraSmall ? 12 : 18),
          Container(
            padding: EdgeInsets.only(left: isExtraSmall ? 8 : 16),
            decoration: const BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.accent, width: 2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.hphtTitle,
                  style: AppTextStyles.poppins(
                    fontSize: _getFontSize(
                      isExtraSmall ? _FontSizes.xsBodyLarge : _FontSizes.mobileBodyLarge,
                      _FontSizes.mobileBodyLarge + 0.5,
                      _FontSizes.bodyLarge,
                    ),
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  controller.hphtDescription,
                  style: AppTextStyles.poppins(
                    fontSize: _getFontSize(
                      isExtraSmall ? _FontSizes.xsBodyRegular : _FontSizes.mobileBodyRegular,
                      _FontSizes.mobileBodyRegular + 0.5,
                      _FontSizes.bodyRegular,
                    ),
                    color: AppColors.mutedForeground,
                    height: 1.7,
                  ),
                ),
                SizedBox(height: isExtraSmall ? 12 : 18),
                Text(
                  controller.cvdTitle,
                  style: AppTextStyles.poppins(
                    fontSize: _getFontSize(
                      isExtraSmall ? _FontSizes.xsBodyLarge : _FontSizes.mobileBodyLarge,
                      _FontSizes.mobileBodyLarge + 0.5,
                      _FontSizes.bodyLarge,
                    ),
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  controller.cvdDescription,
                  style: AppTextStyles.poppins(
                    fontSize: _getFontSize(
                      isExtraSmall ? _FontSizes.xsBodyRegular : _FontSizes.mobileBodyRegular,
                      _FontSizes.mobileBodyRegular + 0.5,
                      _FontSizes.bodyRegular,
                    ),
                    color: AppColors.mutedForeground,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            controller.labGrownResult,
            style: AppTextStyles.poppins(
              fontSize: _getFontSize(
                isExtraSmall ? _FontSizes.xsBodyRegular : _FontSizes.mobileBodyRegular,
                _FontSizes.mobileBodyRegular + 0.5,
                _FontSizes.bodyRegular,
              ),
              color: AppColors.mutedForeground,
              height: 1.8,
            ),
          ),
        ],
        if (!isLabGrown) ...[
          Text(
            controller.formationTitle,
            style: AppTextStyles.poppins(
              fontSize: _getFontSize(
                isExtraSmall ? _FontSizes.xsBodyRegular : _FontSizes.mobileBodyRegular,
                _FontSizes.mobileBodyRegular + 0.5,
                _FontSizes.bodyRegular,
              ),
              fontWeight: FontWeight.w500,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.formationDescription,
            style: AppTextStyles.poppins(
              fontSize: _getFontSize(
                isExtraSmall ? _FontSizes.xsBodyRegular : _FontSizes.mobileBodyRegular,
                _FontSizes.mobileBodyRegular + 0.5,
                _FontSizes.bodyRegular,
              ),
              color: AppColors.mutedForeground,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            controller.journeyTitle,
            style: AppTextStyles.poppins(
              fontSize: _getFontSize(
                isExtraSmall ? _FontSizes.xsBodyRegular : _FontSizes.mobileBodyRegular,
                _FontSizes.mobileBodyRegular + 0.5,
                _FontSizes.bodyRegular,
              ),
              fontWeight: FontWeight.w500,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.journeyDescription,
            style: AppTextStyles.poppins(
              fontSize: _getFontSize(
                isExtraSmall ? _FontSizes.xsBodyRegular : _FontSizes.mobileBodyRegular,
                _FontSizes.mobileBodyRegular + 0.5,
                _FontSizes.bodyRegular,
              ),
              color: AppColors.mutedForeground,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            controller.naturalUniqueness,
            style: AppTextStyles.poppins(
              fontSize: _getFontSize(
                isExtraSmall ? _FontSizes.xsBodyRegular : _FontSizes.mobileBodyRegular,
                _FontSizes.mobileBodyRegular + 0.5,
                _FontSizes.bodyRegular,
              ),
              color: AppColors.mutedForeground,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            controller.naturalLegacy,
            style: AppTextStyles.poppins(
              fontSize: _getFontSize(
                isExtraSmall ? _FontSizes.xsBodyRegular : _FontSizes.mobileBodyRegular,
                _FontSizes.mobileBodyRegular + 0.5,
                _FontSizes.bodyRegular,
              ),
              color: AppColors.mutedForeground,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 32),
          _NaturalDiamondFeatureRow(
            features: controller.naturalFeatures,
            isMobile: isMobile,
            isTablet: isTablet,
            isDesktop: isDesktop,
            isExtraSmall: isExtraSmall,
          ),
        ],
      ],
    );
  }
}

class _NaturalDiamondFeatureRow extends StatelessWidget {
  final List<Map<String, String>> features;
  final bool isMobile, isTablet, isDesktop, isExtraSmall;

  const _NaturalDiamondFeatureRow({
    required this.features,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.isExtraSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: _ResponsiveCards(
        items: features,
        isMobile: isMobile,
        isTablet: isTablet,
        isDesktop: isDesktop,
        isExtraSmall: isExtraSmall,
        builder: (item) => Container(
          height: isExtraSmall ? 240 : (isMobile ? 280 : 310),
          padding: EdgeInsets.symmetric(
            horizontal: isExtraSmall ? 12 : (isMobile ? 18 : 24),
            vertical: isExtraSmall ? 16 : (isMobile ? 20 : 28),
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _cardBorder),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                offset: const Offset(0, 4),
                color: const Color(0xFF000000).withOpacity(0.015),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  item['icon']!,
                  width: isExtraSmall ? 40 : (isMobile ? 50 : 60),
                  height: isExtraSmall ? 40 : (isMobile ? 50 : 60),
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 18),
                Text(
                  item['title']!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.lora(
                    fontSize: isExtraSmall ? 14 : (isMobile ? _FontSizes.mobileBodyLarge : _FontSizes.featureTitle),
                    fontWeight: FontWeight.w500,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item['description']!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.poppins(
                    fontSize: isExtraSmall ? _FontSizes.xsBodyRegular : _FontSizes.bodyRegular,
                    color: AppColors.mutedForeground,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final List<Map<String, String>> features;
  final bool isMobile, isTablet, isDesktop, isExtraSmall;

  const _FeatureRow({
    required this.features,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.isExtraSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isExtraSmall ? 16 : (isMobile ? 24 : 40),
        vertical: isExtraSmall ? 4 : (isMobile ? 8 : 4),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isExtraSmall ? 380 : 1180),
          child: _ResponsiveCards(
            items: features,
            isMobile: isMobile,
            isTablet: isTablet,
            isDesktop: isDesktop,
            isExtraSmall: isExtraSmall,
            builder: (item) => Container(
              padding: EdgeInsets.all(isExtraSmall ? 12 : (isMobile ? 16 : 18)),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _cardBorder),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    color: const Color(0xFF000000).withOpacity(0.015),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      item['icon']!,
                      width: isExtraSmall ? 35 : (isMobile ? 45 : 50),
                      height: isExtraSmall ? 35 : (isMobile ? 45 : 50),
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      item['title']!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.lora(
                        fontSize: isExtraSmall ? 14 : (isMobile ? _FontSizes.mobileBodyLarge : _FontSizes.featureTitle),
                        fontWeight: FontWeight.w500,
                        color: AppColors.foreground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item['description']!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.poppins(
                        fontSize: isExtraSmall ? _FontSizes.xsBodyRegular : _FontSizes.bodyRegular,
                        color: AppColors.mutedForeground,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ComparisonSection extends StatelessWidget {
  final DiamondEducationController controller;
  final bool isMobile, isTablet, isDesktop, isExtraSmall;

  const _ComparisonSection({
    required this.controller,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.isExtraSmall,
  });

  double _getFontSize(double mobile, double tablet, double desktop) {
    if (isExtraSmall) return mobile * 0.85;
    if (isMobile) return mobile;
    if (isTablet) return (mobile + desktop) / 2;
    return desktop;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isExtraSmall ? 16 : (isMobile ? 24 : 40),
        vertical: isExtraSmall ? 20 : (isMobile ? 28 : 40),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isExtraSmall ? 380 : 1180),
          child: Column(
            children: [
              Text(
                controller.comparisonTitle,
                style: AppTextStyles.lora(
                  fontSize: _getFontSize(
                    isExtraSmall ? _FontSizes.xsSectionTitle : _FontSizes.mobileSectionTitle,
                    _FontSizes.mobileSectionTitle + 1,
                    _FontSizes.sectionTitle,
                  ),
                  fontWeight: FontWeight.w500,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                controller.comparisonDescription,
                textAlign: TextAlign.center,
                style: AppTextStyles.poppins(
                  fontSize: _getFontSize(
                    isExtraSmall ? _FontSizes.xsBodySmall : _FontSizes.mobileBodySmall,
                    _FontSizes.mobileBodySmall + 0.5,
                    _FontSizes.bodySmall,
                  ),
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: isExtraSmall ? 380 : (isMobile ? 520 : 720),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _cardBorder),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                          color: const Color(0xFF000000).withOpacity(0.015),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: DataTable(
                        columnSpacing: isExtraSmall ? 8 : (isMobile ? 16 : 24),
                        headingRowColor: const MaterialStatePropertyAll(AppColors.accent),
                        dataRowMaxHeight: isExtraSmall ? 32 : 48,
                        dataRowMinHeight: isExtraSmall ? 28 : 42,
                        headingTextStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: isExtraSmall ? 9 : (isMobile ? _FontSizes.bodyExtraSmall - 1 : _FontSizes.bodyExtraSmall),
                        ),
                        columns: const [
                          DataColumn(label: Text('PROPERTY')),
                          DataColumn(label: Text('NATURAL')),
                          DataColumn(label: Text('LAB-GROWN')),
                        ],
                        rows: controller.comparisonData.map((r) => DataRow(
                          cells: [
                            DataCell(Text(
                              r['property']!,
                              style: AppTextStyles.poppins(
                                fontSize: isExtraSmall ? _FontSizes.xsBodySmall : _FontSizes.bodyExtraSmall,
                              ),
                            )),
                            DataCell(Text(
                              r['natural']!,
                              style: AppTextStyles.poppins(
                                fontSize: isExtraSmall ? _FontSizes.xsBodySmall : _FontSizes.bodyExtraSmall,
                              ),
                            )),
                            DataCell(Text(
                              r['labGrown']!,
                              style: AppTextStyles.poppins(
                                fontSize: isExtraSmall ? _FontSizes.xsBodySmall : _FontSizes.bodyExtraSmall,
                              ),
                            )),
                          ],
                        )).toList(),
                      ),
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

class _FourCsSection extends StatelessWidget {
  final DiamondEducationController controller;
  final bool isMobile, isTablet, isDesktop, isExtraSmall;

  const _FourCsSection({
    required this.controller,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.isExtraSmall,
  });

  double _getFontSize(double mobile, double tablet, double desktop) {
    if (isExtraSmall) return mobile * 0.85;
    if (isMobile) return mobile;
    if (isTablet) return (mobile + desktop) / 2;
    return desktop;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isExtraSmall ? 16 : (isMobile ? 24 : 40),
        vertical: isExtraSmall ? 20 : (isMobile ? 28 : 40),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isExtraSmall ? 380 : 1180),
          child: Column(
            children: [
              Text(
                controller.fourCsTitle,
                style: AppTextStyles.lora(
                  fontSize: _getFontSize(
                    isExtraSmall ? _FontSizes.xsSectionTitle : _FontSizes.mobileSectionTitle,
                    _FontSizes.mobileSectionTitle + 1,
                    _FontSizes.sectionTitle,
                  ),
                  fontWeight: FontWeight.w500,
                  color: AppColors.foreground,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                controller.fourCsDescription,
                textAlign: TextAlign.center,
                style: AppTextStyles.poppins(
                  fontSize: _getFontSize(
                    isExtraSmall ? _FontSizes.xsBodySmall : _FontSizes.mobileBodySmall,
                    _FontSizes.mobileBodySmall + 0.5,
                    _FontSizes.bodySmall,
                  ),
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 20),
              _ResponsiveCards(
                items: controller.fourCsData,
                isMobile: isMobile,
                isTablet: isTablet,
                isDesktop: isDesktop,
                isExtraSmall: isExtraSmall,
                builder: (item) => Container(
                  padding: EdgeInsets.all(isExtraSmall ? 12 : (isMobile ? 16 : 18)),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _cardBorder),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        color: const Color(0xFF000000).withOpacity(0.015),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isExtraSmall ? 30 : (isMobile ? 36 : 40),
                        height: isExtraSmall ? 30 : (isMobile ? 36 : 40),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _accentBg,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item['title']!.characters.first,
                          style: AppTextStyles.lora(
                            fontSize: isExtraSmall ? 12 : (isMobile ? 14 : 16),
                            fontWeight: FontWeight.w500,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['title']!,
                        style: AppTextStyles.lora(
                          fontSize: isExtraSmall ? 14 : (isMobile ? _FontSizes.mobileBodyLarge : _FontSizes.cardTitle),
                          fontWeight: FontWeight.w500,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['description']!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.poppins(
                          fontSize: isExtraSmall ? _FontSizes.xsBodyRegular : _FontSizes.bodyExtraSmall,
                          color: AppColors.mutedForeground,
                          height: 1.5,
                        ),
                      ),
                    ],
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

class _CertificationSection extends StatelessWidget {
  final DiamondEducationController controller;
  final bool isMobile, isTablet, isDesktop, isExtraSmall;

  const _CertificationSection({
    required this.controller,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.isExtraSmall,
  });

  double _getFontSize(double mobile, double tablet, double desktop) {
    if (isExtraSmall) return mobile * 0.85;
    if (isMobile) return mobile;
    if (isTablet) return (mobile + desktop) / 2;
    return desktop;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isExtraSmall ? 16 : (isMobile ? 24 : 40),
        vertical: isExtraSmall ? 20 : (isMobile ? 28 : 40),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isExtraSmall ? 380 : 1180),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              isExtraSmall ? 16 : (isMobile ? 20 : 28),
            ),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: isExtraSmall ? 28 : (isMobile ? 36 : 40),
                  color: AppColors.background.withOpacity(0.95),
                ),
                const SizedBox(height: 10),
                Text(
                  controller.certifiedTitle,
                  style: AppTextStyles.lora(
                    fontSize: _getFontSize(
                      isExtraSmall ? _FontSizes.xsSectionTitle : _FontSizes.mobileSectionTitle,
                      _FontSizes.mobileSectionTitle + 1,
                      _FontSizes.sectionTitle,
                    ),
                    fontWeight: FontWeight.w500,
                    color: AppColors.background,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  controller.certifiedDescription,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.poppins(
                    fontSize: _getFontSize(
                      isExtraSmall ? _FontSizes.xsBodyRegular : _FontSizes.mobileBodyRegular,
                      _FontSizes.mobileBodyRegular + 0.5,
                      _FontSizes.bodyRegular,
                    ),
                    color: AppColors.background.withOpacity(0.88),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: isExtraSmall ? 8 : 16,
                  runSpacing: isExtraSmall ? 8 : 16,
                  alignment: WrapAlignment.center,
                  children: controller.certificationData.map((item) =>
                      _MiniCertCard(
                        title: item['title']!,
                        text: item['description']!,
                        isMobile: isMobile,
                        isExtraSmall: isExtraSmall,
                      )
                  ).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniCertCard extends StatelessWidget {
  final String title;
  final String text;
  final bool isMobile, isExtraSmall;

  const _MiniCertCard({
    required this.title,
    required this.text,
    required this.isMobile,
    required this.isExtraSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isExtraSmall ? 140 : (isMobile ? 160 : 200),
      padding: EdgeInsets.all(isExtraSmall ? 10 : (isMobile ? 14 : 16)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: AppTextStyles.lora(
              fontSize: isExtraSmall ? 14 : (isMobile ? 16 : 18),
              fontWeight: FontWeight.w600,
              color: AppColors.background,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: AppTextStyles.poppins(
              fontSize: isExtraSmall ? _FontSizes.xsBodySmall : _FontSizes.bodyExtraSmall,
              color: AppColors.background.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveCards<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item) builder;
  final bool isMobile, isTablet, isDesktop, isExtraSmall;

  const _ResponsiveCards({
    required this.items,
    required this.builder,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.isExtraSmall,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int columns;
        double spacing;

        if (width >= 1000) {
          columns = 4;
          spacing = isExtraSmall ? 8 : 16;
        } else if (width >= 700) {
          columns = 3;
          spacing = isExtraSmall ? 8 : 16;
        } else if (width >= 500) {
          columns = 2;
          spacing = isExtraSmall ? 8 : 12;
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                builder(items[i]),
                if (i != items.length - 1) const SizedBox(height: 16),
              ],
            ],
          );
        }

        final rows = <Widget>[];
        for (int i = 0; i < items.length; i += columns) {
          final chunk = items.skip(i).take(columns).toList();
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int j = 0; j < chunk.length; j++) ...[
                  Expanded(child: builder(chunk[j])),
                  if (j != chunk.length - 1) SizedBox(width: spacing),
                ],
                if (chunk.length < columns)
                  for (int k = 0; k < columns - chunk.length; k++) ...[
                    const Expanded(child: SizedBox()),
                    if (k != columns - chunk.length - 1) SizedBox(width: spacing),
                  ],
              ],
            ),
          );
          if (i + columns < items.length) {
            rows.add(SizedBox(height: spacing));
          }
        }

        return Column(children: rows);
      },
    );
  }
}