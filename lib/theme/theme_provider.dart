// lib/theme/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A provider class for managing the application's theme.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Initializes the theme provider by loading the saved theme preference.
  ThemeProvider() {
    _loadTheme();
  }

  /// Loads the theme preference from shared preferences.
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Reads the saved theme preference; defaults to system if none is found.
    final theme = prefs.getString('themeMode');
    if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (theme == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  /// Sets the theme mode and saves the preference.
  void setTheme(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;

    _themeMode = themeMode;
    final prefs = await SharedPreferences.getInstance();
    if (themeMode == ThemeMode.system) {
      await prefs.remove('themeMode');
    } else {
      await prefs.setString('themeMode', themeMode == ThemeMode.dark ? 'dark' : 'light');
    }
    notifyListeners();
  }
}
