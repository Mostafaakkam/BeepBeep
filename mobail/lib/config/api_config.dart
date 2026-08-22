class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';
  
  static const String auth = '/auth';
  static const String register = '$auth/register';
  static const String login = '$auth/login';
  static const String me = '$auth/me';
  
  static const String stores = '/stores';
  static const String products = '/products';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String addresses = '/addresses';
  static const String categories = '/categories';
  
  static const Duration timeout = Duration(seconds: 30);
}
