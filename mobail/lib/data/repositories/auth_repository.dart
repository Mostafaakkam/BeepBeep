import '../models/models.dart';
import '../services/api_service.dart';
import '../../config/api_config.dart';

class AuthRepository {
  final ApiService _apiService;
  
  AuthRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();
  
  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        request.toJson(),
      );
      
      return RegisterResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        request.toJson(),
      );
      
      return LoginResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
  
  void dispose() {
    _apiService.dispose();
  }
}
