import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's active [Locale] and persists the user's language
/// choice across restarts via [SharedPreferences].
///
/// English is the default language: if no preference has been saved yet
/// (first launch, or SharedPreferences unavailable), the app stays on
/// English regardless of the device's system locale.
class LocaleProvider extends ChangeNotifier {
  static const String _prefsKey = 'app_locale';
  static const Locale defaultLocale = Locale('en');

  Locale _locale = defaultLocale;
  bool _isLoaded = false;

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isLoaded => _isLoaded;

  /// Loads the previously saved language preference, if any. Should be
  /// called once during app startup, before the first frame if possible.
  Future<void> loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefsKey);
      if (savedCode == 'ar') {
        _locale = const Locale('ar');
      } else if (savedCode == 'en') {
        _locale = const Locale('en');
      }
      // No saved preference (or an unrecognized value) -> keep English default.
    } catch (e) {
      // If SharedPreferences is unavailable for any reason, fall back to
      // the English default rather than crashing app startup.
      _locale = defaultLocale;
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Switches the active language and persists the choice.
  Future<void> setLocale(Locale newLocale) async {
    if (_locale.languageCode == newLocale.languageCode) return;

    _locale = newLocale;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, newLocale.languageCode);
    } catch (e) {
      // Persistence failure shouldn't block switching the language for the
      // current session; the choice just won't survive a restart.
    }
  }
}

/// App-wide singleton, matching this codebase's existing convention of a
/// global ChangeNotifier instance (see e.g. no DI/Provider framework is
/// used elsewhere in the app).
final LocaleProvider localeProvider = LocaleProvider();
