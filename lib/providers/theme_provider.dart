import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode themeMode = ThemeMode.light;

  ThemeProvider() {
    loadTheme();
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme == 'dark') {
      themeMode = ThemeMode.dark;
    } else if (savedTheme == 'system') {
      themeMode = ThemeMode.system;
    } else {
      themeMode = ThemeMode.light;
    }

    notifyListeners();
  }

  Future<void> setLightMode() async {
    themeMode = ThemeMode.light;
    await _saveTheme('light');
    notifyListeners();
  }

  Future<void> setDarkMode() async {
    themeMode = ThemeMode.dark;
    await _saveTheme('dark');
    notifyListeners();
  }

  Future<void> setSystemMode() async {
    themeMode = ThemeMode.system;
    await _saveTheme('system');
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (themeMode == ThemeMode.dark) {
      await setLightMode();
    } else {
      await setDarkMode();
    }
  }

  Future<void> _saveTheme(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, value);
  }
}
