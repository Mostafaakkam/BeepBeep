import 'package:flutter/foundation.dart';
import '../../../../data/repositories/review_repository.dart';
import '../../../../data/models/models.dart';

enum ReviewListState {
  initial,
  loading,
  success,
  error,
}

class ReviewViewModel extends ChangeNotifier {
  final ReviewRepository _repository;

  ReviewListState _state = ReviewListState.initial;
  List<Review> _reviews = [];
  RatingSummary _summary = RatingSummary(reviewCount: 0, averageRating: 0.0);
  String? _errorMessage;

  bool _eligibilityChecked = false;
  bool _hasPurchased = false;
  bool _hasReviewed = false;
  bool _canReview = false;
  Review? _existingReview;

  bool _isSubmitting = false;
  String? _submitError;

  ReviewViewModel({ReviewRepository? repository})
      : _repository = repository ?? ReviewRepository();

  ReviewListState get state => _state;
  List<Review> get reviews => _reviews;
  RatingSummary get summary => _summary;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == ReviewListState.loading;
  bool get isSuccess => _state == ReviewListState.success;
  bool get isError => _state == ReviewListState.error;
  bool get hasReviews => _reviews.isNotEmpty;

  bool get eligibilityChecked => _eligibilityChecked;
  bool get hasPurchased => _hasPurchased;
  bool get hasReviewed => _hasReviewed;
  bool get canReview => _canReview;
  Review? get existingReview => _existingReview;

  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;

  Future<void> loadReviews(int productId) async {
    _state = ReviewListState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getProductReviews(productId);
      _reviews = result['reviews'] as List<Review>;
      _summary = result['summary'] as RatingSummary;
      _state = ReviewListState.success;
      notifyListeners();
    } catch (e) {
      _state = ReviewListState.error;
      _errorMessage = 'Failed to load reviews. Please try again.';
      _reviews = [];
      notifyListeners();
    }
  }

  Future<void> retry(int productId) async {
    await loadReviews(productId);
  }

  Future<void> checkEligibility(int productId) async {
    try {
      final result = await _repository.checkEligibility(productId);
      _hasPurchased = result['hasPurchased'] as bool? ?? false;
      _hasReviewed = result['hasReviewed'] as bool? ?? false;
      _canReview = result['canReview'] as bool? ?? false;
      final existingJson = result['existingReview'] as Map<String, dynamic>?;
      _existingReview =
          existingJson != null ? Review.fromJson(existingJson) : null;
      _eligibilityChecked = true;
      notifyListeners();
    } catch (e) {
      _hasPurchased = false;
      _hasReviewed = false;
      _canReview = false;
      _existingReview = null;
      _eligibilityChecked = false;
      notifyListeners();
    }
  }

  Future<bool> submitReview({
    required int productId,
    required int rating,
    String? comment,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      await _repository.createReview(productId, rating, comment);
      await loadReviews(productId);
      await checkEligibility(productId);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _submitError = 'Failed to submit review. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> editReview({
    required int productId,
    required int reviewId,
    required int rating,
    String? comment,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      await _repository.updateReview(reviewId, rating, comment);
      await loadReviews(productId);
      await checkEligibility(productId);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _submitError = 'Failed to update review. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeReview({
    required int productId,
    required int reviewId,
  }) async {
    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    try {
      await _repository.deleteReview(reviewId);
      await loadReviews(productId);
      await checkEligibility(productId);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _submitError = 'Failed to delete review. Please try again.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
