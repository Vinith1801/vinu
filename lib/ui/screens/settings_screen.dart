import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customization Settings"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Theme Color Sets",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: scheme.onSurface,
              ),
            ),
          ),

          const SizedBox(height: 12),

          _colorSetSelector(context),

          const SizedBox(height: 20),

          _section("Color & Theme Systems", [
            "Dynamic Theme Generator",
            "Gradient Builder",
            "Dark/Light Mode Variants",
            "Seasonal Themes",
            "Material You Integration",
          ], scheme),

          _section("Background Customization", [
            "Background Blur Intensity",
            "Custom Background Images",
            "Animated Backgrounds",
            "Transparency Controls",
            "Video Backgrounds",
          ], scheme),

          _section("Player Screen Customizations", [
            "Player Layout Presets",
            "Album Art Shapes",
            "Artwork Effects",
          ], scheme),

          _section("Interface Elements", [
            "Custom Navigation Bars",
            "Now Playing Widget Styles",
            "Control Button Styles",
          ], scheme),

          _section("Animations & Transitions", [
            "Page Transition Effects",
            "Loading Animations",
            "Micro-interactions",
          ], scheme),

          _section("Music Visualization", [
            "Visualizer Types",
            "Visualizer Customization",
          ], scheme),

          _section("Library View Options", [
            "Grid Size Slider",
            "View Modes",
            "Sorting Visualizers",
            "Custom Cover Grids",
          ], scheme),

          _section("Control Center & Widgets", [
            "Home Screen Widgets",
            "Always-on Display",
            "Notification Player Styles",
            "Quick Settings",
          ], scheme),

          _section("Typography & Text", [
            "Font Library",
            "Text Size Scaling",
            "Text Colors",
            "Text Effects",
          ], scheme),

          _section("Advanced Visual Features", [
            "Custom Icon Packs",
            "Cursor/Pointer Effects",
            "Screen Saver Mode",
            "AR/VR Mode",
          ], scheme),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _colorSetSelector(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 80,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: theme.colorSets.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final set = theme.colorSets[i];
          final selected = theme.selectedIndex == i;

          return GestureDetector(
            onTap: () => theme.setColorSet(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 80,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? set.primary : scheme.outline.withValues(alpha: 0.5),
                  width: selected ? 3 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _colorDot(set.primary),
                  _colorDot(set.secondary),
                  _colorDot(set.background),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _colorDot(Color c) => Container(
        width: 18,
        height: 18,
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
        ),
      );

  Widget _section(String title, List<String> items, ColorScheme scheme) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      childrenPadding: const EdgeInsets.only(left: 20, right: 16, bottom: 12),
      children: items
          .map(
            (e) => ListTile(
              title: Text(e, style: TextStyle(color: scheme.onSurface)),
              contentPadding: EdgeInsets.zero,
              trailing: Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: scheme.onSurface.withValues(alpha: 0.5)),
              onTap: () {},
            ),
          )
          .toList(),
    );
  }
}
