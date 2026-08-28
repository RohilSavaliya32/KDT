import 'dart:async';

import 'package:get/get.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../daimond_card/diamond_model.dart';
import '../../daimond_card/diamond_repository.dart';

class HomeController extends GetxController {
  final SettingsDataRepository repository;
  final DiamondRepository diamondRepository = Get.find<DiamondRepository>();

  final RxList<DiamondModel> bestSellerDiamonds = <DiamondModel>[].obs;
  final RxList<DiamondModel> trendingDiamonds = <DiamondModel>[].obs;
  final RxBool isLoading = false.obs;

  HomeController(this.repository);

  @override
  void onInit() {
    super.onInit();
    // Fetch data in background immediately
    refreshHomeData();
  }

  Future<void> refreshHomeData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        getSettings(),
        loadBestSellerDiamonds(),
        loadTrendingDiamonds(),
      ]).timeout(const Duration(seconds: 20)); // extra safety net
    } catch (e) {
      print("Error loading home data: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> getSettings() async {
    try {
      await repository.getSettings().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Settings fetch timed out'),
      );
    } catch (e) {
      print("Settings Error: $e");
    }
  }

  Future<void> loadBestSellerDiamonds() async {
    try {
      final data = await diamondRepository
          .getBestSellerDiamonds()
          .timeout(const Duration(seconds: 15));
      bestSellerDiamonds.assignAll(data);
    } catch (e) {
      print("Best Seller Error: $e");
      bestSellerDiamonds.assignAll([]); // spinner ko forever stuck hone se rokta hai
    }
  }

  Future<void> loadTrendingDiamonds() async {
    try {
      final data = await diamondRepository
          .getTrendingDiamonds()
          .timeout(const Duration(seconds: 15));
      trendingDiamonds.assignAll(data);
    } catch (e) {
      print("Trending Error: $e");
      trendingDiamonds.assignAll([]);
    }
  }
}