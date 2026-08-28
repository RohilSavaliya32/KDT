import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/widgets/kdt_shimmer.dart';

import '../../daimond_card/controllers/daimond_card_controller.dart';
import '../../daimond_card/views/daimond_card_view.dart';
import '../../fade_slide_in.dart';
import '../controllers/search_controller.dart';

class SearchView extends GetView<SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final diamondController = Get.find<DiamondCardController>();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        color: AppColors.appBack,
        child: SafeArea(
          top: false,
          bottom: true,
          child: RefreshIndicator(
            color: const Color(0xFF005B45),
            onRefresh: () async {
              FocusManager.instance.primaryFocus?.unfocus();

              // Clear search
              controller.searchText.value = "";
              diamondController.searchText.value = "";

              // Reset pagination
              diamondController.currentPage.value = 1;
              diamondController.hasMore.value = true;

              // Refresh latest diamonds
              await diamondController.refreshDiamonds();
            },
            child: Obx(() {
              // Show shimmer if searching or initial loading
              final bool isSearching = diamondController.isLoading.value &&
                  diamondController.diamonds.isEmpty;

              if (isSearching) {
                return _SearchShimmer();
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 50,
                ),
                child: FadeSlideIn(
                  duration: const Duration(milliseconds: 500),
                  slideOffset: 20,
                  child: DiamondCardView(
                    isEmbedded: true,
                    enableScroll: false,
                    enablesearch: true,
                    limit: 10,
                    enableLoadMore: true,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _SearchShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return KdtShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 340,
              ),
              itemCount: 6,
              itemBuilder: (_, __) => const DiamondCardSkeleton(),
            ),
          ],
        ),
      ),
    );
  }
}
