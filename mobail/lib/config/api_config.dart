class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';
  
  static const String auth = '/auth';
  static const String register = '$auth/register';
  static const String login = '$auth/login';
  static const String me = '$auth/me';
  
  static const Duration timeout = Duration(seconds: 30);
}
