import 'package:flutter/material.dart';

class AppColorSet {
  final Color primary;
  final Color secondary;
  final Color background;

  const AppColorSet({
    required this.primary,
    required this.secondary,
    required this.background,
  });
}

class ThemeController extends ChangeNotifier {
  bool isDark = false;

  final List<AppColorSet> colorSets = const [
    AppColorSet(
      primary: Color(0xFF1DB954),
      secondary: Color(0xFF191414),
      background: Color(0xFFF1FDF4),
    ),
    AppColorSet(
      primary: Color(0xFF6200EE),
      secondary: Color(0xFF3700B3),
      background: Color(0xFFF6EDFF),
    ),
    AppColorSet(
      primary: Color(0xFFFF5722),
      secondary: Color(0xFFBF360C),
      background: Color(0xFFFFECE5),
    ),
  ];

  int selectedIndex = 0;

  AppColorSet get current => colorSets[selectedIndex];

  void toggleDarkMode() {
    isDark = !isDark;
    notifyListeners();
  }

  void setColorSet(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
