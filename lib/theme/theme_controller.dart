import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  bool isDark = false;
  Color accentColor = Colors.blue;

  void toggleDarkMode() {
    isDark = !isDark;
    notifyListeners();
  }

  void setAccentColor(Color color) {
    accentColor = color;
    notifyListeners();
  }
}
