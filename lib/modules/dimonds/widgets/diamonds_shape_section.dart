import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../translations/Translation_key/translation_keys.dart';

class DiamondsShapeSection extends StatefulWidget {
  final double width;
  final List<Map<String, String>> shapes;
  final List<int> selectedIndexes;
  final ValueChanged<int> onSelected;

  const DiamondsShapeSection({
    super.key,
    required this.width,
    required this.shapes,
    required this.selectedIndexes,
    required this.onSelected,
  });

  @override
  State<DiamondsShapeSection> createState() => _DiamondsShapeSectionState();
}

class _DiamondsShapeSectionState extends State<DiamondsShapeSection> {
  late final ScrollController _scrollController;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();

    _autoScrollTimer = Timer.periodic(
      const Duration(milliseconds: 16),
          (_) {
        if (!_scrollController.hasClients) return;

        final current = _scrollController.offset + 0.8;
        final maxScroll = _scrollController.position.maxScrollExtent;

        if (current >= maxScroll * 0.7) {
          _scrollController.jumpTo(maxScroll * 0.2);
        } else {
          _scrollController.jumpTo(current);
        }
      },
    );
  }

  void _pauseAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void _resumeAutoScroll() {
    Future.delayed(
      const Duration(seconds: 2),
          () {
        if (mounted) {
          _startAutoScroll();
        }
      },
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loopShapes = [
      ...widget.shapes,
      ...widget.shapes,
      ...widget.shapes,
      ...widget.shapes,
      ...widget.shapes,
    ];

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.0),
        boldText: false,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationKeys.shape.tr,
            style: AppTextStyles.lora(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction != ScrollDirection.idle) {
                _pauseAutoScroll();
              } else {
                _resumeAutoScroll();
              }
              return false;
            },
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  loopShapes.length,
                      (index) {
                    final item = loopShapes[index];
                    final realIndex = index % widget.shapes.length;
                    final selected = widget.selectedIndexes.contains(realIndex);

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _shapeCard(
                        context: context,
                        title: _getTranslatedShapeName(item['name'] ?? ''),
                        imagePath: item['image'] ?? '',
                        selected: selected,
                        onTap: () => widget.onSelected(realIndex),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
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

  Widget _shapeCard({
    required BuildContext context,
    required String title,
    required String imagePath,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 90,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected
                  ? AppColors.primaryDark
                  : AppColors.borderGray,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: selected
                        ? AppColors.primaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}