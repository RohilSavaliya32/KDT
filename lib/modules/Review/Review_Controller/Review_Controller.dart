import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Model/Review_Model.dart';
import '../ReviewApiService/Review_Api_Service.dart';

class ReviewController extends GetxController {
  final ReviewApiService _api = ReviewApiService();

  final reviews = <ReviewModel>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final selectedRating = 0.0.obs; // Changed to double for half-star support
  final hasReviewed = false.obs;
  final editingReview = Rxn<ReviewModel>();

  final TextEditingController commentController = TextEditingController();

  String currentUserId = '';

  bool get isEditing => editingReview.value != null;

  ReviewModel? get myReview {
    if (currentUserId.isEmpty) return null;
    for (final r in reviews) {
      if (r.userId == currentUserId) return r;
    }
    return null;
  }

  void setCurrentUserId(String userId) {
    currentUserId = userId;
    debugPrint('Current User ID => $currentUserId');

    hasReviewed.value =
        currentUserId.isNotEmpty && reviews.any((r) => r.userId == currentUserId);

    debugPrint('Has Reviewed After Set User => ${hasReviewed.value}');
  }

  void startEditReview(ReviewModel review) {
    editingReview.value = review;
    selectedRating.value = review.rating;
    commentController.text = review.comment;

    debugPrint('===== START EDIT REVIEW =====');
    debugPrint('Review ID => ${review.id}');
    debugPrint('User ID => ${review.userId}');
    debugPrint('Rating => ${review.rating}');
    debugPrint('Comment => ${review.comment}');
  }

  void cancelEdit() {
    editingReview.value = null;
    selectedRating.value = 0.0;
    commentController.clear();
  }

  Future<void> loadReviews(String diamondId) async {
    try {
      debugPrint('===== LOAD REVIEWS START =====');
      debugPrint('Diamond ID => $diamondId');

      isLoading.value = true;

      final result = await _api.getReviews(diamondId);

      debugPrint('Fetched Reviews Count => ${result.length}');
      reviews.assignAll(result);

      debugPrint('Assigned Reviews Count => ${reviews.length}');
      for (int i = 0; i < reviews.length; i++) {
        final r = reviews[i];
        debugPrint(
          'UI Review #$i => userId: ${r.userId}, rating: ${r.rating}, comment: ${r.comment}',
        );
      }

      hasReviewed.value =
          currentUserId.isNotEmpty && reviews.any((r) => r.userId == currentUserId);

      debugPrint('Current User ID => $currentUserId');
      debugPrint('Has Reviewed => ${hasReviewed.value}');
      debugPrint('===== LOAD REVIEWS END =====');
    } catch (e) {
      debugPrint('LOAD REVIEW ERROR => $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitReview(String diamondId) async {
    final rating = selectedRating.value;
    final comment = commentController.text.trim();

    if (rating == 0) {
      return;
    }

    if (comment.isEmpty) {
      return;
    }

    try {
      isSubmitting.value = true;

      final reviewId =
      editingReview.value != null ? editingReview.value!.id.trim() : null;

      final saved = await _api.submitOrUpdateReview(
        diamondId: diamondId,
        rating: rating.toInt(), // API might expect int, but model is double. 
        // If API supports double, change to rating.
        comment: comment,
        reviewId: reviewId,
      );

      if (saved != null) {
        await loadReviews(diamondId);

        if (editingReview.value != null) {
          cancelEdit();
        } else {
          selectedRating.value = 0.0;
          commentController.clear();
        }

        hasReviewed.value = true;
      } else {
      }
    } catch (e) {
      debugPrint('SUBMIT/UPDATE REVIEW ERROR => $e');
      Get.snackbar('Error', 'Unable to save review');
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}