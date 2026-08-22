import '../models/models.dart';
import '../services/api_service.dart';
import '../../config/api_config.dart';
import '../../data/services/token_storage.dart';

class AddressRepository {
  final ApiService _apiService;
  
  AddressRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();
  
  Future<String?> _getToken() async {
    return await TokenStorage.getToken();
  }
  
  Future<List<AddressModel>> getAddresses() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.get(
        ApiConfig.addresses,
        token: token,
      );
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'] as List<dynamic>;
        return data.map((json) => AddressModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      
      return [];
    } catch (e) {
      rethrow;
    }
  }
  
  Future<AddressModel?> getAddress(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.get(
        '${ApiConfig.addresses}/$id',
        token: token,
      );
      
      if (response['success'] == true && response['data'] != null) {
        return AddressModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      
      return null;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<AddressModel> createAddress(AddressModel address) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.post(
        ApiConfig.addresses,
        address.toCreateJson(),
        token: token,
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to create address');
      }
      
      // Get the created address
      if (response['data'] != null && response['data']['id'] != null) {
        return await getAddress(response['data']['id'] as int) ?? address;
      }
      
      return address;
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateAddress(AddressModel address) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.patch(
        '${ApiConfig.addresses}/${address.id}',
        address.toCreateJson(),
        token: token,
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to update address');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteAddress(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.delete(
        '${ApiConfig.addresses}/$id',
        token: token,
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to delete address');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> setDefaultAddress(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.patch(
        '${ApiConfig.addresses}/$id/default',
        {},
        token: token,
      );
      
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'Failed to set default address');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Future<AddressModel?> getDefaultAddress() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      
      final response = await _apiService.get(
        '${ApiConfig.addresses}/default',
        token: token,
      );
      
      if (response['success'] == true && response['data'] != null) {
        return AddressModel.fromJson(response['data'] as Map<String, dynamic>);
      }
      
      return null;
    } catch (e) {
      // Return null on error (no default address)
      return null;
    }
  }
  
  void dispose() {
    _apiService.dispose();
  }
}
