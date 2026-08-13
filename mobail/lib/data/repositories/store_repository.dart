import '../models/models.dart';
import '../services/api_service.dart';
import '../../config/api_config.dart';

class StoreRepository {
  final ApiService _apiService;
  
  StoreRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();
  
  Future<List<Store>> getAllStores() async {
    try {
      final response = await _apiService.get(ApiConfig.stores);
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> storesData = response['data'] as List<dynamic>;
        return storesData.map((storeData) => Store.fromJson(storeData as Map<String, dynamic>)).toList();
      }
      
      return [];
    } catch (e) {
      rethrow;
    }
  }
  
  Future<Store> getStoreById(int id) async {
    try {
      final response = await _apiService.get('${ApiConfig.stores}/$id');
      
      if (response['success'] == true && response['data'] != null) {
        return Store.fromJson(response['data'] as Map<String, dynamic>);
      }
      
      throw Exception('Failed to fetch store');
    } catch (e) {
      rethrow;
    }
  }
  
  void dispose() {
    _apiService.dispose();
  }
}
