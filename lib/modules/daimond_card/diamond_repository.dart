import 'diamond_api_provider.dart';
import 'diamond_model.dart';

class DiamondRepository {
  final DiamondApiProvider apiProvider;

  DiamondRepository(this.apiProvider) {
    print("🔵 [DiamondRepository] Instance created");
  }

  Future<List<DiamondModel>> getDiamonds({
    int page = 1,
    int limit = 20,
    String search = '',
  }) async {
    print("\n═══════════════════════════════════════════════════════════");
    print("🔵 [Repository] getDiamonds() START");
    print("═══════════════════════════════════════════════════════════");
    print("   📋 Parameters:");
    print("      - Page: $page");
    print("      - Limit: $limit");
    print("      - Search: '${search.isEmpty ? '(empty)' : search}'");
    print("═══════════════════════════════════════════════════════════");

    try {
      print("   📡 Calling API Provider...");
      print("   ⏳ Request started at: ${DateTime.now()}");

      final response = await apiProvider.getDiamonds(
        page: page,
        limit: limit,
        search: search,
      );

      print("   ✅ API Response received at: ${DateTime.now()}");
      print("   📊 Response Status: ${response.statusCode}");
      print("   📊 Status Text: ${response.statusText}");
      print("─────────────────────────────────────────────────────────");
      print("   📄 Response Body (truncated):");

      // Print truncated response body for readability
      final responseBody = response.body.toString();
      if (responseBody.length > 500) {
        print("   ${responseBody.substring(0, 500)}...");
        print("   ... (${responseBody.length - 500} more characters)");
      } else {
        print("   $responseBody");
      }
      print("─────────────────────────────────────────────────────────");

      // ✅ Check status code
      if (response.statusCode == 200) {
        print("   ✅ Status 200 OK - Processing response...");

        // ✅ Check if response body is null
        if (response.body == null) {
          print("   ⚠️ Response body is null");
          print("   📦 Returning empty list");
          return [];
        }

        final body = response.body;

        // ✅ Check if body is Map
        if (body is! Map<String, dynamic>) {
          print("   ❌ ERROR: Unexpected response format");
          print("   Expected: Map<String, dynamic>");
          print("   Received: ${body.runtimeType}");
          print("   📦 Returning empty list");
          return [];
        }

        // ✅ Check success flag
        final success = body['success'] ?? false;
        print("   📊 Success flag: $success");

        if (!success) {
          final message = body['message'] ?? 'Unknown error';
          print("   ⚠️ API returned success: false");
          print("   Message: $message");
        }

        // ✅ Extract data
        final data = body['data'];

        if (data == null) {
          print("   ⚠️ 'data' key not found in response");
          print("   📦 Returning empty list");
          return [];
        }

        if (data is! List) {
          print("   ❌ ERROR: 'data' is not a List");
          print("   Data type: ${data.runtimeType}");
          print("   📦 Returning empty list");
          return [];
        }

        print("   📊 Data length: ${data.length} items");

        // ✅ Parse each diamond
        print("   🔄 Parsing ${data.length} diamonds...");
        final diamonds = <DiamondModel>[];

        for (int i = 0; i < data.length; i++) {
          try {
            final json = data[i] as Map<String, dynamic>;
            final diamond = DiamondModel.fromJson(json);
            diamonds.add(diamond);

            // Print first 3 diamonds for debugging
            if (i < 3) {
              print("      📇 Diamond ${i + 1}: ${diamond.title} (${diamond.certification}) - \$${diamond.price}");
            }
          } catch (e, stackTrace) {
            print("   ❌ Error parsing diamond at index $i:");
            print("      Error: $e");
            print("      Data: ${data[i]}");
            // Continue with next diamond
          }
        }

        print("   ✅ Successfully parsed ${diamonds.length} diamonds");
        print("   📦 Returning ${diamonds.length} diamonds");

        // ✅ Print summary
        if (diamonds.isNotEmpty) {
          print("─────────────────────────────────────────────────────────");
          print("   📊 SUMMARY:");
          print("      Total: ${diamonds.length}");
          print("      Certifications: ${diamonds.map((d) => d.certification).toSet().join(', ')}");
          print("      Shapes: ${diamonds.map((d) => d.shape).toSet().join(', ')}");
          print("      Price Range: \$${diamonds.map((d) => d.price).reduce((a, b) => a < b ? a : b)} - \$${diamonds.map((d) => d.price).reduce((a, b) => a > b ? a : b)}");
          print("─────────────────────────────────────────────────────────");
        }

        print("═══════════════════════════════════════════════════════════");
        print("✅ [Repository] getDiamonds() COMPLETE - ${diamonds.length} items");
        print("═══════════════════════════════════════════════════════════\n");

        return diamonds;
      }

      // ❌ Status code not 200
      print("   ❌ API ERROR: Status ${response.statusCode}");
      print("   📄 Error Response: ${response.body}");

      print("═══════════════════════════════════════════════════════════");
      print("❌ [Repository] getDiamonds() FAILED - Status ${response.statusCode}");
      print("═══════════════════════════════════════════════════════════\n");

      throw Exception(
        'Failed to load diamonds. Status: ${response.statusCode}',
      );

    } catch (e, stackTrace) {
      print("═══════════════════════════════════════════════════════════");
      print("❌ [Repository] EXCEPTION CAUGHT");
      print("═══════════════════════════════════════════════════════════");
      print("   Error: $e");
      print("   Type: ${e.runtimeType}");
      print("─────────────────────────────────────────────────────────");
      print("   📚 Stack Trace:");
      print("   $stackTrace");
      print("═══════════════════════════════════════════════════════════");
      print("   📦 Returning empty list due to exception");
      print("═══════════════════════════════════════════════════════════\n");

      return [];
    }
  }

  Future<DiamondModel?> getDiamondById(String id) async {
    print("\n═══════════════════════════════════════════════════════════");
    print("🔵 [Repository] getDiamondById() START");
    print("═══════════════════════════════════════════════════════════");
    print("   📋 ID: $id");
    print("═══════════════════════════════════════════════════════════");

    try {
      print("   📡 Calling API Provider...");

      final response = await apiProvider.getDiamondById(id);

      print("   ✅ API Response received");
      print("   📊 Status Code: ${response.statusCode}");
      print("─────────────────────────────────────────────────────────");
      print("   📄 Response Body:");

      final responseBody = response.body.toString();
      if (responseBody.length > 500) {
        print("   ${responseBody.substring(0, 500)}...");
      } else {
        print("   $responseBody");
      }
      print("─────────────────────────────────────────────────────────");

      // ✅ Check if successful
      if (response.statusCode == 200) {
        print("   ✅ Status 200 OK");

        if (response.body != null && response.body['data'] != null) {
          print("   🔄 Parsing diamond data...");

          try {
            final diamond = DiamondModel.fromJson(
              Map<String, dynamic>.from(response.body['data']),
            );

            print("   ✅ Diamond parsed successfully:");
            print("      ID: ${diamond.id}");
            print("      Title: ${diamond.title}");
            print("      Price: \$${diamond.price}");
            print("      Certification: ${diamond.certification}");

            print("═══════════════════════════════════════════════════════════");
            print("✅ [Repository] getDiamondById() COMPLETE - Found: ${diamond.title}");
            print("═══════════════════════════════════════════════════════════\n");

            return diamond;

          } catch (e, stackTrace) {
            print("   ❌ Error parsing diamond data:");
            print("      Error: $e");
            print("      StackTrace: $stackTrace");

            print("═══════════════════════════════════════════════════════════");
            print("❌ [Repository] getDiamondById() FAILED - Parse error");
            print("═══════════════════════════════════════════════════════════\n");

            return null;
          }
        } else {
          print("   ⚠️ Response body is null or missing 'data' key");

          print("═══════════════════════════════════════════════════════════");
          print("⚠️ [Repository] getDiamondById() - No data found for ID: $id");
          print("═══════════════════════════════════════════════════════════\n");

          return null;
        }
      }

      // ❌ Status code not 200
      print("   ❌ API ERROR: Status ${response.statusCode}");
      print("   📄 Error Response: ${response.body}");

      print("═══════════════════════════════════════════════════════════");
      print("❌ [Repository] getDiamondById() FAILED - Status ${response.statusCode}");
      print("═══════════════════════════════════════════════════════════\n");

      return null;

    } catch (e, stackTrace) {
      print("═══════════════════════════════════════════════════════════");
      print("❌ [Repository] getDiamondById() EXCEPTION CAUGHT");
      print("═══════════════════════════════════════════════════════════");
      print("   Error: $e");
      print("   Type: ${e.runtimeType}");
      print("─────────────────────────────────────────────────────────");
      print("   📚 Stack Trace:");
      print("   $stackTrace");
      print("═══════════════════════════════════════════════════════════\n");

      return null;
    }
  }
  // ─── GET DIAMOND BY SLUG ───────────────────────────────────────────────

  Future<DiamondModel?> getDiamondBySlug(String slug) async {
    print("\n═══════════════════════════════════════════════════════════");
    print("🔵 [Repository] getDiamondBySlug() START");
    print("═══════════════════════════════════════════════════════════");
    print("   📋 Slug: $slug");
    print("═══════════════════════════════════════════════════════════");

    try {
      print("   📡 Calling API Provider...");

      final response = await apiProvider.getDiamondBySlug(slug);

      print("   ✅ API Response received");
      print("   📊 Status Code: ${response.statusCode}");
      print("─────────────────────────────────────────────────────────");

      if (response.statusCode == 200) {
        print("   ✅ Status 200 OK");

        if (response.body != null && response.body['data'] != null) {
          print("   🔄 Parsing diamond data...");

          try {
            final diamond = DiamondModel.fromJson(
              Map<String, dynamic>.from(response.body['data']),
            );

            print("   ✅ Diamond parsed successfully:");
            print("      ID: ${diamond.id}");
            print("      Title: ${diamond.title}");
            print("      Price: \$${diamond.price}");
            print("      Certification: ${diamond.certification}");
            print("      Slug: ${diamond.slug}");

            print("═══════════════════════════════════════════════════════════");
            print("✅ [Repository] getDiamondBySlug() COMPLETE - Found: ${diamond.title}");
            print("═══════════════════════════════════════════════════════════\n");

            return diamond;

          } catch (e, stackTrace) {
            print("   ❌ Error parsing diamond data:");
            print("      Error: $e");
            print("      StackTrace: $stackTrace");

            print("═══════════════════════════════════════════════════════════");
            print("❌ [Repository] getDiamondBySlug() FAILED - Parse error");
            print("═══════════════════════════════════════════════════════════\n");

            return null;
          }
        } else {
          print("   ⚠️ Response body is null or missing 'data' key");

          print("═══════════════════════════════════════════════════════════");
          print("⚠️ [Repository] getDiamondBySlug() - No data found for slug: $slug");
          print("═══════════════════════════════════════════════════════════\n");

          return null;
        }
      }

      print("   ❌ API ERROR: Status ${response.statusCode}");
      print("   📄 Error Response: ${response.body}");

      print("═══════════════════════════════════════════════════════════");
      print("❌ [Repository] getDiamondBySlug() FAILED - Status ${response.statusCode}");
      print("═══════════════════════════════════════════════════════════\n");

      return null;

    } catch (e, stackTrace) {
      print("═══════════════════════════════════════════════════════════");
      print("❌ [Repository] getDiamondBySlug() EXCEPTION CAUGHT");
      print("═══════════════════════════════════════════════════════════");
      print("   Error: $e");
      print("   Type: ${e.runtimeType}");
      print("─────────────────────────────────────────────────────────");
      print("   📚 Stack Trace:");
      print("   $stackTrace");
      print("═══════════════════════════════════════════════════════════\n");

      return null;
    }
  }

  // ─── GET BEST SELLER DIAMONDS ───────────────────────────────────────────────

  Future<List<DiamondModel>> getBestSellerDiamonds() async {
    print("\n═══════════════════════════════════════════════════════════");
    print("🔵 [Repository] getBestSellerDiamonds() START");
    print("═══════════════════════════════════════════════════════════");

    try {
      final response = await apiProvider.getBestSellerDiamonds();

      print("📊 Status Code : ${response.statusCode}");
      print("📦 Response Body : ${response.body}");

      if (response.statusCode != 200) {
        print("❌ API Failed");
        return [];
      }

      if (response.body == null) {
        print("❌ Response body is null");
        return [];
      }

      final body = response.body;

      if (body is! Map<String, dynamic>) {
        print("❌ Invalid body format");
        return [];
      }

      final data = body['data'];

      if (data is! Map<String, dynamic>) {
        print("❌ Invalid data format");
        return [];
      }

      final diamonds = data['diamonds'];

      if (diamonds is! List) {
        print("❌ diamonds key not found");
        return [];
      }

      print("✅ Best Seller Count : ${diamonds.length}");

      final list = diamonds
          .map<DiamondModel>(
            (e) => DiamondModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList();

      print("✅ Parsed Count : ${list.length}");

      if (list.isNotEmpty) {
        print("✅ First Diamond : ${list.first.title}");
      }

      print("═══════════════════════════════════════════════════════════");
      print("✅ [Repository] getBestSellerDiamonds() COMPLETE");
      print("═══════════════════════════════════════════════════════════");

      return list;
    } catch (e, stackTrace) {
      print("═══════════════════════════════════════════════════════════");
      print("❌ [Repository] getBestSellerDiamonds() EXCEPTION");
      print("Error : $e");
      print(stackTrace);
      print("═══════════════════════════════════════════════════════════");

      return [];
    }
  }

  Future<List<DiamondModel>> getTrendingDiamonds() async {
    print("\n═══════════════════════════════════════════════════════════");
    print("🔵 [Repository] getTrendingDiamonds() START");
    print("═══════════════════════════════════════════════════════════");

    try {
      final response = await apiProvider.getTrendingDiamonds();

      print("📊 Status Code : ${response.statusCode}");
      print("📦 Response Body : ${response.body}");

      if (response.statusCode != 200) {
        print("❌ API Failed");
        return [];
      }

      if (response.body == null) {
        print("❌ Response body is null");
        return [];
      }

      final body = response.body;

      if (body is! Map<String, dynamic>) {
        print("❌ Invalid body format");
        return [];
      }

      final data = body['data'];

      if (data is! Map<String, dynamic>) {
        print("❌ Invalid data format");
        return [];
      }

      final diamonds = data['diamonds'];

      if (diamonds is! List) {
        print("❌ diamonds key not found");
        return [];
      }

      print("✅ Trending Count : ${diamonds.length}");

      final list = diamonds
          .map<DiamondModel>(
            (e) => DiamondModel.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList();

      print("✅ Parsed Count : ${list.length}");

      if (list.isNotEmpty) {
        print("✅ First Diamond : ${list.first.title}");
      }

      print("═══════════════════════════════════════════════════════════");
      print("✅ [Repository] getTrendingDiamonds() COMPLETE");
      print("═══════════════════════════════════════════════════════════");

      return list;
    } catch (e, stackTrace) {
      print("═══════════════════════════════════════════════════════════");
      print("❌ [Repository] getTrendingDiamonds() EXCEPTION");
      print("Error : $e");
      print(stackTrace);
      print("═══════════════════════════════════════════════════════════");

      return [];
    }
  }
}



