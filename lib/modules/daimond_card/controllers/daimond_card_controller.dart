  import 'package:get/get.dart';
  import '../diamond_model.dart';
  import '../diamond_repository.dart';

  class DiamondCardController extends GetxController {
    final DiamondRepository repository;
    DiamondCardController(this.repository);

    final isLoading = false.obs;
    final errorMessage = ''.obs;
    final diamonds = <DiamondModel>[].obs;
    final searchText = ''.obs;
    final minCarat = 0.0.obs;
    final maxCarat = 999999999.0.obs;

    final selectedType = ''.obs;
    final selectedShapes = <String>[].obs;
    final selectedCuts = <String>[].obs;
    final selectedColors = <String>[].obs;
    final selectedClarities = <String>[].obs;
    final selectedCertifications = <String>[].obs;
    final RxnBool labGrownFilter = RxnBool();

    // ✅ Reactive filtered list
    final filteredList = <DiamondModel>[].obs;

    final currentPage = 1.obs;
    final limit = 20;
    final hasMore = true.obs;

    bool _isApplyingFilters = false;

    @override
    void onInit() {
      super.onInit();
      print("🔵 [INIT] DiamondCardController initialized");

      // ✅ Listen to all filter changes
      ever(diamonds, (_) {
        print("🟢 [EVER] diamonds changed - count: ${diamonds.length}");
        _applyFilters();
      });
      ever(labGrownFilter, (_) {
        print("🟢 [EVER] labGrownFilter changed - value: ${labGrownFilter.value}");
        _applyFilters();
      });
      ever(selectedType, (_) {
        print("🟢 [EVER] selectedType changed - value: ${selectedType.value}");
        _applyFilters();
      });
      ever(selectedShapes, (_) {
        print("🟢 [EVER] selectedShapes changed - values: ${selectedShapes.join(', ')}");
        _applyFilters();
      });
      ever(selectedCuts, (_) {
        print("🟢 [EVER] selectedCuts changed - values: ${selectedCuts.join(', ')}");
        _applyFilters();
      });
      ever(selectedColors, (_) {
        print("🟢 [EVER] selectedColors changed - values: ${selectedColors.join(', ')}");
        _applyFilters();
      });
      ever(selectedClarities, (_) {
        print("🟢 [EVER] selectedClarities changed - values: ${selectedClarities.join(', ')}");
        _applyFilters();
      });
      ever(selectedCertifications, (_) {
        print("🟢 [EVER] selectedCertifications changed - values: ${selectedCertifications.join(', ')}");
        _applyFilters();
      });
      ever(minCarat, (_) {
        print("🟢 [EVER] minCarat changed - value: ${minCarat.value}");
        _applyFilters();
      });
      ever(maxCarat, (_) {
        print("🟢 [EVER] maxCarat changed - value: ${maxCarat.value}");
        _applyFilters();
      });

      fetchDiamonds();
    }

    // ✅ FIXED: Filter logic with proper assignment
    void _applyFilters() {
      if (_isApplyingFilters) return;
      _isApplyingFilters = true;

      try {
        if (diamonds.isEmpty) {
          print("   📭 [_applyFilters] Diamonds is empty");
          filteredList.value = []; // ✅ FIX: Use .value
          return;
        }

        print("   🔍 [_applyFilters] Starting filter iteration on ${diamonds.length} diamonds...");

        final result = diamonds.where((diamond) {
          // Lab Grown filter
          if (labGrownFilter.value != null &&
              diamond.isLabGrown != labGrownFilter.value) {
            print("   ❌ Rejected: ${diamond.title} - Lab Grown mismatch (${diamond.isLabGrown} != ${labGrownFilter.value})");
            return false;
          }

          // Type filter
          if (selectedType.value.isNotEmpty) {
            final type = selectedType.value.toLowerCase();
            final cert = diamond.certification.trim().toLowerCase();
            switch (type) {
              case 'certified':
                if (cert.isEmpty) return false;
                break;
              case 'non-certified':
                if (cert.isNotEmpty) return false;
                break;
              case 'melee':
                if (diamond.carat > 0.18) return false;
                break;
            }
          }

          // Shape filter
          if (selectedShapes.isNotEmpty) {
            final matched = selectedShapes.any(
                  (s) => diamond.shape.toLowerCase().contains(s.toLowerCase()),
            );
            if (!matched) return false;
          }

          // Cut filter
          if (selectedCuts.isNotEmpty &&
              !selectedCuts.map((e) => e.toLowerCase()).contains(diamond.cut.toLowerCase()))
            return false;

          // Color filter
          if (selectedColors.isNotEmpty &&
              !selectedColors.map((e) => e.toLowerCase()).contains(diamond.color.toLowerCase()))
            return false;

          // Clarity filter
          if (selectedClarities.isNotEmpty &&
              !selectedClarities.map((e) => e.toLowerCase()).contains(diamond.clarity.toLowerCase()))
            return false;

          // ✅ Certification filter - EXACT MATCH (case insensitive)
          if (selectedCertifications.isNotEmpty) {
            final certMatch = selectedCertifications.any(
                    (selectedCert) =>
                diamond.certification.trim().toLowerCase() == selectedCert.trim().toLowerCase()
            );
            if (!certMatch) {
              print("   ❌ Rejected: ${diamond.title} - Certification mismatch (${diamond.certification} not in ${selectedCertifications.join(', ')})");
              return false;
            }
          }

          // Carat range filter
          if (diamond.carat < minCarat.value || diamond.carat > maxCarat.value)
            return false;

          print("   ✅ Passed: ${diamond.title} (${diamond.certification})");
          return true;
        }).toList();

        // ✅ FIX: Always use .value to trigger reactivity
        filteredList.value = result;

        print("✅ Filters Applied - Total: ${filteredList.length}");
        print("   Shapes: ${selectedShapes.join(', ')}");
        print("   Certifications: ${selectedCertifications.join(', ')}");
        print("   Lab Grown: ${labGrownFilter.value}");

      } catch (e) {
        print("❌ Error applying filters: $e");
      } finally {
        _isApplyingFilters = false;
      }
    }

    // ─── Toggle Certification ───────────────────────────────

    void toggleCertification(String value) {
      final item = value.trim().toUpperCase(); // ✅ Normalize to uppercase
      print("🔄 [toggleCertification] Toggling: '$item'");
      print("   Before: ${selectedCertifications.join(', ')}");

      if (selectedCertifications.contains(item)) {
        selectedCertifications.remove(item);
        print("   Removed: $item");
      } else {
        selectedCertifications.add(item);
        print("   Added: $item");
      }

      print("   After: ${selectedCertifications.join(', ')}");
      // ✅ ever() will handle _applyFilters()
    }

    // ─── Toggle Lab Grown ────────────────────────────────────

    void toggleLabGrown(bool? value) {
      print("🔄 [toggleLabGrown] Toggling to: $value");
      labGrownFilter.value = value;
      // ✅ ever() will handle _applyFilters()
    }

    // ─── Clear All Filters ───────────────────────────────────

    // Future<void> clearAllFilters() async {
    //   print("🔄 [clearAllFilters] START - Clearing all filters...");
    //
    //   selectedType.value = '';
    //   selectedShapes.clear();
    //   selectedCuts.clear();
    //   selectedColors.clear();
    //   selectedClarities.clear();
    //   selectedCertifications.clear();
    //   labGrownFilter.value = null;
    //   minCarat.value = 0.0;
    //   maxCarat.value = 999999999.0;
    //   searchText.value = '';
    //   currentPage.value = 1;
    //   hasMore.value = true;
    //
    //   await refreshDiamonds(); // ✅ ye khud diamonds.assignAll() + _applyFilters() karta hai — filteredList already sahi set ho chuka hoga
    //
    //   print("✅ Filters Cleared - Total: ${filteredList.length}");
    // }
    Future<void> clearAllFilters() async {
      print("🔄 [clearAllFilters] START - Clearing all filters...");

      selectedType.value = '';
      selectedShapes.clear();
      selectedCuts.clear();
      selectedColors.clear();
      selectedClarities.clear();
      selectedCertifications.clear();
      labGrownFilter.value = null;
      minCarat.value = 0.0;
      maxCarat.value = 999999999.0;
      searchText.value = '';

      // Sirf local list reset karo
      filteredList.assignAll(diamonds);

      print("✅ Filters Cleared - Total: ${filteredList.length}");
    }
    // ─── Setters ───────────────────────────────────────────

    void setType(String value) {
      selectedType.value = value.trim();
    }

    void setLabGrownFilter(bool? value) {
      labGrownFilter.value = value;
    }

    void setCaratRange(double min, double max) {
      minCarat.value = min;
      maxCarat.value = max;
    }

    void setShape(String value) {
      selectedShapes.clear();
      selectedShapes.add(value.trim());
    }

    void setCut(String value) => toggleCut(value);
    void setColor(String value) => toggleColor(value);
    void setClarity(String value) => toggleClarity(value);
    void setCertification(String value) => toggleCertification(value);

    void toggleShape(String value) {
      final item = value.trim();
      if (selectedShapes.contains(item)) {
        selectedShapes.remove(item);
      } else {
        selectedShapes.add(item);
      }
    }

    void toggleCut(String value) {
      final item = value.trim();
      if (selectedCuts.contains(item)) {
        selectedCuts.remove(item);
      } else {
        selectedCuts.add(item);
      }
    }

    void toggleColor(String value) {
      final item = value.trim();
      if (selectedColors.contains(item)) {
        selectedColors.remove(item);
      } else {
        selectedColors.add(item);
      }
    }

    void toggleClarity(String value) {
      final item = value.trim();
      if (selectedClarities.contains(item)) {
        selectedClarities.remove(item);
      } else {
        selectedClarities.add(item);
      }
    }

    // ─── Search ────────────────────────────────────────────

    void searchDiamonds(String value) {
      searchText.value = value;
    }

    List<DiamondModel> get searchOnlyDiamonds {
      if (searchText.value.trim().isEmpty) return diamonds;
      return diamonds
          .where((d) => d.title.toLowerCase().contains(searchText.value.toLowerCase()))
          .toList();
    }

    List<DiamondModel> get filteredDiamonds => filteredList;

    // ─── API ───────────────────────────────────────────────

    Future<void> fetchDiamonds() async {
      try {
        isLoading.value = true;
        errorMessage.value = '';
        final result = await repository.getDiamonds(
          page: currentPage.value,
          limit: limit,
        );
        diamonds.assignAll(result);
        _applyFilters();
      } catch (e) {
        errorMessage.value = e.toString();
        Get.snackbar(
          'Load Error',
          'We couldn’t fetch the diamonds. Please try again later.',
          snackPosition: SnackPosition.TOP,
        );
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> refreshDiamonds() async {
      currentPage.value = 1;
      try {
        final result = await repository.getDiamonds(page: 1, limit: limit);
        diamonds.assignAll(result);
        hasMore.value = result.length >= limit;
        _applyFilters();
      } catch (e) {
        Get.snackbar(
          'Refresh Error',
          'We couldn’t refresh the diamonds. Please check your connection.',
          snackPosition: SnackPosition.TOP,
        );
      }
    }

    Future<void> loadMore() async {
      if (!hasMore.value || isLoading.value) return;

      try {
        isLoading.value = true;

        currentPage.value++;

        final result = await repository.getDiamonds(
          page: currentPage.value,
          limit: limit,
        );

        // ✅ No data
        if (result.isEmpty) {
          hasMore.value = false;
          currentPage.value--;
          return;
        }

        // ✅ Last page (records are less than limit)
        if (result.length < limit) {
          hasMore.value = false;
        }

        // ✅ Remove duplicate records
        final existingIds = diamonds.map((e) => e.id).toSet();

        for (final diamond in result) {
          if (!existingIds.contains(diamond.id)) {
            diamonds.add(diamond);
          }
        }

        _applyFilters();
      } catch (e) {
        currentPage.value--;
        Get.snackbar(
          'Load More Error',
          'An unexpected error occurred while loading more diamonds.',
          snackPosition: SnackPosition.TOP,
        );
      } finally {
        isLoading.value = false;
      }
    }
    DiamondModel? getDiamondByIndex(int index) {
      if (index >= diamonds.length) return null;
      return diamonds[index];
    }
  }