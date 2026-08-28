import 'package:get/get.dart';
import '../../daimond_card/controllers/daimond_card_controller.dart';

class NavigationController extends GetxController {
  RxInt currentIndex = 0.obs;
  final pendingShapeIndex = RxnInt();
  final pendingLabGrown = RxnBool();

  bool _isRefreshing = false;

  bool get hasPendingFilter =>
      pendingShapeIndex.value != null || pendingLabGrown.value != null;

  @override
  void onInit() {
    super.onInit();
    _applyArguments(Get.arguments);
  }

  void _applyArguments(dynamic args) {
    if (args is Map) {
      currentIndex.value = args['tab'] ?? currentIndex.value;
      if (args['selectedShapeIndex'] != null) {
        pendingShapeIndex.value = args['selectedShapeIndex'] as int;
      }
      if (args['labGrown'] != null) {
        pendingLabGrown.value = args['labGrown'] as bool?;
      }
    } else if (args is int) {
      currentIndex.value = args;
    }
  }

  // ✅ Public entry point — route navigate karte waqt ise call karo
  // taaki permanent-controller ke onInit-only-once problem se bacha ja sake.
  void applyIncomingArguments(dynamic args) {
    _applyArguments(args);
  }

  void changeTab(int index) {
    final dc = Get.find<DiamondCardController>();
    final previousIndex = currentIndex.value;

    if (previousIndex == 2 && index != 2) {
      dc.clearAllFilters();
      dc.setType('');
    }

    currentIndex.value = index;
    update();

    if (index != 1) {
      dc.searchText.value = '';
    }

    if (index == 2) {
      // ✅ FIX: ab yahan se pending values ko null NAHI kiya jaata.
      // DiamondsView._applyPendingFilters() hi inhe consume aur clear karega,
      // taaki koi bhi pending filter (navigateToDiamonds ya route args se aaya)
      // race condition mein khud-hi-khud clear na ho jaye.
      _refreshDiamondsTab();
    }
  }

  Future<void> _refreshDiamondsTab() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      final dc = Get.find<DiamondCardController>();
      await Future.delayed(const Duration(milliseconds: 100));

      // ✅ Agar koi pending filter nahi hai, tabhi plain refresh karo.
      // Agar pending filter hai, to DiamondsView khud clearAllFilters +
      // filter apply karega — hum yahan se dobara refresh karke
      // uske saath race nahi karenge.
      if (!hasPendingFilter) {
        await dc.refreshDiamonds();
        dc.currentPage.value = 1;
        dc.hasMore.value = true;
      }

      print("✅ Diamonds tab refreshed on tab change");
    } catch (e) {
      print("❌ Error refreshing diamonds tab: $e");
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> manualRefresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      final dc = Get.find<DiamondCardController>();
      await dc.clearAllFilters();
      dc.setType('');

      pendingShapeIndex.value = null;
      pendingLabGrown.value = null;

      print("✅ Manual refresh completed");
    } catch (e) {
      print("❌ Error in manual refresh: $e");
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> clearAllFilters() async {
    try {
      final dc = Get.find<DiamondCardController>();
      await dc.clearAllFilters();
      dc.setType('');

      pendingShapeIndex.value = null;
      pendingLabGrown.value = null;

      print("✅ All filters cleared");
    } catch (e) {
      print("❌ Error clearing filters: $e");
    }
  }

  void setPendingShape(int index) {
    pendingShapeIndex.value = index;
  }

  void setPendingLabGrown(bool? value) {
    pendingLabGrown.value = value;
  }

  void clearPendingFilters() {
    pendingShapeIndex.value = null;
    pendingLabGrown.value = null;
  }

  bool get isDiamondTab => currentIndex.value == 2;

  void navigateToDiamonds({int? shapeIndex, bool? labGrown}) {
    if (shapeIndex != null) {
      pendingShapeIndex.value = shapeIndex;
    }
    if (labGrown != null) {
      pendingLabGrown.value = labGrown;
    }
    changeTab(2);
  }
}