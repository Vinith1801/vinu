//lib/theme/theme_controller.dart
import 'package:flutter/material.dart';
import 'app_color_set.dart';

class ThemeController extends ChangeNotifier {
  bool isDark = false;
  int selectedIndex = 0;

  final List<AppColorSet> colorSets = const [

    // -------------------------
    // 1. Ultra Blue Premium Set
    // -------------------------
    AppColorSet(
      primary: Color(0xFF0A84FF),
      secondary: Color(0xFF003E6B),
      background: Color(0xFFE7F3FF),
      gradientLight: LinearGradient(
        colors: [Color(0xFF0A84FF), Color(0xFF003E6B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      gradientDark: LinearGradient(
        colors: [Color(0xFF002B4C), Color(0xFF001424)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),

    // -------------------------
    // 2. Gold Luxury Theme
    // -------------------------
    AppColorSet(
      primary: Color(0xFFFFC107),
      secondary: Color(0xFF7A5C00),
      background: Color(0xFFFFF8E1),
      gradientLight: LinearGradient(
        colors: [Color(0xFFFFC107), Color(0xFF7A5C00)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      gradientDark: LinearGradient(
        colors: [Color(0xFF4A3500), Color(0xFF1E1400)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),

    // -------------------------
    // 3. Aqua Premium Teal
    // -------------------------
    AppColorSet(
      primary: Color(0xFF00C2A8),
      secondary: Color(0xFF006B5C),
      background: Color(0xFFE0FFF9),
      gradientLight: LinearGradient(
        colors: [Color(0xFF00C2A8), Color(0xFF006B5C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      gradientDark: LinearGradient(
        colors: [Color(0xFF003D35), Color(0xFF001E1A)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ),

    // -------------------------
    // 4. Rose Studio Premium
    // -------------------------
    AppColorSet(
      primary: Color(0xFFEA4C89),
      secondary: Color(0xFF9B1D55),
      background: Color(0xFFFDE7F1),
      gradientLight: LinearGradient(
        colors: [Color(0xFFEA4C89), Color(0xFF9B1D55)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      gradientDark: LinearGradient(
        colors: [Color(0xFF5D1233), Color(0xFF230515)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),

    // -------------------------
    // 5. Indigo Elite
    // -------------------------
    AppColorSet(
      primary: Color(0xFF3D5AFE),
      secondary: Color(0xFF1A237E),
      background: Color(0xFFE8EAF6),
      gradientLight: LinearGradient(
        colors: [Color(0xFF3D5AFE), Color(0xFF1A237E)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      gradientDark: LinearGradient(
        colors: [Color(0xFF0C1033), Color(0xFF06071D)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),

    // -------------------------
    // 6. Emerald Calm Premium
    // -------------------------
    AppColorSet(
      primary: Color(0xFF4CAF50),
      secondary: Color(0xFF1B5E20),
      background: Color(0xFFE8F5E9),
      gradientLight: LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF1B5E20)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      gradientDark: LinearGradient(
        colors: [Color(0xFF0C2B0F), Color(0xFF041306)],
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
      ),
    ),

    // -------------------------
    // 7. Neon Fashion Theme
    // -------------------------
    AppColorSet(
      primary: Color(0xFFFF4081),
      secondary: Color(0xFFC60055),
      background: Color(0xFFFCE4EC),
      gradientLight: LinearGradient(
        colors: [Color(0xFFFF4081), Color(0xFFC60055)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      gradientDark: LinearGradient(
        colors: [Color(0xFF520020), Color(0xFF23000E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  AppColorSet get current => colorSets[selectedIndex];

  Gradient? get currentGradient =>
      isDark ? current.gradientDark : current.gradientLight;

  void toggleDarkMode() {
    isDark = !isDark;
    notifyListeners();
  }

  void setColorSet(int index) {
    selectedIndex = index;
    notifyListeners();
  }
}
