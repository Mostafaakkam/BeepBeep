import 'package:flutter/foundation.dart';
import '../../../../data/services/token_storage.dart';
import '../../../../data/repositories/auth_repository.dart';

enum AuthState {
  checking,
  authenticated,
  unauthenticated,
}

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthState _authState = AuthState.checking;
  Map<String, dynamic>? _userInfo;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

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
        // Store Owner Dashboard: "determine the user's current role from the
        // backend, do not trust a client-supplied role" -- the cached role
        // above is only ever a starting point (needed immediately so the UI
        // isn't blocked on network), refreshed here from the DB-verified
        // GET /api/auth/me. Deliberately best-effort: a failed/offline call
        // must never block session restore or force a logout, so any error
        // here just leaves the cached role in place.
        await _refreshRoleFromBackend();
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

  Future<void> _refreshRoleFromBackend() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return;

      final currentUser = await _authRepository.getMe(token);

      final cachedName = _userInfo?['name']?.toString() ?? '';
      await TokenStorage.saveUserInfo(
        userId: currentUser.userId,
        role: currentUser.role,
        name: cachedName,
      );
      _userInfo = await TokenStorage.getUserInfo();
    } catch (e) {
      // Offline or backend error: keep whatever role was already cached
      // locally rather than failing session restore.
    }
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

  @override
  void dispose() {
    _authRepository.dispose();
    super.dispose();
  }
}
