import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';

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
        color: Colors.white,
        child: SafeArea(
          top: false,
          bottom: true,
          child: RefreshIndicator(
            color: const Color(0xFF005B45),
            onRefresh: () async {
              FocusManager.instance.primaryFocus?.unfocus();

              // Clear search
              controller.searchText.value = "";

              // Reset pagination
              diamondController.currentPage.value = 1;
              diamondController.hasMore.value = true;

              // Refresh latest diamonds
              await diamondController.refreshDiamonds();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
            ),
          ),
        ),
      ),
    );
  }
}