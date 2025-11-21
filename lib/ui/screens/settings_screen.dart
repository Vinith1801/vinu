// lib/ui/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        title: Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface),
        ),
      ),
      backgroundColor: scheme.surface,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        children: const [
          SizedBox(height: 6),
          _AppearanceCard(),
          SizedBox(height: 12),
          _PlayerCard(),
          SizedBox(height: 12),
          _LibraryCard(),
          SizedBox(height: 12),
          _AboutCard(),
          SizedBox(height: 28),
        ],
      ),
    );
  }
}

/// Appearance Card: theme mode + color set selector.
/// Uses ThemeController (provider) to change color set and dark mode.
class _AppearanceCard extends StatefulWidget {
  const _AppearanceCard();

  @override
  State<_AppearanceCard> createState() => _AppearanceCardState();
}

class _AppearanceCardState extends State<_AppearanceCard> {
  String _mode = 'system'; // 'system'|'light'|'dark'

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = context.read<ThemeController>();
    // best-effort: map theme.isDark to local mode (no system info in controller)
    _mode = theme.isDark ? 'dark' : 'light';
  }

  void _applyMode(String mode) {
    final theme = context.read<ThemeController>();
    setState(() => _mode = mode);

    if (mode == 'system') {
      // If you later add system integration, replace this with actual behavior.
      // For now, keep "system" as toggling to light by default to avoid surprises.
      if (theme.isDark) theme.toggleDarkMode();
    } else if (mode == 'dark') {
      if (!theme.isDark) theme.toggleDarkMode();
    } else {
      if (theme.isDark) theme.toggleDarkMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final scheme = Theme.of(context).colorScheme;

    return _CardContainer(
      title: 'Appearance',
      subtitle: 'Theme, accent and look & feel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme Mode radios
          Text('Theme mode', style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
          const SizedBox(height: 8),
          Row(
            children: [
              _RadioButton(
                label: 'System',
                selected: _mode == 'system',
                onTap: () => _applyMode('system'),
              ),
              const SizedBox(width: 12),
              _RadioButton(
                label: 'Light',
                selected: _mode == 'light',
                onTap: () => _applyMode('light'),
              ),
              const SizedBox(width: 12),
              _RadioButton(
                label: 'Dark',
                selected: _mode == 'dark',
                onTap: () => _applyMode('dark'),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Color set selector (uses ThemeController)
          Text('Accent palettes', style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: theme.colorSets.length,
              padding: const EdgeInsets.only(left: 6, right: 6),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final set = theme.colorSets[i];
                final selected = theme.selectedIndex == i;
                return GestureDetector(
                  onTap: () => theme.setColorSet(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 86,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        width: selected ? 3 : 1,
                        color: selected ? set.primary : Theme.of(context).colorScheme.outline.withOpacity(0.06),
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: set.primary.withOpacity(0.16),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Gradient preview circle (nicer than stacked dots)
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: (theme.isDark ? set.gradientDark : set.gradientLight) ??
                                LinearGradient(colors: [set.primary, set.secondary]),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Palette ${i + 1}',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Player Card: opens Player Settings page (persisted toggles).
class _PlayerCard extends StatelessWidget {
  const _PlayerCard();

  @override
  Widget build(BuildContext context) {
    // final scheme = Theme.of(context).colorScheme;
    return _CardContainer(
      title: 'Player',
      subtitle: 'Playback UI & micro-behaviors',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ListRow(
            icon: Icons.music_note,
            title: 'Player Settings',
            subtitle: 'Animation & controls',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const _PlayerSettingsScreen()),
            ),
          ),
          const SizedBox(height: 6),
          _ListRow(
            icon: Icons.info_outline,
            title: 'Playback quality',
            subtitle: 'Bitrate / resampling (if supported)',
            onTap: () => _showNotImplemented(context),
          ),
        ],
      ),
    );
  }

  void _showNotImplemented(BuildContext c) {
    ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content: Text('Not implemented yet')));
  }
}

/// Library Card: local preference for default list/grid view (persisted)
class _LibraryCard extends StatefulWidget {
  const _LibraryCard();

  @override
  State<_LibraryCard> createState() => _LibraryCardState();
}

class _LibraryCardState extends State<_LibraryCard> {
  static const _kKeyDefaultView = 'settings.library.defaultView';
  String _defaultView = 'list';

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      final v = p.getString(_kKeyDefaultView) ?? 'list';
      setState(() => _defaultView = v);
    });
  }

  void _setDefault(String v) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kKeyDefaultView, v);
    setState(() => _defaultView = v);
  }

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      title: 'Library',
      subtitle: 'Default view & sorting',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Default view', style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
          Row(
            children: [
              _RadioButton(label: 'List', selected: _defaultView == 'list', onTap: () => _setDefault('list')),
              const SizedBox(width: 12),
              _RadioButton(label: 'Grid', selected: _defaultView == 'grid', onTap: () => _setDefault('grid')),
            ],
          ),
          const SizedBox(height: 12),
          _ListRow(
            icon: Icons.sort_rounded,
            title: 'Sort order',
            subtitle: 'Tap to choose... (coming soon)',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not implemented'))),
          ),
        ],
      ),
    );
  }
}

/// Small About / version card
class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    // final scheme = Theme.of(context).colorScheme;
    return _CardContainer(
      title: 'About',
      subtitle: 'App information & policies',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ListRow(
            icon: Icons.info_rounded,
            title: 'App version',
            subtitle: '1.0.0',
            onTap: () {},
            dense: true,
          ),
          const SizedBox(height: 8),
          _ListRow(
            icon: Icons.shield_outlined,
            title: 'Privacy & permissions',
            subtitle: 'Review permissions and privacy',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// Generic card container to match your app's visual style
class _CardContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _CardContainer({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: scheme.onSurface)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Small tappable row used inside cards
class _ListRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool dense;

  const _ListRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: dense ? 6 : 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
                ],
              ]),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// Custom radio-like button
class _RadioButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? scheme.primary : scheme.outline.withOpacity(0.06)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? scheme.onPrimary : scheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Player settings page (persisted with SharedPreferences)
class _PlayerSettingsScreen extends StatefulWidget {
  const _PlayerSettingsScreen();

  @override
  State<_PlayerSettingsScreen> createState() => _PlayerSettingsScreenState();
}

class _PlayerSettingsScreenState extends State<_PlayerSettingsScreen> {
  static const _kVinyl = 'player.vinyl.enabled';
  static const _kTonearm = 'player.tonearm.enabled';
  static const _kMiniExpand = 'player.mini.expandOnTap';

  bool _vinyl = true;
  bool _tonearm = true;
  bool _miniExpandOnTap = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _vinyl = p.getBool(_kVinyl) ?? true;
      _tonearm = p.getBool(_kTonearm) ?? true;
      _miniExpandOnTap = p.getBool(_kMiniExpand) ?? true;
    });
  }

  Future<void> _setBool(String key, bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('Player Settings', style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w700)), backgroundColor: scheme.surface),
      backgroundColor: scheme.surface,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CardContainer(
            title: 'Playback visuals',
            subtitle: 'Vinyl, tonearm and mini-player behavior',
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Vinyl animation'),
                  subtitle: const Text('Show rotating vinyl in the full player'),
                  value: _vinyl,
                  onChanged: (v) {
                    _setBool(_kVinyl, v);
                    setState(() => _vinyl = v);
                    // Optionally: notify AudioPlayerController if you add support
                  },
                ),
                const SizedBox(height: 6),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Tonearm animation'),
                  subtitle: const Text('Animate tonearm when playing/paused'),
                  value: _tonearm,
                  onChanged: (v) {
                    _setBool(_kTonearm, v);
                    setState(() => _tonearm = v);
                  },
                ),
                const SizedBox(height: 6),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Expand mini-player on tap'),
                  subtitle: const Text('Tap the mini player to open full view'),
                  value: _miniExpandOnTap,
                  onChanged: (v) {
                    _setBool(_kMiniExpand, v);
                    setState(() => _miniExpandOnTap = v);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
