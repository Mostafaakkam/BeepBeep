import '../models/models.dart';
import '../services/api_service.dart';
import '../../config/api_config.dart';

class CategoryRepository {
  final ApiService _apiService;
  
  CategoryRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();
  
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiService.get(
        ApiConfig.categories,
      );
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        return data.map((json) => CategoryModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      return [];
    } catch (e) {
      rethrow;
    }
  }
  
  Future<CategoryModel?> getCategory(int id) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.categories}/$id',
      );
      
      if (response['success'] == true && response['data'] != null) {
        return CategoryModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<List<dynamic>> getProductsByCategory(int categoryId) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.categories}/$categoryId/products',
      );
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as List<dynamic>;
      }
      
      return [];
    } catch (e) {
      rethrow;
    }
  }
  
  void dispose() {
    _apiService.dispose();
  }
}
