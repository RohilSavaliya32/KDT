
// import 'package:dio/dio.dart';
// import '../../../core/storage/secure_storage.dart';
//
// class WishlistApiService {
//   WishlistApiService({Dio? dio}) : _dio = dio ?? Dio() {
//     _dio.options = BaseOptions(
//       baseUrl: _baseUrl,
//       connectTimeout: const Duration(seconds: 30),
//       receiveTimeout: const Duration(seconds: 30),
//       sendTimeout: const Duration(seconds: 30),
//       headers: {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       },
//     );
//   }
//
//   final Dio _dio;
//   static const String _baseUrl = 'http://193.46.198.103/api/v1';
//
//   Future<Options> _getAuthOptions() async {
//     final token = await SecureStorage.getToken();
//
//     return Options(
//       headers: {
//         if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
//       },
//     );
//   }
//
//   // Check if user is logged in
//   Future<bool> isLoggedIn() async {
//     final token = await SecureStorage.getToken();
//     return token != null && token.isNotEmpty;
//   }
//
//   Map<String, dynamic> _asMap(dynamic data) {
//     if (data is Map<String, dynamic>) return data;
//     if (data is Map) return Map<String, dynamic>.from(data);
//     return <String, dynamic>{};
//   }
//
//   Future<Map<String, dynamic>> updateWishlist(
//       List<Map<String, dynamic>> wishlistItems,
//       ) async {
//     try {
//       final options = await _getAuthOptions();
//
//       final response = await _dio.put(
//         '/auth/wishlist',
//         data: {
//           'wishlist': wishlistItems,
//         },
//         options: options,
//       );
//
//       return _asMap(response.data);
//     } on DioException catch (e) {
//       throw Exception(_getErrorMessage(e));
//     } catch (e) {
//       throw Exception('Wishlist update failed: $e');
//     }
//   }
//
//   Future<Map<String, dynamic>> getMyProfile() async {
//     try {
//       final options = await _getAuthOptions();
//
//       final response = await _dio.get(
//         '/auth/profile',
//         options: options,
//       );
//
//       return _asMap(response.data);
//     } on DioException catch (e) {
//       throw Exception(_getErrorMessage(e));
//     } catch (e) {
//       throw Exception('Profile fetch failed: $e');
//     }
//   }
//
//   String _getErrorMessage(DioException e) {
//     if (e.response?.data is Map) {
//       final data = Map<String, dynamic>.from(e.response!.data);
//       if (data['message'] != null) return data['message'].toString();
//       if (data['error'] != null) return data['error'].toString();
//     }
//
//     switch (e.type) {
//       case DioExceptionType.connectionTimeout:
//         return 'Connection timeout';
//       case DioExceptionType.sendTimeout:
//         return 'Send timeout';
//       case DioExceptionType.receiveTimeout:
//         return 'Receive timeout';
//       case DioExceptionType.badResponse:
//         return 'Server error: ${e.response?.statusCode}';
//       case DioExceptionType.cancel:
//         return 'Request cancelled';
//       case DioExceptionType.connectionError:
//         return 'No internet connection';
//       default:
//         return 'Something went wrong';
//     }
//   }
// }



import 'package:dio/dio.dart';
import 'package:kdt/core/storage/api_constants.dart';
import '../../../core/storage/secure_storage.dart';

class WishlistApiService {
  WishlistApiService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  final Dio _dio;
  static const String _baseUrl = ApiConstants.baseUrl;

  Future<Options> _getAuthOptions() async {
    final token = await SecureStorage.getToken();

    return Options(
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await SecureStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  // ============ UPDATE WISHLIST ============
  Future<Map<String, dynamic>> updateWishlist(
      List<Map<String, dynamic>> wishlistItems,
      ) async {
    try {
      final options = await _getAuthOptions();

      final response = await _dio.put(
        ApiConstants.wishlist,
        data: {
          'wishlist': wishlistItems,
        },
        options: options,
      );

      return _asMap(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('Wishlist update failed: $e');
    }
  }

  // ============ GET MY PROFILE ============
  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final options = await _getAuthOptions();

      final response = await _dio.get(
        ApiConstants.profile,
        options: options,
      );

      return _asMap(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('Profile fetch failed: $e');
    }
  }

  // ============ ADD TO WISHLIST ============
  Future<Map<String, dynamic>> addToWishlist(String diamondId) async {
    try {
      final options = await _getAuthOptions();

      final response = await _dio.post(
        ApiConstants.wishlistAdd,
        data: {
          'diamondId': diamondId,
        },
        options: options,
      );

      return _asMap(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('Add to wishlist failed: $e');
    }
  }

  // ============ REMOVE FROM WISHLIST ============
  Future<Map<String, dynamic>> removeFromWishlist(String diamondId) async {
    try {
      final options = await _getAuthOptions();

      final response = await _dio.delete(
        '/auth/wishlist/remove/$diamondId',
        options: options,
      );

      return _asMap(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('Remove from wishlist failed: $e');
    }
  }

  // ============ SYNC WISHLIST (MERGE) ============
  Future<Map<String, dynamic>> syncWishlist(
      List<Map<String, dynamic>> wishlistItems,
      ) async {
    try {
      final options = await _getAuthOptions();

      final response = await _dio.post(
        '/auth/wishlist/sync',
        data: {
          'wishlist': wishlistItems,
        },
        options: options,
      );

      return _asMap(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('Sync wishlist failed: $e');
    }
  }

  // ============ GET WISHLIST ONLY ============
  Future<Map<String, dynamic>> getWishlist() async {
    try {
      final options = await _getAuthOptions();

      final response = await _dio.get(
        ApiConstants.wishlist,
        options: options,
      );

      return _asMap(response.data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('Get wishlist failed: $e');
    }
  }

  // ============ CHECK IF DIAMOND IN WISHLIST ============
  Future<bool> isInWishlist(String diamondId) async {
    try {
      final options = await _getAuthOptions();

      final response = await _dio.get(
        '/auth/wishlist/check/$diamondId',
        options: options,
      );

      final data = _asMap(response.data);
      return data['inWishlist'] ?? false;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    } catch (e) {
      throw Exception('Check wishlist failed: $e');
    }
  }

  // ============ ERROR MESSAGE HANDLER ============
  String _getErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      final data = Map<String, dynamic>.from(e.response!.data);
      if (data['message'] != null) return data['message'].toString();
      if (data['error'] != null) return data['error'].toString();
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Please try again.';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return 'Session expired. Please login again.';
        }
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}