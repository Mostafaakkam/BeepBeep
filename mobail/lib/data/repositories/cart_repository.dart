import '../models/models.dart';
import '../services/api_service.dart';
import '../../config/api_config.dart';
import '../../data/services/token_storage.dart';

class CartRepository {
  final ApiService _apiService;
  
  CartRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();
  
  Future<String?> _getToken() async {
    return await TokenStorage.getToken();
  }
  
  Future<Cart> getCart() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.get(
        ApiConfig.cart,
        token: token,
      );
      
      if (response['success'] == true && response['data'] != null) {
        return Cart.fromJson(response['data'] as Map<String, dynamic>);
      }
      
      return Cart(items: [], itemsCount: 0, subtotal: 0, total: 0);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> addItem({
    required int productId,
    required int variantId,
    required int quantity,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.post(
        '${ApiConfig.cart}/items',
        {
          'product_id': productId,
          'variant_id': variantId,
          'quantity': quantity,
        },
        token: token,
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to add item to cart');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateItemQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.patch(
        '${ApiConfig.cart}/items/$cartItemId',
        {'quantity': quantity},
        token: token,
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update cart item');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> removeItem(int cartItemId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.delete(
        '${ApiConfig.cart}/items/$cartItemId',
        token: token,
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to remove cart item');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> clearCart() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.delete(
        ApiConfig.cart,
        token: token,
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to clear cart');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  void dispose() {
    _apiService.dispose();
  }
}
