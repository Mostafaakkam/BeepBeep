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

  // Store Owner Dashboard: DB-fresh "who am I" used on session restore to
  // decide whether to show the Store Owner Dashboard entry point -- see
  // AuthViewModel.checkAuthStatus(). Backend re-verifies the role from the DB
  // on every call (authService.getCurrentUser), so this never trusts a
  // locally cached or JWT-claimed role.
  Future<CurrentUser> getMe(String token) async {
    try {
      final response = await _apiService.get(ApiConfig.me, token: token);

      if (response['success'] == true && response['data'] != null) {
        return CurrentUser.fromJson(response['data'] as Map<String, dynamic>);
      }

      throw Exception('Failed to fetch current user');
    } catch (e) {
      rethrow;
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}
