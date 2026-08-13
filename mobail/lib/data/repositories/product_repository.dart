import '../models/models.dart';
import '../services/api_service.dart';
import '../../config/api_config.dart';

class ProductRepository {
  final ApiService _apiService;
  
  ProductRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();
  
  Future<List<Product>> getAllProducts({int? storeId}) async {
    try {
      String endpoint = ApiConfig.products;
      if (storeId != null) {
        endpoint += '?store_id=$storeId';
      }
      
      final response = await _apiService.get(endpoint);
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> productsData = response['data'] as List<dynamic>;
        return productsData.map((productData) => Product.fromJson(productData as Map<String, dynamic>)).toList();
      }
      
      return [];
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Product> getProductById(int id) async {
    try {
      final response = await _apiService.get('${ApiConfig.products}/$id');
      
      if (response['success'] == true && response['data'] != null) {
        return Product.fromJson(response['data'] as Map<String, dynamic>);
      }
      
      throw Exception('Failed to fetch product');
    } catch (e) {
      rethrow;
    }
  }
  
  void dispose() {
    _apiService.dispose();
  }
}
