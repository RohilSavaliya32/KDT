import 'package:kdt/modules/fade_slide_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../controllers/about_controller.dart';
import 'package:url_launcher/url_launcher.dart';

// ==================== FONT SIZES ====================

class _FontSizes {
  // Headings
  static const double heroTitle = 28;
  static const double sectionTitle = 24;
  static const double cardTitle = 20;
  static const double officeTitle = 22;

  // Body text
  static const double bodyLarge = 15;
  static const double bodyRegular = 14;
  static const double bodySmall = 13;
  static const double bodyExtraSmall = 12;

  // Stats
  static const double statNumber = 32;
  static const double statLabel = 13;

  // Mobile adjustments
  static const double mobileHeroTitle = 24;
  static const double mobileSectionTitle = 22;
  static const double mobileCardTitle = 17;
  static const double mobileOfficeTitle = 20;
  static const double mobileBodyLarge = 14;
  static const double mobileBodyRegular = 13;
  static const double mobileBodySmall = 12;
  static const double mobileStatNumber = 28;
  static const double mobileStatLabel = 12;
}

class AboutView extends GetView<AboutController> {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: FadeSlideIn(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
              const _HeroSection(),
              _Section(
                title: controller.storySectionTitle,
                child: const _StorySection(),
              ),
              _Section(
                title: controller.valuesSectionTitle,
                bgColor: AppColors.lightGray,
                child: const _ValuesGrid(),
              ),
              _Section(
                title: controller.timelineSectionTitle,
                child: const _TimelineSection(),
              ),
              _Section(
                title: controller.visionSectionTitle,
                bgColor: AppColors.lightGray,
                subtitle: controller.visionSubtitle,
                child: const _VisionSection(),
              ),
              _Section(
                title: controller.partnersSectionTitle,
                subtitle: controller.partnersSubtitle,
                child: const _PartnersSection(),
              ),
              _Section(
                title: controller.officesSectionTitle,
                bgColor: AppColors.lightGray,
                child: const _OfficesSection(),
              ),
            ],
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
      iconTheme: const IconThemeData(
        color: AppColors.foreground,
      ),
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppColors.foreground,
        ),
        tooltip: 'Back',
      ),
      title: Text(
        'About Us',
        style: AppTextStyles.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.foreground,
        ),
      ),
    );
  }
}

// ==================== HERO SECTION ====================

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final controller = Get.find<AboutController>();

    return Container(
      width: double.infinity,
      color: AppColors.lightGray,
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isMobile ? 40 : 60,
      ),
      child: Column(
        children: [
          Text(
            controller.heroTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.poppins(
              fontSize: isMobile
                  ? _FontSizes.mobileHeroTitle
                  : _FontSizes.heroTitle,
              fontWeight: FontWeight.w500,
              height: 1.25,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Text(
              controller.heroSubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.poppins(
                fontSize: isMobile
                    ? _FontSizes.mobileBodyLarge
                    : _FontSizes.bodyLarge,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SECTION WRAPPER ====================

class _Section extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Color? bgColor;

  const _Section({
    required this.title,
    required this.child,
    this.subtitle,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      width: double.infinity,
      color: bgColor ?? AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isMobile ? 28 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.poppins(
                  fontSize: isMobile
                      ? _FontSizes.mobileSectionTitle
                      : _FontSizes.sectionTitle,
                  fontWeight: FontWeight.w500,
                  letterSpacing: title == title.toUpperCase() ? 1.2 : 0,
                  color: AppColors.foreground,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.poppins(
                      fontSize: isMobile
                          ? _FontSizes.mobileBodyRegular
                          : _FontSizes.bodyRegular,
                      height: 1.7,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== STORY SECTION ====================

class _StorySection extends StatelessWidget {
  const _StorySection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final controller = Get.find<AboutController>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;

        final storyText = Text(
          controller.storyText,
          style: AppTextStyles.poppins(
            fontSize: isMobile
                ? _FontSizes.mobileBodyRegular
                : _FontSizes.bodyRegular,
            height: 1.75,
            color: AppColors.textSecondary,
          ),
        );

        final statsCard = const _StatsCard();

        if (isWide) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: storyText,
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 2,
                  child: statsCard,
                ),
              ],
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            storyText,
            const SizedBox(height: 24),
            statsCard,
          ],
        );
      },
    );
  }
}

// ==================== STATS CARD ====================

class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AboutController>();
    final stats = controller.stats;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            offset: const Offset(0, 12),
            color: AppColors.black.withOpacity(0.04),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _StatItem(stat: stats[0]),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatItem(stat: stats[1]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _StatItem(stat: stats[2]),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatItem(stat: stats[3]),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ==================== STAT ITEM ====================

class _StatItem extends StatelessWidget {
  final Map<String, String> stat;

  const _StatItem({
    required this.stat,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          stat['value']!,
          style: AppTextStyles.poppins(
            fontSize: isMobile
                ? _FontSizes.mobileStatNumber
                : _FontSizes.statNumber,
            fontWeight: FontWeight.w600,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stat['label']!,
          textAlign: TextAlign.center,
          style: AppTextStyles.poppins(
            fontSize: isMobile
                ? _FontSizes.mobileStatLabel
                : _FontSizes.statLabel,
            height: 1.4,
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

// ==================== VALUES GRID ====================

class _ValuesGrid extends StatelessWidget {
  const _ValuesGrid();

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'verified_outlined':
        return Icons.verified_outlined;
      case 'groups_outlined':
        return Icons.groups_outlined;
      case 'public_outlined':
        return Icons.public_outlined;
      case 'favorite_border':
        return Icons.favorite_border;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AboutController>();
    final values = controller.values;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width > 900) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: values
                  .map(
                    (value) => Expanded(
                  child: _ValueCard(
                    data: value,
                    iconData: _getIconData(value['icon']!),
                  ),
                ),
              )
                  .toList(),
            ),
          );
        }

        if (width > 550) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _ValueCard(
                        data: values[0],
                        iconData: _getIconData(values[0]['icon']!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ValueCard(
                        data: values[1],
                        iconData: _getIconData(values[1]['icon']!),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _ValueCard(
                        data: values[2],
                        iconData: _getIconData(values[2]['icon']!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ValueCard(
                        data: values[3],
                        iconData: _getIconData(values[3]['icon']!),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _ValueCard(
                      data: values[0],
                      iconData: _getIconData(values[0]['icon']!),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _ValueCard(
                      data: values[1],
                      iconData: _getIconData(values[1]['icon']!),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _ValueCard(
                      data: values[2],
                      iconData: _getIconData(values[2]['icon']!),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _ValueCard(
                      data: values[3],
                      iconData: _getIconData(values[3]['icon']!),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ==================== VALUE CARD ====================

class _ValueCard extends StatelessWidget {
  final Map<String, String> data;
  final IconData iconData;

  const _ValueCard({
    required this.data,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 4),
            color: AppColors.black.withOpacity(0.015),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconData,
              size: 24,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            data['title']!,
            textAlign: TextAlign.center,
            style: AppTextStyles.poppins(
              fontSize: isMobile
                  ? _FontSizes.mobileCardTitle
                  : _FontSizes.cardTitle,
              fontWeight: FontWeight.w500,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data['text']!,
            textAlign: TextAlign.center,
            style: AppTextStyles.poppins(
              fontSize: isMobile
                  ? _FontSizes.mobileBodySmall
                  : _FontSizes.bodySmall,
              height: 1.5,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== TIMELINE SECTION ====================

class _TimelineSection extends StatelessWidget {
  const _TimelineSection();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final controller = Get.find<AboutController>();
    final timelineData = controller.timelineData;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        if (isWide) {
          return _DesktopTimeline(items: timelineData);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            timelineData.length,
                (index) {
              return _TimelineItem(
                data: timelineData[index],
                isMobile: isMobile,
                isLast: index == timelineData.length - 1,
              );
            },
          ),
        );
      },
    );
  }
}

// ==================== DESKTOP TIMELINE ====================

class _DesktopTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const _DesktopTimeline({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: List.generate(
          items.length,
              (index) {
            final bool isLeft = index.isEven;

            return SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // LEFT SIDE
                  Expanded(
                    child: isLeft
                        ? Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 35),
                        child: _TimelineContent(
                          data: items[index],
                          alignRight: true,
                        ),
                      ),
                    )
                        : const SizedBox(),
                  ),

                  // CENTER LINE & DOT
                  SizedBox(
                    width: 70,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: 2,
                            color: index == 0
                                ? AppColors.transparent
                                : AppColors.lightGreen,
                          ),
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: 2,
                            color: index == items.length - 1
                                ? AppColors.transparent
                                : AppColors.lightGreen,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // RIGHT SIDE
                  Expanded(
                    child: !isLeft
                        ? Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 35),
                        child: _TimelineContent(
                          data: items[index],
                          alignRight: false,
                        ),
                      ),
                    )
                        : const SizedBox(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ==================== TIMELINE CONTENT ====================

class _TimelineContent extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool alignRight;

  const _TimelineContent({
    super.key,
    required this.data,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    final events = List<String>.from(data['events']);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 420,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: alignRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            data['year']!,
            textAlign: alignRight ? TextAlign.right : TextAlign.left,
            style: AppTextStyles.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          ...events.map(
                (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                softWrap: true,
                overflow: TextOverflow.visible,
                textAlign: alignRight ? TextAlign.right : TextAlign.left,
                style: AppTextStyles.poppins(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== MOBILE TIMELINE ITEM ====================

class _TimelineItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool isMobile;
  final bool isLast;

  const _TimelineItem({
    required this.data,
    required this.isMobile,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final events = List<String>.from(data['events']);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot + connecting line
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.lightGreen,
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Year + description
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['year']!,
                    style: AppTextStyles.poppins(
                      fontSize: isMobile ? 17 : 19,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...events.map(
                        (line) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        line,
                        style: AppTextStyles.poppins(
                          fontSize: isMobile
                              ? _FontSizes.mobileBodySmall
                              : _FontSizes.bodySmall,
                          height: 1.5,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== VISION SECTION ====================

class _VisionSection extends StatelessWidget {
  const _VisionSection();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AboutController>();
    final images = controller.visionImages;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;

        if (isWide) {
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _VisionImageCard(data: images[0]),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _VisionImageCard(data: images[1]),
                ),
              ],
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _VisionImageCard(data: images[0]),
            const SizedBox(height: 20),
            _VisionImageCard(data: images[1]),
          ],
        );
      },
    );
  }
}

// ==================== VISION IMAGE CARD ====================

class _VisionImageCard extends StatelessWidget {
  final Map<String, String> data;

  const _VisionImageCard({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.asset(
              data['path']!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.lightGray,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.apartment_rounded,
                    size: 48,
                    color: AppColors.accent.withOpacity(0.4),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          data['label']!,
          style: AppTextStyles.poppins(
            fontSize: isMobile
                ? _FontSizes.mobileBodySmall
                : _FontSizes.bodySmall,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ==================== OFFICES SECTION ====================

class _OfficesSection extends StatelessWidget {
  const _OfficesSection();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AboutController>();

    return Obx(() {
      // Show loading if data is being fetched and we don't have it yet
      if (controller.settingsController.isLoading.value && 
          controller.settingsController.settings.value == null) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
        );
      }

      // Show retry button if there was an error and no data
      if (controller.settingsController.errorMessage.isNotEmpty && 
          controller.settingsController.settings.value == null) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              const Text("Failed to load office information"),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => controller.settingsController.fetchSettings(),
                child: const Text("Retry"),
              ),
            ],
          ),
        );
      }

      final office1 = _OfficeCard(
        office: "Korea Office",
        flagEmoji: "🇰🇷",
        address: controller.koreaAddress.isEmpty ? "Seoul, South Korea" : controller.koreaAddress,
        phone: controller.koreaPhone.isEmpty ? "+82-2-747-1945" : controller.koreaPhone,
        email: "korea@kdtdiamond.com",
        hours: "Mon - Sat: 10:00 AM - 7:00 PM (KST)",
        regNumber: "Registration Number: ${controller.regNo.isEmpty ? "101-86-63531" : controller.regNo}",
      );

      final office2 = _OfficeCard(
        office: "India Office",
        flagEmoji: "🇮🇳",
        address: controller.indiaAddress.isEmpty ? "Surat, Gujarat, India" : controller.indiaAddress,
        phone: controller.indiaPhone.isEmpty ? "+91-261-255-1945" : controller.indiaPhone,
        email: controller.email.isEmpty ? "india@kdtdiamond.com" : controller.email,
        hours: "Mon - Sat: 10:00 AM - 7:00 PM (IST)",
        regNumber: "GST Number: ${controller.gstNo.isEmpty ? "24AAACK3103J1Z0" : controller.gstNo}",
      );

      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: office1),
                const SizedBox(width: 24),
                Expanded(child: office2),
              ],
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              office1,
              const SizedBox(height: 20),
              office2,
            ],
          );
        },
      );
    });
  }
}

// ==================== OFFICE CARD ====================

class _OfficeCard extends StatelessWidget {
  final String office;
  final String flagEmoji;
  final String address;
  final String phone;
  final String email;
  final String hours;
  final String regNumber;

  const _OfficeCard({
    required this.office,
    required this.flagEmoji,
    required this.address,
    required this.phone,
    required this.email,
    required this.hours,
    required this.regNumber,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 6),
            color: AppColors.black.withOpacity(0.02),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                flagEmoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                office,
                style: AppTextStyles.poppins(
                  fontSize: isMobile
                      ? _FontSizes.mobileOfficeTitle
                      : _FontSizes.officeTitle,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: 'Address',
            value: address,
            icon: Icons.location_on_outlined,
            isMobile: isMobile,
          ),
          _InfoRow(
            label: 'Phone',
            value: phone,
            icon: Icons.phone_outlined,
            isMobile: isMobile,
          ),
          _InfoRow(
            label: 'Email',
            value: email,
            icon: Icons.email_outlined,
            isMobile: isMobile,
          ),
          _InfoRow(
            label: 'Business Hours',
            value: hours,
            icon: Icons.access_time_outlined,
            isMobile: isMobile,
          ),
          const Divider(
            height: 24,
            color: AppColors.divider,
          ),
          Text(
            regNumber,
            style: AppTextStyles.poppins(
              fontSize: isMobile ? 11 : _FontSizes.bodyExtraSmall,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== INFO ROW ====================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isMobile;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.isMobile,
  });

  Future<void> _launch() async {
    try {
      if (label == "Phone") {
        final uri = Uri.parse("tel:${value.replaceAll(' ', '')}");
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else if (label == "Email") {
        final uri = Uri.parse("mailto:${value.trim()}");
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint("Launch Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final clickable = label == "Phone" || label == "Email";

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.iconGray,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.foreground,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: clickable ? _launch : null,
                  child: Text(
                    value,
                    style: AppTextStyles.poppins(
                      color: clickable
                          ? AppColors.accent
                          : AppColors.textSecondary,
                    ),
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

// ==================== PARTNERS SECTION ====================

class _PartnersSection extends StatelessWidget {
  const _PartnersSection();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AboutController>();
    final partners = controller.partners;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        final crossAxisCount = isWide ? 5 : 2;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          alignment: WrapAlignment.center,
          children: partners.map((p) {
            final itemWidth =
                (constraints.maxWidth - (crossAxisCount - 1) * 14) /
                    crossAxisCount;

            return SizedBox(
              width: itemWidth,
              child: _PartnerLogoCard(data: p),
            );
          }).toList(),
        );
      },
    );
  }
}

// ==================== PARTNER LOGO CARD ====================

class _PartnerLogoCard extends StatelessWidget {
  final Map<String, String> data;

  const _PartnerLogoCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          data['image']!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.mutedForeground,
              ),
            );
          },
        ),
      ),
    );
  }
}
