import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeController>(context);

    return Scaffold(
      backgroundColor: theme.isDark ? const Color(0xFF111111) : Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.isDark ? Colors.white : Colors.black,
        title: const Text("Settings", style: TextStyle(fontSize: 20)),
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [

          // ============ APPEARANCE ============
          _sectionTitle("Appearance"),
          _glassTile(
            dark: theme.isDark,
            child: SwitchListTile(
              title: const Text("Dark Mode",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              value: theme.isDark,
              onChanged: (_) => theme.toggleDarkMode(),
            ),
          ),

          const SizedBox(height: 12),

          _glassTile(
            dark: theme.isDark,
            child: ListTile(
              title: const Text("Accent Color",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(
                "Tap to change color",
                style: TextStyle(color: theme.accentColor),
              ),
              trailing: CircleAvatar(
                radius: 14,
                backgroundColor: theme.accentColor,
              ),
              onTap: () => _showColorPicker(context),
            ),
          ),

          const SizedBox(height: 28),

          // ============ PLAYBACK ============
          _sectionTitle("Playback"),
          _glassTile(
            dark: theme.isDark,
            child: Column(
              children: [
                _tile(Icons.equalizer, "Equalizer", "Coming soon"),
                _divider(theme),
                _tile(Icons.timer, "Sleep Timer", "Coming soon"),
                _divider(theme),
                _tile(Icons.speed, "Playback Speed", "Coming soon"),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ============ UI CUSTOMIZATION ============
          _sectionTitle("UI Customization"),
          _glassTile(
            dark: theme.isDark,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Show Album Artwork in Lists"),
                  value: true,
                  onChanged: (v) {},
                ),
                _divider(theme),
                SwitchListTile(
                  title: const Text("Round Artwork Thumbnails"),
                  value: true,
                  onChanged: (v) {},
                ),
                _divider(theme),
                SwitchListTile(
                  title: const Text("Enable Mini-player"),
                  value: true,
                  onChanged: (v) {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ============================================
  // SECTION TITLE
  // ============================================

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ============================================
  // PREMIUM GLASS TILE CONTAINER
  // ============================================

  Widget _glassTile({required Widget child, required bool dark}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.06),
            blurRadius: dark ? 14 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================
  // MINI TILE
  // ============================================

  Widget _tile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, size: 28),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  // ============================================
  // DIVIDER
  // ============================================

  Widget _divider(ThemeController t) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: t.isDark ? Colors.white12 : Colors.grey.shade300,
    );
  }

  // ============================================
  // ACCENT COLOR PICKER
  // ============================================

  void _showColorPicker(BuildContext context) {
    final theme = Provider.of<ThemeController>(context, listen: false);

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.amber,
      Colors.cyan,
      Colors.indigo,
    ];

    showDialog(
      context: context,
      builder: (c) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Pick Accent Color",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: theme.isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 20),

                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: colors
                      .map((color) => GestureDetector(
                            onTap: () {
                              theme.setAccentColor(color);
                              Navigator.pop(context);
                            },
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: color,
                              child: theme.accentColor == color
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          ))
                      .toList(),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
