import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/modules/fade_slide_in.dart';
import 'package:kdt/utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../daimond_card/controllers/daimond_card_controller.dart';
import '../../daimond_card/views/daimond_card_view.dart';
import '../../navigation/controllers/navigation_controller.dart';
import '../../translations/Translation_controllers/language_controller.dart';
import '../../translations/Translation_key/translation_keys.dart';
import '../widgets/diamonds_advanced_filters.dart';
import '../widgets/diamonds_hero_section.dart';
import '../widgets/diamonds_shape_section.dart';
import '../widgets/diamonds_type_filter.dart';

class DiamondsView extends StatefulWidget {
  const DiamondsView({super.key});

  @override
  State<DiamondsView> createState() => _DiamondsViewState();
}

class _DiamondsViewState extends State<DiamondsView> with AutomaticKeepAliveClientMixin {
  int selectedSortIndex = 0;
  bool _isInitializing = false;
  bool _isRefreshing = false;
  final FocusNode _focusNode = FocusNode();

  final controller = Get.find<DiamondCardController>();

  List<String> get sortOptions => [
    TranslationKeys.newestFirst.tr,
    TranslationKeys.priceLowToHigh.tr,
    TranslationKeys.priceHighToLow.tr,
    TranslationKeys.caratHighToLow.tr,
  ];

  List<String> get types => [
    TranslationKeys.allDiamonds.tr,
    TranslationKeys.certified.tr,
    TranslationKeys.nonCertified.tr,
    TranslationKeys.melee.tr,
  ];

  static const List<Map<String, String>> shapes = [
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

  List<String> get cutOptions => [
    TranslationKeys.excellent.tr,
    TranslationKeys.veryGood.tr,
  ];

  static const List<String> colorOptions = ['D', 'E', 'F', 'G', 'H'];
  static const List<String> certificationOptions = ['GIA', 'IGI', 'KDT'];

  List<String> get currentClarityOptions {
    return controller.selectedType.value.toLowerCase() == 'melee'
        ? ['VS1', 'VS2']
        : ['IF', 'VVS1', 'VVS2', 'VS1', 'VS2'];
  }

  @override
  bool get wantKeepAlive => true;
  StreamSubscription? _labGrownSub;
  StreamSubscription? _shapeIndexSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyPendingFilters();
    });

    final navController = Get.find<NavigationController>();
    _labGrownSub = navController.pendingLabGrown.listen((_) => _applyPendingFilters());
    _shapeIndexSub = navController.pendingShapeIndex.listen((_) => _applyPendingFilters());

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {}
        });
      }
    });
  }

  @override
  void dispose() {
    _labGrownSub?.cancel();
    _shapeIndexSub?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _applyPendingFilters() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      final navController = Get.find<NavigationController>();
      final shapeIndex = navController.pendingShapeIndex.value;
      final labGrown = navController.pendingLabGrown.value;
      final hasAnyPending = shapeIndex != null || labGrown != null;

      if (hasAnyPending) {
        // ✅ Pehle hi consume/reset kar do, taaki listener dobara trigger na ho isi value pe
        navController.pendingShapeIndex.value = null;
        navController.pendingLabGrown.value = null;

        await controller.clearAllFilters(); // ✅ ab poora wait karega — network refresh complete hone tak

        if (shapeIndex != null && shapeIndex < shapes.length) {
          final shapeName = shapes[shapeIndex]['name'] ?? '';
          if (shapeName.isNotEmpty) {
            controller.selectedShapes.clear();
            controller.selectedShapes.add(shapeName);
            controller.selectedShapes.refresh();
          }
        }

        if (labGrown != null) {
          controller.setLabGrownFilter(labGrown);
        }
      }
    } catch (e) {
      print("❌ Error applying pending filters: $e");
    } finally {
      _isInitializing = false;
    }
  }
  Future<void> _refreshPageCompletely() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      setState(() {});
      await controller.clearAllFilters(); // ✅ ye already fetch + filter apply kar chuka hai, dobara refreshDiamonds() ki zaroorat nahi
      setState(() {
        selectedSortIndex = 0;
      });
      print("✅ Page refreshed completely");
    } catch (e) {
      print("❌ Error refreshing page: $e");
    } finally {
      _isRefreshing = false;
      setState(() {});
    }
  }
  Future<void> _resetFilters() async {
    await _refreshPageCompletely();
  }

  void _handleTabChange() {
    if (mounted) {
      _refreshPageCompletely();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(1.0),
          boldText: false,
        ),
        child: _buildScaffold(),
      ),
    );
  }

  Widget _buildScaffold() {
    final width = MediaQuery.of(context).size.width;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return GetBuilder<LanguageController>(
      builder: (langController) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.appBack,
          body: GestureDetector(
            onTap: () {
              // Dismiss keyboard when tapping outside
              FocusScope.of(context).unfocus();
            },
            child: SafeArea(
              bottom: false, // Remove bottom safe area to prevent white space
              child: Stack(
                children: [
                  SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: 18,
                      right: 18,
                      top: 30,
                      // Add extra bottom padding when keyboard is open
                      bottom: viewInsets.bottom > 0
                          ? viewInsets.bottom + 30
                          : 30,
                    ),
                    child: FadeSlideIn(
                      duration: const Duration(milliseconds: 500),
                      slideOffset: 15,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1280),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 32),
                              const DiamondsHeroSection(),
                              const SizedBox(height: 48),
                              _buildTypeFilter(),
                              const SizedBox(height: 24),
                              Divider(height: 1, thickness: 1, color: AppColors.borderGray),
                              const SizedBox(height: 24),
                              _buildShapeSection(width),
                              const SizedBox(height: 24),
                              _buildAdvancedFilters(width),
                              const SizedBox(height: 12),
                              const SizedBox(height: 24),
                              Divider(height: 1, color: AppColors.borderGray),
                              const SizedBox(height: 18),
                              _buildHeaderRow(),
                              const SizedBox(height: 20),
                              DiamondCardView(
                                isEmbedded: true,
                                useFilters: true,
                                sortIndex: selectedSortIndex,
                                onClearFilters: _resetFilters,
                                controller: controller,
                                limit: 10,
                                enableLoadMore: true,
                              ),
                              // Add extra bottom space for scrolling
                              const SizedBox(height: 120),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isRefreshing)
                    Container(
                      color: AppColors.primaryDark.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypeFilter() {
    return Obx(() {
      int selectedIdx = 0;
      if (controller.selectedType.value.isNotEmpty) {
        final index = types.indexWhere(
                (e) => e.toLowerCase() == controller.selectedType.value.toLowerCase()
        );
        if (index >= 0) {
          selectedIdx = index;
        }
      }

      return DiamondsTypeFilter(
        types: types,
        selectedIndex: selectedIdx,
        onSelected: (index) {
          // Dismiss keyboard when selecting type
          FocusScope.of(context).unfocus();
          controller.selectedClarities.clear();
          final selectedType = index == 0 ? '' : types[index];
          controller.setType(selectedType);
        },
      );
    });
  }

  Widget _buildShapeSection(double width) {
    return Obx(() {
      final selectedIndexes = controller.selectedShapes
          .map((e) {
        final index = shapes.indexWhere(
                (s) => s['name']?.toLowerCase() == e.toLowerCase()
        );
        return index;
      })
          .where((e) => e >= 0)
          .toList();

      return DiamondsShapeSection(
        width: width,
        shapes: shapes,
        selectedIndexes: selectedIndexes,
        onSelected: (index) {
          // Dismiss keyboard when selecting shape
          FocusScope.of(context).unfocus();
          if (index >= 0 && index < shapes.length) {
            final name = shapes[index]['name'] ?? '';
            if (name.isNotEmpty) {
              controller.toggleShape(name);
            }
          }
        },
      );
    });
  }

  Widget _buildAdvancedFilters(double width) {
    return Obx(() {
      final selectedCutIndexes = controller.selectedCuts
          .map((e) => cutOptions.indexWhere(
              (option) => option.toLowerCase() == e.toLowerCase()
      ))
          .where((e) => e >= 0)
          .toList();

      final selectedColorIndexes = controller.selectedColors
          .map((e) => colorOptions.indexWhere(
              (option) => option.toLowerCase() == e.toLowerCase()
      ))
          .where((e) => e >= 0)
          .toList();

      final clarityOptions = currentClarityOptions;
      final selectedClarityIndexes = controller.selectedClarities
          .map((e) => clarityOptions.indexWhere(
              (option) => option.toLowerCase() == e.toLowerCase()
      ))
          .where((e) => e >= 0)
          .toList();

      final selectedCertificationIndexes = controller.selectedCertifications
          .map((e) => certificationOptions.indexWhere(
              (option) => option.toLowerCase() == e.toLowerCase()
      ))
          .where((e) => e >= 0)
          .toList();

      return DiamondsAdvancedFilters(
        width: width,
        cutOptions: cutOptions,
        colorOptions: colorOptions,
        clarityOptions: clarityOptions,
        certificationOptions: certificationOptions,
        selectedCutIndexes: selectedCutIndexes,
        selectedColorIndexes: selectedColorIndexes,
        selectedClarityIndexes: selectedClarityIndexes,
        selectedCertificationIndexes: selectedCertificationIndexes,
        onCutSelected: (index) {
          // Dismiss keyboard when selecting cut
          FocusScope.of(context).unfocus();
          if (index >= 0 && index < cutOptions.length) {
            controller.toggleCut(cutOptions[index]);
          }
        },
        onColorSelected: (index) {
          // Dismiss keyboard when selecting color
          FocusScope.of(context).unfocus();
          if (index >= 0 && index < colorOptions.length) {
            controller.toggleColor(colorOptions[index]);
          }
        },
        onClaritySelected: (index) {
          // Dismiss keyboard when selecting clarity
          FocusScope.of(context).unfocus();
          if (index >= 0 && index < clarityOptions.length) {
            controller.toggleClarity(clarityOptions[index]);
          }
        },
        onCertificationSelected: (index) {
          // Dismiss keyboard when selecting certification
          FocusScope.of(context).unfocus();
          if (index >= 0 && index < certificationOptions.length) {
            controller.toggleCertification(certificationOptions[index]);
          }
        },
        onCaratMinChanged: (value) {
          final min = double.tryParse(value) ?? 0.0;
          if (min >= 0) {
            controller.setCaratRange(min, controller.maxCarat.value);
          }
        },
        onCaratMaxChanged: (value) {
          final max = double.tryParse(value) ?? 999999999.0;
          if (max >= controller.minCarat.value) {
            controller.setCaratRange(controller.minCarat.value, max);
          }
        },
      );
    });
  }

  Widget _buildHeaderRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Obx(() {
            final count = controller.filteredList.length;
            return Text(
              '$count ${TranslationKeys.diamondsFound.tr}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            );
          }),
        ),
        const SizedBox(width: 12),
        _buildSortDropdown(),
      ],
    );
  }

  Widget _buildSortDropdown() {
    return PopupMenuButton<int>(
      color: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      onSelected: (value) {
        // Dismiss keyboard when selecting sort option
        FocusScope.of(context).unfocus();
        if (value != selectedSortIndex) {
          setState(() {
            selectedSortIndex = value;
          });
        }
      },
      itemBuilder: (context) => _buildSortMenuItems(),
      child: _buildSortDropdownButton(),
    );
  }

  List<PopupMenuItem<int>> _buildSortMenuItems() {
    return List.generate(sortOptions.length, (index) {
      final selected = selectedSortIndex == index;
      return PopupMenuItem<int>(
        value: index,
        padding: EdgeInsets.zero,
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: selected ? AppColors.foreground : AppColors.white,
          child: Text(
            sortOptions[index],
            style: AppTextStyles.lora(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: selected ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSortDropdownButton() {
    return Container(
      width: 180,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              sortOptions[selectedSortIndex],
              style: AppTextStyles.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}