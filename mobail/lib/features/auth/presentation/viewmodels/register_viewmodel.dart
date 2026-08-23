import 'package:flutter/foundation.dart';
import '../../../../data/models/models.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../core/utils/validators.dart';
import '../../../../l10n/generated/app_localizations.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  RegisterViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  // Localization (set from the View on every build; see setLocalizations).
  AppLocalizations? _l10n;

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

  /// Gives the ViewModel access to the active [AppLocalizations] instance
  /// without depending on BuildContext directly. Cheap to call repeatedly;
  /// the View calls this on every build via ListenableBuilder.
  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  // Setters
  void setName(String value) {
    _name = value;
    _nameError = _l10n != null ? Validators.validateName(_l10n!, value) : null;
    notifyListeners();
  }

  void setPhone(String value) {
    _phone = value;
    _phoneError = _l10n != null ? Validators.validatePhone(_l10n!, value) : null;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    _emailError = _l10n != null ? Validators.validateEmail(_l10n!, value) : null;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    _passwordError = _l10n != null ? Validators.validatePassword(_l10n!, value) : null;
    if (_confirmPassword.isNotEmpty && _l10n != null) {
      _confirmPasswordError = Validators.validateConfirmPassword(
        _l10n!,
        _confirmPassword,
        value,
      );
    }
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    _confirmPasswordError = _l10n != null
        ? Validators.validateConfirmPassword(_l10n!, value, _password)
        : null;
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
      return _l10n?.errorEmailAlreadyRegistered ?? 'Email already registered';
    }
    if (error.toString().contains('Phone number already registered')) {
      return _l10n?.errorPhoneAlreadyRegistered ?? 'Phone number already registered';
    }
    if (error.toString().contains('Validation failed')) {
      return _l10n?.errorPleaseCheckInput ?? 'Please check your input and try again';
    }
    if (error.toString().contains('Network error')) {
      return _l10n?.errorNetworkCheckConnection ?? 'Network error. Please check your connection';
    }
    return _l10n?.errorRegistrationFailedTryAgain ?? 'Registration failed. Please try again';
  }

  @override
  void dispose() {
    _authRepository.dispose();
    super.dispose();
  }
}
