import '../services/api_service.dart';
import '../../config/api_config.dart';

class SearchRepository {
  final ApiService _apiService;
  
  SearchRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();
  
  Future<Map<String, dynamic>> search(String query) async {
    try {
      final response = await _apiService.get(
        '${ApiConfig.search}?q=${Uri.encodeComponent(query)}',
      );
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }
      
      return {'products': [], 'stores': []};
    } catch (e) {
      rethrow;
    }
  }
  
  void dispose() {
    _apiService.dispose();
  }
}
