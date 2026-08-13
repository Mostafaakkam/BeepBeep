import 'package:flutter/foundation.dart';
import '../../../../data/services/token_storage.dart';

class HomeViewModel extends ChangeNotifier {
  String _userName = '';
  bool _isLoading = false;
  String? _errorMessage;
  
  String get userName => _userName;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadUserData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await TokenStorage.init();
      final userInfo = await TokenStorage.getUserInfo();
      
      if (userInfo != null) {
        _userName = userInfo['name']?.toString() ?? 'User';
      } else {
        _userName = 'User';
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load user data';
      _isLoading = false;
      _userName = 'User';
      notifyListeners();
    }
  }
}
