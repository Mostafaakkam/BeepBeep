import 'package:flutter/foundation.dart';
import '../../../../data/models/models.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../core/utils/validators.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  RegisterViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();
  
  // Form state
  String _name = '';
  String _phone = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  
  // Validation state
  String? _nameError;
  String? _phoneError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  
  // UI state
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // Getters
  String get name => _name;
  String get phone => _phone;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  
  String? get nameError => _nameError;
  String? get phoneError => _phoneError;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  String? get confirmPasswordError => _confirmPasswordError;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  
  bool get isFormValid {
    return _nameError == null &&
        _phoneError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _name.isNotEmpty &&
        _phone.isNotEmpty &&
        _email.isNotEmpty &&
        _password.isNotEmpty &&
        _confirmPassword.isNotEmpty;
  }
  
  // Setters
  void setName(String value) {
    _name = value;
    _nameError = Validators.validateName(value);
    notifyListeners();
  }
  
  void setPhone(String value) {
    _phone = value;
    _phoneError = Validators.validatePhone(value);
    notifyListeners();
  }
  
  void setEmail(String value) {
    _email = value;
    _emailError = Validators.validateEmail(value);
    notifyListeners();
  }
  
  void setPassword(String value) {
    _password = value;
    _passwordError = Validators.validatePassword(value);
    if (_confirmPassword.isNotEmpty) {
      _confirmPasswordError = Validators.validateConfirmPassword(
        _confirmPassword,
        value,
      );
    }
    notifyListeners();
  }
  
  void setConfirmPassword(String value) {
    _confirmPassword = value;
    _confirmPasswordError = Validators.validateConfirmPassword(
      value,
      _password,
    );
    notifyListeners();
  }
  
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }
  
  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }
  
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
  
  Future<bool> register() async {
    if (!isFormValid || _isLoading) {
      return false;
    }
    
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
    
    try {
      final request = RegisterRequest(
        name: _name,
        phone: _phone,
        email: _email,
        password: _password,
      );
      
      final response = await _authRepository.register(request);
      
      if (response.success) {
        _successMessage = response.message;
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
    if (error.toString().contains('Email already registered')) {
      return 'Email already registered';
    }
    if (error.toString().contains('Phone number already registered')) {
      return 'Phone number already registered';
    }
    if (error.toString().contains('Validation failed')) {
      return 'Please check your input and try again';
    }
    if (error.toString().contains('Network error')) {
      return 'Network error. Please check your connection';
    }
    return 'Registration failed. Please try again';
  }
  
  @override
  void dispose() {
    _authRepository.dispose();
    super.dispose();
  }
}
