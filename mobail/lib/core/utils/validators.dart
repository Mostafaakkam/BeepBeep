import '../../l10n/generated/app_localizations.dart';

/// Form field validators. Each function takes the active [AppLocalizations]
/// instance so returned error messages are localized; callers obtain it via
/// `AppLocalizations.of(context)!` in the View and pass it through (see
/// LoginViewModel/RegisterViewModel's `setLocalizations`), keeping the
/// ViewModel layer free of any direct BuildContext dependency.
class Validators {
  static String? validateName(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.validatorNameRequired;
    }
    if (value.trim().length < 2) {
      return l10n.validatorNameTooShort;
    }
    return null;
  }

  static String? validatePhone(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.validatorPhoneRequired;
    }
    if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value.trim())) {
      return l10n.validatorPhoneInvalid;
    }
    return null;
  }

  static String? validateEmail(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.validatorEmailRequired;
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value.trim())) {
      return l10n.validatorEmailInvalid;
    }
    return null;
  }

  static String? validatePassword(AppLocalizations l10n, String? value) {
    if (value == null || value.isEmpty) {
      return l10n.validatorPasswordRequired;
    }
    if (value.length < 6) {
      return l10n.validatorPasswordTooShort;
    }
    return null;
  }

  static String? validateConfirmPassword(
    AppLocalizations l10n,
    String? value,
    String? password,
  ) {
    if (value == null || value.isEmpty) {
      return l10n.validatorConfirmPasswordRequired;
    }
    if (value != password) {
      return l10n.validatorPasswordsMismatch;
    }
    return null;
  }
}
