import 'package:flutter/material.dart';
import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          // --------------------
          // App Title
          // --------------------
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Vinu",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),

          const Spacer(),

          // --------------------
          // Search Button
          // --------------------
          _roundedButton(
            context,
            icon: Icons.search_rounded,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 220),
                  pageBuilder: (_, _, _) => const SearchScreen(),
                  transitionsBuilder: (_, anim, _, child) =>
                      FadeTransition(opacity: anim, child: child),
                ),
              );
            },
          ),

          const SizedBox(width: 12),

          // --------------------
          // Settings Button
          // --------------------
          _roundedButton(
            context,
            icon: Icons.settings_rounded,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 220),
                  pageBuilder: (_, _, _) => const SettingsScreen(),
                  transitionsBuilder: (_, anim, _, child) =>
                      FadeTransition(opacity: anim, child: child),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------
  // Reusable Rounded Button
  // --------------------------------------------------------
  Widget _roundedButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(
            alpha: scheme.brightness == Brightness.dark ? 0.2 : 0.7,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            if (scheme.brightness == Brightness.light)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Icon(
          icon,
          size: 24,
          color: scheme.onSurface,
        ),
      ),
    );
  }
}
