import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService with ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _manualNextOnCorrectKey = 'manual_next_on_correct';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  ThemeMode get themeMode {
    final mode = _prefs.getString(_themeModeKey);
    if (mode == 'dark') return ThemeMode.dark;
    if (mode == 'light') return ThemeMode.light;
    return ThemeMode.light; // Default to light instead of system
  }

  bool get manualNextOnCorrect {
    return _prefs.getBool(_manualNextOnCorrectKey) ?? true; // Default is true (new behavior)
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.name);
    notifyListeners();
  }

  Future<void> setManualNextOnCorrect(bool value) async {
    await _prefs.setBool(_manualNextOnCorrectKey, value);
    notifyListeners();
  }
}
