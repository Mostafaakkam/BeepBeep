import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';
  static const String _userNameKey = 'user_name';
  
  static SharedPreferences? _preferences;
  
  static Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }
  
  static Future<void> saveToken(String token) async {
    await init();
    await _preferences!.setString(_tokenKey, token);
  }
  
  static Future<String?> getToken() async {
    await init();
    return _preferences!.getString(_tokenKey);
  }
  
  static Future<void> saveUserInfo({
    required int userId,
    required String role,
    required String name,
  }) async {
    await init();
    await _preferences!.setInt(_userIdKey, userId);
    await _preferences!.setString(_userRoleKey, role);
    await _preferences!.setString(_userNameKey, name);
  }
  
  static Future<Map<String, dynamic>?> getUserInfo() async {
    await init();
    final userId = _preferences!.getInt(_userIdKey);
    final role = _preferences!.getString(_userRoleKey);
    final name = _preferences!.getString(_userNameKey);
    
    if (userId != null && role != null && name != null) {
      return {
        'userId': userId,
        'role': role,
        'name': name,
      };
    }
    
    return null;
  }
  
  static Future<void> clearAuth() async {
    await init();
    await _preferences!.remove(_tokenKey);
    await _preferences!.remove(_userIdKey);
    await _preferences!.remove(_userRoleKey);
    await _preferences!.remove(_userNameKey);
  }
  
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
