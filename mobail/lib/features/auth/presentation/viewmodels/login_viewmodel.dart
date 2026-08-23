import 'package:flutter/foundation.dart';
import '../../../../data/models/models.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/services/token_storage.dart';
import '../../../../core/utils/validators.dart';
import '../../../../l10n/generated/app_localizations.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  // Localization (set from the View on every build; see setLocalizations).
  AppLocalizations? _l10n;

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

  /// Gives the ViewModel access to the active [AppLocalizations] instance
  /// without depending on BuildContext directly. Cheap to call repeatedly;
  /// the View calls this on every build via ListenableBuilder.
  void setLocalizations(AppLocalizations l10n) {
    _l10n = l10n;
  }

  // Setters
  void setEmail(String value) {
    _email = value;
    _emailError = _l10n != null ? Validators.validateEmail(_l10n!, value) : null;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    _passwordError = _l10n != null ? Validators.validatePassword(_l10n!, value) : null;
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
      return _l10n?.errorInvalidCredentials ?? 'Invalid email or password';
    }
    if (error.toString().contains('Validation failed')) {
      return _l10n?.errorPleaseCheckInput ?? 'Please check your input and try again';
    }
    if (error.toString().contains('Network error')) {
      return _l10n?.errorNetworkCheckConnection ?? 'Network error. Please check your connection';
    }
    return _l10n?.errorLoginFailedTryAgain ?? 'Login failed. Please try again';
  }

  @override
  void dispose() {
    _authRepository.dispose();
    super.dispose();
  }
}
