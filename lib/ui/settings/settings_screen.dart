import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:vinu/state/library/library_visibility_controller.dart';
import 'package:vinu/state/settings/playback_settings_controller.dart';
import 'package:vinu/state/ui/library_layout_controller.dart';
import 'package:vinu/ui/player/styles/player_styles_screen.dart';
import 'package:vinu/ui/shared/color_picker_dialog.dart';
import '../theme/theme_controller.dart';

////////////////////////////////////////////////////////////////////////////
/// SETTINGS SCREEN
////////////////////////////////////////////////////////////////////////////
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          AppearanceCard(),
          SizedBox(height: 16),
          PlaybackCard(),
          SizedBox(height: 16),
          VisibilityCard(),
          SizedBox(height: 16),
          AboutCard(),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////
/// APPEARANCE (NOW INCLUDES LIBRARY VIEW)
////////////////////////////////////////////////////////////////////////////
class AppearanceCard extends StatelessWidget {
  const AppearanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final view = context.watch<LibraryLayoutController>();
    final scheme = Theme.of(context).colorScheme;

    return SettingsCard(
      title: 'Appearance',
      subtitle: 'Theme, colors, and layout',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Theme mode
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {theme.themeMode},
            onSelectionChanged: (v) {
              HapticFeedback.selectionClick();
              theme.setThemeMode(v.first);
            },
          ),

          const SizedBox(height: 16),

          // Accent color
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => ColorPickerDialog(
                  initialColor: theme.seedColor,
                  onSelected: theme.setSeedColor,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _ColorDot(color: theme.seedColor, size: 48),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Accent color',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '#${theme.seedColor.value.toRadixString(16).substring(2).toUpperCase()}',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Library view mode
          const Text(
            'Library layout',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),

          SegmentedButton<LibraryViewMode>(
            segments: const [
              ButtonSegment(value: LibraryViewMode.list, label: Text('List')),
              ButtonSegment(value: LibraryViewMode.grid, label: Text('Grid')),
            ],
            selected: {view.viewMode},
            onSelectionChanged: (v) {
              HapticFeedback.selectionClick();
              view.setViewMode(v.first);
            },
          ),

          if (view.viewMode == LibraryViewMode.grid) ...[
            const SizedBox(height: 12),
            Slider(
              min: 2,
              max: 4,
              divisions: 2,
              label: view.gridCount == 2
                  ? 'Comfortable'
                  : view.gridCount == 3
                      ? 'Balanced'
                      : 'Compact',
              value: view.gridCount.toDouble(),
              onChanged: (v) => view.setGridCount(v.toInt()),
            ),
          ],
          const Divider(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.palette_rounded),
            title: const Text('Player styles'),
            subtitle: const Text('Change now playing UI'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PlayerStylesScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////
/// PLAYBACK
////////////////////////////////////////////////////////////////////////////
class PlaybackCard extends StatelessWidget {
  const PlaybackCard({super.key});

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<PlaybackSettingsController>();

    return SettingsCard(
      title: 'Playback',
      subtitle: 'Background behavior',
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'Play in background',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: const Text(
          'Continue playback when the app is closed',
        ),
        value: playback.playInBackground,
        onChanged: (v) {
          HapticFeedback.selectionClick();
          context.read<PlaybackSettingsController>().set(v);
        },
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////
/// VISIBILITY
////////////////////////////////////////////////////////////////////////////
class VisibilityCard extends StatefulWidget {
  const VisibilityCard({super.key});

  @override
  State<VisibilityCard> createState() => _VisibilityCardState();
}

class _VisibilityCardState extends State<VisibilityCard> {
  bool tabsExpanded = false;
  bool foldersExpanded = false;

  String _basename(String path) => path.split(RegExp(r'[\\/]+')).last;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<LibraryVisibilityController>();
    final scheme = Theme.of(context).colorScheme;

    final showFolders = ctrl.visibleTabs['Folders'] == true;

    final folders = ctrl.folderMap.entries.toList()
      ..sort(
        (a, b) => _basename(a.key)
            .toLowerCase()
            .compareTo(_basename(b.key).toLowerCase()),
      );

    return SettingsCard(
      title: 'Library Visibility',
      subtitle: 'Tabs and folder scanning',
      child: Column(
        children: [
          _Expandable(
            title: 'Home Tabs',
            summary: ctrl.visibleTabs.entries
                    .where((e) => e.value)
                    .map((e) => e.key)
                    .join(', ')
                    .isEmpty
                ? 'None enabled'
                : ctrl.visibleTabs.entries
                    .where((e) => e.value)
                    .map((e) => e.key)
                    .join(', '),
            expanded: tabsExpanded,
            onToggle: () => setState(() => tabsExpanded = !tabsExpanded),
            child: Column(
              children: ctrl.visibleTabs.entries.map((e) {
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.key),
                  value: e.value,
                  onChanged: (_) => ctrl.toggleTab(e.key),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 24),
          _Expandable(
            title: 'Folder Scanning',
            summary:
                showFolders ? '${folders.where((f) => f.value).length} enabled' : 'Disabled',
            expanded: foldersExpanded,
            onToggle: () => setState(() => foldersExpanded = !foldersExpanded),
            child: Opacity(
              opacity: showFolders ? 1 : 0.4,
              child: IgnorePointer(
                ignoring: !showFolders,
                child: Column(
                  children: [
                    for (final entry in folders)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.folder, color: scheme.primary),
                        title: Text(_basename(entry.key)),
                        subtitle: Text(
                          '${ctrl.folderSongCount[entry.key] ?? 0} songs',
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: Switch(
                          value: entry.value,
                          onChanged: (_) => ctrl.toggleFolder(entry.key),
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: ctrl.refreshFolders,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh folders'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////
/// ABOUT
////////////////////////////////////////////////////////////////////////////
class AboutCard extends StatelessWidget {
  const AboutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      title: 'About',
      subtitle: 'App information',
      dense: true,
      child: Column(
        children: const [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.shield_outlined),
            title: Text('Privacy & permissions'),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////
/// SHARED
////////////////////////////////////////////////////////////////////////////
class SettingsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool dense;

  const SettingsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(dense ? 12 : 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outline.withOpacity(0.05)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 6),
            color: Color(0x11000000),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Expandable extends StatelessWidget {
  final String title;
  final String summary;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  const _Expandable({
    required this.title,
    required this.summary,
    required this.expanded,
    required this.onToggle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        summary,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: expanded ? child : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final double size;

  const _ColorDot({required this.color, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: const [
          BoxShadow(
            blurRadius: 6,
            offset: Offset(0, 3),
            color: Color(0x33000000),
          ),
        ],
      ),
    );
  }
}
