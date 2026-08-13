import 'package:flutter/foundation.dart';
import '../../../../data/services/token_storage.dart';

enum AuthState {
  checking,
  authenticated,
  unauthenticated,
}

class AuthViewModel extends ChangeNotifier {
  AuthState _authState = AuthState.checking;
  Map<String, dynamic>? _userInfo;
  
  AuthState get authState => _authState;
  Map<String, dynamic>? get userInfo => _userInfo;
  bool get isChecking => _authState == AuthState.checking;
  bool get isAuthenticated => _authState == AuthState.authenticated;
  bool get isUnauthenticated => _authState == AuthState.unauthenticated;
  
  Future<void> checkAuthStatus() async {
    _authState = AuthState.checking;
    notifyListeners();
    
    try {
      // Initialize TokenStorage
      await TokenStorage.init();
      
      // Check if user is authenticated
      final authenticated = await TokenStorage.isAuthenticated();
      
      if (authenticated) {
        // Get user info
        _userInfo = await TokenStorage.getUserInfo();
        _authState = AuthState.authenticated;
      } else {
        _authState = AuthState.unauthenticated;
      }
    } catch (e) {
      // If there's any error reading TokenStorage, treat as unauthenticated
      // This prevents the app from crashing on startup
      _authState = AuthState.unauthenticated;
      _userInfo = null;
    }
    
    notifyListeners();
  }
  
  Future<void> loadUserInfo() async {
    try {
      await TokenStorage.init();
      _userInfo = await TokenStorage.getUserInfo();
      notifyListeners();
    } catch (e) {
      _userInfo = null;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    try {
      await TokenStorage.clearAuth();
      _authState = AuthState.unauthenticated;
      _userInfo = null;
      notifyListeners();
    } catch (e) {
      // If logout fails, still update state
      _authState = AuthState.unauthenticated;
      _userInfo = null;
      notifyListeners();
    }
  }
}
