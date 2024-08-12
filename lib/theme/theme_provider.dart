import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  final SharedPreferences prefs;
  late ThemeMode _themeMode;

  ThemeProvider(this.prefs) {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  void _loadTheme() {
    final String? themeString = prefs.getString('theme');
    _themeMode = _parseThemeMode(themeString);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    prefs.setString('theme', mode.toString());
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String? themeString) {
    switch (themeString) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  ThemeData get lightTheme {
    return ThemeData(
      primaryColor: const Color(0xFF10B981),
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF10B981),
        secondary: Color(0xFF3B82F6),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: const Color(0xFF10B981),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF10B981),
        secondary: Color(0xFF3B82F6),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),
    );
  }
}
