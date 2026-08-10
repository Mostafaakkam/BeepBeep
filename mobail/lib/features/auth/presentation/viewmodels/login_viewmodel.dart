import 'package:flutter/foundation.dart';
import '../../../../data/models/models.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/token_storage.dart';
import '../../../../core/utils/validators.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  LoginViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();
  
  // Form state
  String _email = '';
  String _password = '';
  
  // Validation state
  String? _emailError;
  String? _passwordError;
  
  // UI state
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  
  // Getters
  String get email => _email;
  String get password => _password;
  
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  
  bool get isFormValid {
    return _emailError == null &&
        _passwordError == null &&
        _email.isNotEmpty &&
        _password.isNotEmpty;
  }
  
  // Setters
  void setEmail(String value) {
    _email = value;
    _emailError = Validators.validateEmail(value);
    notifyListeners();
  }
  
  void setPassword(String value) {
    _password = value;
    _passwordError = Validators.validatePassword(value);
    notifyListeners();
  }
  
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }
  
  void clearMessages() {
    _errorMessage = null;
    notifyListeners();
  }
  
  Future<bool> login() async {
    if (!isFormValid || _isLoading) {
      return false;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final request = LoginRequest(
        email: _email,
        password: _password,
      );
      
      final response = await _authRepository.login(request);
      
      if (response.success && response.data != null) {
        final data = response.data!;
        // Store token and user info
        await TokenStorage.saveToken(data.token);
        await TokenStorage.saveUserInfo(
          userId: data.user.id,
          role: data.user.role,
          name: data.user.name,
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('Invalid credentials')) {
      return 'Invalid email or password';
    }
    if (error.toString().contains('Validation failed')) {
      return 'Please check your input and try again';
    }
    if (error.toString().contains('Network error')) {
      return 'Network error. Please check your connection';
    }
    return 'Login failed. Please try again';
  }
  
  @override
  void dispose() {
    _authRepository.dispose();
    super.dispose();
  }
}
