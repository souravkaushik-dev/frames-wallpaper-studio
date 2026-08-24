import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  bool get isSystem =>
      _themeMode == ThemeMode.system;

  void toggleTheme(bool dark) {
    _themeMode =
    dark ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}