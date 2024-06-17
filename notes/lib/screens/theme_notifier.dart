import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  final String key = "theme";
  late SharedPreferences _prefs; // Gunakan late
  bool _darkTheme = true;

  bool get darkTheme => _darkTheme;

  ThemeNotifier() {
    _initPrefs();
  }

  toggleTheme() {
    _darkTheme = !_darkTheme;
    _saveToPrefs();
    notifyListeners();
  }

  _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromPrefs();
  }

  _loadFromPrefs() {
    _darkTheme = _prefs.getBool(key) ?? true;
    notifyListeners();
  }

  _saveToPrefs() {
    _prefs.setBool(key, _darkTheme);
  }
}
