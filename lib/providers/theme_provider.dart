import 'package:flutter/material.dart';
import '../services/settings_service.dart';

/// ڈارک/لائٹ موڈ کی حالت کا انتظام
class ThemeProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _isDarkMode = await _settingsService.getDarkMode();
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    await _settingsService.setDarkMode(value);
    notifyListeners();
  }
}
