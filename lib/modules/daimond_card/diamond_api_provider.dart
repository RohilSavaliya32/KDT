import 'dart:convert';
import 'package:get/get.dart';
import 'package:kdt/core/storage/api_constants.dart';

class DiamondApiProvider extends GetConnect {
  DiamondApiProvider() {
    print("🔵 [DiamondApiProvider] Instance created");
  }

  @override
  void onInit() {
    print("🔵 [DiamondApiProvider] onInit() START");

    httpClient.baseUrl = ApiConstants.baseUrl;
    httpClient.timeout = const Duration(seconds: 30);
    print("   📡 Base URL: ${httpClient.baseUrl}");
    print("   ⏱️ Timeout: ${httpClient.timeout}");

    // ✅ Request Interceptor
    httpClient.addRequestModifier<dynamic>((request) {
      print("\n═══════════════════════════════════════════════════════════");
      print("🔵 [API] REQUEST INTERCEPTOR");
      print("═══════════════════════════════════════════════════════════");
      print("   📤 Method: ${request.method}");
      print("   📤 URL: ${request.url}");

      // ✅ Log headers safely
      print("   📤 Headers:");
      request.headers?.forEach((key, value) {
        print("      $key: $value");
      });

      print("═══════════════════════════════════════════════════════════\n");

      return request;
    });

    // ✅ Response Interceptor
    httpClient.addResponseModifier((request, response) {
      print("\n═══════════════════════════════════════════════════════════");
      print("🟢 [API] RESPONSE INTERCEPTOR");
      print("═══════════════════════════════════════════════════════════");
      print("   📥 Status Code: ${response.statusCode}");
      print("   📥 Status Text: ${response.statusText}");
      print("   📥 Request URL: ${request.url}");
      print("─────────────────────────────────────────────────────────");

      // ✅ Log response headers safely
      print("   📥 Response Headers:");
      response.headers?.forEach((key, value) {
        print("      $key: $value");
      });
      print("─────────────────────────────────────────────────────────");

      // ✅ Log response body (truncated if too large)
      final bodyString = response.bodyString ?? '';
      print("   📥 Response Body (${bodyString.length} chars):");

      if (bodyString.length > 1000) {
        print("   ${bodyString.substring(0, 1000)}...");
        print("   ... (${bodyString.length - 1000} more characters)");
      } else {
        print("   $bodyString");
      }

      print("═══════════════════════════════════════════════════════════\n");

      return response;
    });

    super.onInit();
    print("🔵 [DiamondApiProvider] onInit() COMPLETE");
  }

  // ─── GET DIAMONDS ─────────────────────────────────────────────────────

  Future<Response> getDiamonds({
    int page = 1,
    int limit = 20,
    String search = '',
  }) async {
    print("\n═══════════════════════════════════════════════════════════");
    print("🔵 [API] getDiamonds() START");
    print("═══════════════════════════════════════════════════════════");
    print("   📋 Parameters:");
    print("      - Page: $page");
    print("      - Limit: $limit");
    print("      - Search: '${search.isEmpty ? '(empty)' : search}'");
    print("═══════════════════════════════════════════════════════════");

    // ✅ Build endpoint
    final endpoint = search.trim().isEmpty
        ? '/diamonds?page=$page&limit=$limit'
        : '/diamonds?page=$page&limit=$limit&search=$search';

    final fullUrl = '${httpClient.baseUrl}$endpoint';

    print("   📡 Endpoint: $endpoint");
    print("   📡 Full URL: $fullUrl");
    print("   ⏳ Request started at: ${DateTime.now()}");
    print("─────────────────────────────────────────────────────────");

    try {
      // ✅ Make API call
      final stopwatch = Stopwatch()..start();
      final response = await get(endpoint);
      stopwatch.stop();

      print("   ✅ Response received in ${stopwatch.elapsedMilliseconds}ms");
      print("   📊 Status Code: ${response.statusCode}");
      print("   📊 Status Text: ${response.statusText}");

      // ✅ Log response details
      print("─────────────────────────────────────────────────────────");
      print("   📥 Response Headers:");
      response.headers?.forEach((key, value) {
        print("      $key: $value");
      });

      // ✅ Log response body
      print("─────────────────────────────────────────────────────────");
      print("   📥 Response Body:");

      final bodyString = response.bodyString ?? '';
      if (bodyString.isEmpty) {
        print("      (empty response)");
      } else if (bodyString.length > 800) {
        print("      ${bodyString.substring(0, 800)}...");
        print("      ... (${bodyString.length - 800} more characters)");
      } else {
        print("      $bodyString");
      }

      // ✅ Try to parse as JSON for pretty print
      try {
        if (bodyString.isNotEmpty) {
          final json = jsonDecode(bodyString);
          print("─────────────────────────────────────────────────────────");
          print("   📊 Parsed JSON Structure:");
          print("      - Type: ${json.runtimeType}");

          if (json is Map<String, dynamic>) {
            print("      - Keys: ${json.keys.join(', ')}");

            // ✅ Check success flag
            final success = json['success'] ?? false;
            print("      - Success: $success");

            // ✅ Check data count
            final data = json['data'];
            if (data is List) {
              print("      - Data Count: ${data.length}");
            } else if (data != null) {
              print("      - Data Type: ${data.runtimeType}");
            }

            // ✅ Check message
            final message = json['message'];
            if (message != null) {
              print("      - Message: $message");
            }
          } else if (json is List) {
            print("      - Data Count: ${json.length}");
          }
        }
      } catch (e) {
        print("   ⚠️ Could not parse JSON: $e");
      }

      print("─────────────────────────────────────────────────────────");
      print("   ✅ Request completed");
      print("═══════════════════════════════════════════════════════════");
      print("✅ [API] getDiamonds() COMPLETE - Status: ${response.statusCode}");
      print("═══════════════════════════════════════════════════════════\n");

      return response;

    } catch (e, stackTrace) {
      print("═══════════════════════════════════════════════════════════");
      print("❌ [API] getDiamonds() EXCEPTION");
      print("═══════════════════════════════════════════════════════════");
      print("   Error: $e");
      print("   Type: ${e.runtimeType}");
      print("─────────────────────────────────────────────────────────");
      print("   📚 Stack Trace:");
      print("   $stackTrace");
      print("═══════════════════════════════════════════════════════════\n");

      rethrow;
    }
  }

  // ─── GET DIAMOND BY ID ───────────────────────────────────────────────

  Future<Response> getDiamondById(String id) async {
    print("\n═══════════════════════════════════════════════════════════");
    print("🔵 [API] getDiamondById() START");
    print("═══════════════════════════════════════════════════════════");
    print("   📋 ID: $id");
    print("═══════════════════════════════════════════════════════════");

    final endpoint = '/diamonds/$id';
    final fullUrl = '${httpClient.baseUrl}$endpoint';

    print("   📡 Endpoint: $endpoint");
    print("   📡 Full URL: $fullUrl");
    print("   ⏳ Request started at: ${DateTime.now()}");
    print("─────────────────────────────────────────────────────────");

    try {
      // ✅ Make API call
      final stopwatch = Stopwatch()..start();
      final response = await get(endpoint);
      stopwatch.stop();

      print("   ✅ Response received in ${stopwatch.elapsedMilliseconds}ms");
      print("   📊 Status Code: ${response.statusCode}");
      print("   📊 Status Text: ${response.statusText}");

      // ✅ Log response details
      print("─────────────────────────────────────────────────────────");
      print("   📥 Response Headers:");
      response.headers?.forEach((key, value) {
        print("      $key: $value");
      });

      // ✅ Log response body
      print("─────────────────────────────────────────────────────────");
      print("   📥 Response Body:");

      final bodyString = response.bodyString ?? '';
      if (bodyString.isEmpty) {
        print("      (empty response)");
      } else if (bodyString.length > 800) {
        print("      ${bodyString.substring(0, 800)}...");
        print("      ... (${bodyString.length - 800} more characters)");
      } else {
        print("      $bodyString");
      }

      // ✅ Try to parse as JSON for pretty print
      try {
        if (bodyString.isNotEmpty) {
          final json = jsonDecode(bodyString);
          print("─────────────────────────────────────────────────────────");
          print("   📊 Parsed JSON Structure:");
          print("      - Type: ${json.runtimeType}");

          if (json is Map<String, dynamic>) {
            print("      - Keys: ${json.keys.join(', ')}");

            // ✅ Check success flag
            final success = json['success'] ?? false;
            print("      - Success: $success");

            // ✅ Check data
            final data = json['data'];
            if (data is Map<String, dynamic>) {
              print("      - Data Keys: ${data.keys.join(', ')}");

              // ✅ Show diamond details
              final title = data['title'] ?? 'N/A';
              final price = data['price'] ?? 'N/A';
              final certification = data['certification'] ?? 'N/A';
              print("      - Diamond: $title");
              print("      - Price: \$$price");
              print("      - Certification: $certification");
            } else if (data != null) {
              print("      - Data Type: ${data.runtimeType}");
            }

            // ✅ Check message
            final message = json['message'];
            if (message != null) {
              print("      - Message: $message");
            }
          }
        }
      } catch (e) {
        print("   ⚠️ Could not parse JSON: $e");
      }

      print("─────────────────────────────────────────────────────────");
      print("   ✅ Request completed");
      print("═══════════════════════════════════════════════════════════");
      print("✅ [API] getDiamondById() COMPLETE - Status: ${response.statusCode}");
      print("═══════════════════════════════════════════════════════════\n");

      return response;

    } catch (e, stackTrace) {
      print("═══════════════════════════════════════════════════════════");
      print("❌ [API] getDiamondById() EXCEPTION");
      print("═══════════════════════════════════════════════════════════");
      print("   Error: $e");
      print("   Type: ${e.runtimeType}");
      print("─────────────────────────────────────────────────────────");
      print("   📚 Stack Trace:");
      print("   $stackTrace");
      print("═══════════════════════════════════════════════════════════\n");

      rethrow;
    }
  }
// ─── GET DIAMOND BY SLUG ───────────────────────────────────────────────

  Future<Response> getDiamondBySlug(String slug) async {
    print("\n═══════════════════════════════════════════════════════════");
    print("🔵 [API] getDiamondBySlug() START");
    print("═══════════════════════════════════════════════════════════");
    print("   📋 Slug: $slug");
    print("═══════════════════════════════════════════════════════════");

    final endpoint = '/diamonds/$slug';
    final fullUrl = '${httpClient.baseUrl}$endpoint';

    print("   📡 Endpoint: $endpoint");
    print("   📡 Full URL: $fullUrl");
    print("   ⏳ Request started at: ${DateTime.now()}");
    print("─────────────────────────────────────────────────────────");

    try {
      final stopwatch = Stopwatch()..start();
      final response = await get(endpoint);
      stopwatch.stop();

      print("   ✅ Response received in ${stopwatch.elapsedMilliseconds}ms");
      print("   📊 Status Code: ${response.statusCode}");
      print("   📊 Status Text: ${response.statusText}");

      // Log response body
      print("─────────────────────────────────────────────────────────");
      print("   📥 Response Body:");

      final bodyString = response.bodyString ?? '';
      if (bodyString.isEmpty) {
        print("      (empty response)");
      } else if (bodyString.length > 800) {
        print("      ${bodyString.substring(0, 800)}...");
        print("      ... (${bodyString.length - 800} more characters)");
      } else {
        print("      $bodyString");
      }

      // Try to parse JSON
      try {
        if (bodyString.isNotEmpty) {
          final json = jsonDecode(bodyString);
          print("─────────────────────────────────────────────────────────");
          print("   📊 Parsed JSON Structure:");
          print("      - Type: ${json.runtimeType}");

          if (json is Map<String, dynamic>) {
            print("      - Keys: ${json.keys.join(', ')}");
            final success = json['success'] ?? false;
            print("      - Success: $success");

            final data = json['data'];
            if (data is Map<String, dynamic>) {
              print("      - Data Keys: ${data.keys.join(', ')}");
              final title = data['title'] ?? 'N/A';
              final price = data['price'] ?? 'N/A';
              print("      - Diamond: $title");
              print("      - Price: \$$price");
            }
          }
        }
      } catch (e) {
        print("   ⚠️ Could not parse JSON: $e");
      }

      print("─────────────────────────────────────────────────────────");
      print("   ✅ Request completed");
      print("═══════════════════════════════════════════════════════════");
      print("✅ [API] getDiamondBySlug() COMPLETE - Status: ${response.statusCode}");
      print("═══════════════════════════════════════════════════════════\n");

      return response;

    } catch (e, stackTrace) {
      print("═══════════════════════════════════════════════════════════");
      print("❌ [API] getDiamondBySlug() EXCEPTION");
      print("═══════════════════════════════════════════════════════════");
      print("   Error: $e");
      print("   Type: ${e.runtimeType}");
      print("─────────────────────────────────────────────────────────");
      print("   📚 Stack Trace:");
      print("   $stackTrace");
      print("═══════════════════════════════════════════════════════════\n");

      rethrow;
    }
  }

  // ─── GET BEST SELLER DIAMONDS ─────────────────────────────────────────────

  Future<Response> getBestSellerDiamonds() async {
    print("\n═══════════════════════════════════════════════════════════");
    print("🔵 [API] getBestSellerDiamonds() START");
    print("═══════════════════════════════════════════════════════════");

    const endpoint =
        '/diamonds?sortBy=best-seller&limit=8&pagination=true';

    final fullUrl = '${httpClient.baseUrl}$endpoint';

    print("   📡 Endpoint: $endpoint");
    print("   📡 Full URL: $fullUrl");
    print("─────────────────────────────────────────────────────────");

    try {
      final stopwatch = Stopwatch()..start();
      print("➡️ Calling GET...");

      final response = await get(endpoint);

      print("⬅️ GET Finished");
      stopwatch.stop();

      print("   ✅ Response received in ${stopwatch.elapsedMilliseconds}ms");
      print("   📊 Status Code: ${response.statusCode}");
      print("═══════════════════════════════════════════════════════════");
      print("✅ [API] getBestSellerDiamonds() COMPLETE");
      print("═══════════════════════════════════════════════════════════");

      return response;
    } catch (e, stackTrace) {
      print("═══════════════════════════════════════════════════════════");
      print("❌ [API] getBestSellerDiamonds() EXCEPTION");
      print("Error: $e");
      print("❌ ERROR TYPE : ${e.runtimeType}");
      print(stackTrace);
      rethrow;
      print("═══════════════════════════════════════════════════════════");

      rethrow;
    }
  }
  Future<Response> getTrendingDiamonds() async  {
    print("\n═══════════════════════════════════════════════════════════");
    print("🔵 [API] getTrendingDiamonds() START");
    print("═══════════════════════════════════════════════════════════");

    const endpoint =
        '/diamonds?sortBy=trending&limit=6&pagination=true';

    final fullUrl = '${httpClient.baseUrl}$endpoint';

    print("   📡 Endpoint: $endpoint");
    print("   📡 Full URL: $fullUrl");
    print("─────────────────────────────────────────────────────────");

    try {
      final stopwatch = Stopwatch()..start();

      print("➡️ Calling GET...");

      final response = await get(endpoint);

      print("⬅️ GET Finished");

      stopwatch.stop();

      print("   ✅ Response received in ${stopwatch.elapsedMilliseconds}ms");
      print("   📊 Status Code: ${response.statusCode}");
      print("═══════════════════════════════════════════════════════════");
      print("✅ [API] getTrendingDiamonds() COMPLETE");
      print("═══════════════════════════════════════════════════════════");

      return response;
    } catch (e, stackTrace) {
      print("═══════════════════════════════════════════════════════════");
      print("❌ [API] getTrendingDiamonds() EXCEPTION");
      print("Error: $e");
      print("❌ ERROR TYPE : ${e.runtimeType}");
      print(stackTrace);
      print("═══════════════════════════════════════════════════════════");

      rethrow;
    }
  }
}



