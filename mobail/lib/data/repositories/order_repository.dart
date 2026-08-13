import '../models/models.dart';
import '../services/api_service.dart';
import '../../config/api_config.dart';
import '../../data/services/token_storage.dart';

class OrderRepository {
  final ApiService _apiService;
  
  OrderRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();
  
  Future<String?> _getToken() async {
    return await TokenStorage.getToken();
  }
  
  Future<List<Order>> getOrders() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.get(
        ApiConfig.orders,
        token: token,
      );
      
      if (response['success'] == true && response['data'] != null) {
        final ordersList = response['data'] as List<dynamic>;
        return ordersList.map((order) => Order.fromJson(order as Map<String, dynamic>)).toList();
      }
      
      return [];
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Order> getOrderById(int orderId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.get(
        '${ApiConfig.orders}/$orderId',
        token: token,
      );
      
      if (response['success'] == true && response['data'] != null) {
        return Order.fromJson(response['data'] as Map<String, dynamic>);
      }
      
      throw Exception('Failed to fetch order');
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> createOrder({
    required String customerName,
    required String customerPhone,
    required String deliveryAddress,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.post(
        ApiConfig.orders,
        {
          'customer_name': customerName,
          'customer_phone': customerPhone,
          'delivery_address': deliveryAddress,
        },
        token: token,
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to create order');
      }
      
      return response['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> cancelOrder(int orderId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.patch(
        '${ApiConfig.orders}/$orderId/cancel',
        {},
        token: token,
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  void dispose() {
    _apiService.dispose();
  }
}
