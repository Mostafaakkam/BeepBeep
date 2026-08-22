import '../models/models.dart';
import '../services/api_service.dart';
import '../../config/api_config.dart';

class ProductRepository {
  final ApiService _apiService;
  
  ProductRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();
  
  Future<List<Product>> getAllProducts({
    int? storeId,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    bool inStock = false,
    String sortBy = 'newest',
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (storeId != null) queryParams['store_id'] = storeId.toString();
      if (categoryId != null) queryParams['category_id'] = categoryId.toString();
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (inStock) queryParams['in_stock'] = 'true';
      queryParams['sort'] = sortBy;
      
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final response = await _apiService.get(
        '${ApiConfig.products}?$queryString',
      );
      
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
