import '../services/api_service.dart';
import '../../config/api_config.dart';
import '../../data/services/token_storage.dart';

class FavoriteRepository {
  final ApiService _apiService;
  
  FavoriteRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();
  
  Future<String?> _getToken() async {
    return await TokenStorage.getToken();
  }
  
  Future<List<dynamic>> getFavorites() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.get(
        ApiConfig.favorites,
        token: token,
      );
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as List<dynamic>;
      }
      
      return [];
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> addFavorite(int productId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.post(
        ApiConfig.favorites,
        {'product_id': productId},
        token: token,
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to add favorite');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> removeFavorite(int productId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.delete(
        '${ApiConfig.favorites}/$productId',
        token: token,
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to remove favorite');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<bool> checkFavorite(int productId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.get(
        '${ApiConfig.favorites}/check/$productId',
        token: token,
      );
      
      if (response['success'] == true && response['data'] != null) {
        return response['data']['isFavorited'] as bool;
      }
      
      return false;
    } catch (e) {
      // Return false on error (not favorited)
      return false;
    }
  }
  
  void dispose() {
    _apiService.dispose();
  }
}
