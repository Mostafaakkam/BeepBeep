import '../services/api_service.dart';
import '../../config/api_config.dart';
import '../../data/services/token_storage.dart';
import '../models/models.dart';

class ReviewRepository {
  final ApiService _apiService;

  ReviewRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<String?> _getToken() async {
    return await TokenStorage.getToken();
  }

  Future<Map<String, dynamic>> getProductReviews(int productId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.reviews}/product/$productId',
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final reviewsList = data['reviews'] as List<dynamic>? ?? [];
        final reviews = reviewsList
            .map((r) => Review.fromJson(r as Map<String, dynamic>))
            .toList();
        final summary = RatingSummary.fromJson(
          (data['summary'] as Map<String, dynamic>?) ?? const {},
        );
        return {'reviews': reviews, 'summary': summary};
      }

      return {
        'reviews': <Review>[],
        'summary': RatingSummary(reviewCount: 0, averageRating: 0.0),
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkEligibility(int productId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _apiService.get(
        '${ApiConfig.reviews}/product/$productId/eligibility',
        token: token,
      );

      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }

      return {
        'hasPurchased': false,
        'hasReviewed': false,
        'canReview': false,
        'existingReview': null,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createReview(int productId, int rating, String? comment) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _apiService.post(
        '${ApiConfig.reviews}/product/$productId',
        {
          'rating': rating,
          'comment': comment,
        },
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to submit review');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateReview(int reviewId, int rating, String? comment) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _apiService.patch(
        '${ApiConfig.reviews}/$reviewId',
        {
          'rating': rating,
          'comment': comment,
        },
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update review');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReview(int reviewId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await _apiService.delete(
        '${ApiConfig.reviews}/$reviewId',
        token: token,
      );

      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete review');
      }
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}
