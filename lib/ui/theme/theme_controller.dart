import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _kThemeMode = 'theme.mode';
  static const _kSeedColor = 'theme.seedColor';

  ThemeMode themeMode = ThemeMode.system;
  Color seedColor = const Color(0xFF0A84FF);

  ThemeController() {
    _load();
  }

  bool get isDark {
    if (themeMode == ThemeMode.dark) return true;
    if (themeMode == ThemeMode.light) return false;

    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    themeMode = ThemeMode.values[prefs.getInt(_kThemeMode) ?? 0];
    seedColor = Color(prefs.getInt(_kSeedColor) ?? seedColor.value);

    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeMode, themeMode.index);
    await prefs.setInt(_kSeedColor, seedColor.value);
  }

  void setThemeMode(ThemeMode mode) {
    if (themeMode == mode) return;
    themeMode = mode;
    _save();
    notifyListeners();
  }

  void setSeedColor(Color color) {
    if (seedColor.value == color.value) return;
    seedColor = color;
    _save();
    notifyListeners();
  }
}
