//lib/ui/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinu/player/library_visibility_controller.dart';
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
          _VisibilityCard(),
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

////////////////////////////////////////////////////////////////////////////
/// APPEARANCE CARD
////////////////////////////////////////////////////////////////////////////
class _AppearanceCard extends StatefulWidget {
  const _AppearanceCard();

  @override
  State<_AppearanceCard> createState() => _AppearanceCardState();
}

class _AppearanceCardState extends State<_AppearanceCard> {
  String _mode = 'system';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = context.read<ThemeController>();
    _mode = theme.isDark ? 'dark' : 'light';
  }

  void _applyMode(String mode) {
    final theme = context.read<ThemeController>();
    setState(() => _mode = mode);

    if (mode == 'system') {
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
          Text('Theme mode', style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
          const SizedBox(height: 8),
          Row(
            children: [
              _RadioButton(label: 'System', selected: _mode == 'system', onTap: () => _applyMode('system')),
              const SizedBox(width: 12),
              _RadioButton(label: 'Light', selected: _mode == 'light', onTap: () => _applyMode('light')),
              const SizedBox(width: 12),
              _RadioButton(label: 'Dark', selected: _mode == 'dark', onTap: () => _applyMode('dark')),
            ],
          ),
          const SizedBox(height: 14),
          Text('Accent palettes', style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: theme.colorSets.length,
              padding: const EdgeInsets.symmetric(horizontal: 6),
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
                      color: scheme.surface,
                      border: Border.all(
                        width: selected ? 3 : 1,
                        color: selected ? set.primary : scheme.outline.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: (theme.isDark ? set.gradientDark : set.gradientLight)
                                ?? LinearGradient(colors: [set.primary, set.secondary]),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Palette ${i + 1}', style: TextStyle(fontSize: 12, color: scheme.onSurface)),
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

////////////////////////////////////////////////////////////////////////////
/// VISIBILITY CARD (tabs + per-folder scanning toggles)
////////////////////////////////////////////////////////////////////////////
class _ExpandableSection extends StatelessWidget {
  final String title;
  final String summary;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  const _ExpandableSection({
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: scheme.onSurface)),
                        const SizedBox(height: 4),
                        Text(summary,
                            style: TextStyle(
                                fontSize: 13,
                                color: scheme.onSurfaceVariant)),
                      ]),
                ),
                Icon(
                  expanded
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: scheme.onSurfaceVariant,
                )
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: child,
          crossFadeState:
              expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}


class _VisibilityCard extends StatefulWidget {
  const _VisibilityCard();

  @override
  State<_VisibilityCard> createState() => _VisibilityCardState();
}

class _VisibilityCardState extends State<_VisibilityCard> {
  bool tabsExpanded = false;
  bool foldersExpanded = false;

  String _basename(String path) =>
      path.split(RegExp(r'[\\/]+')).last;

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<LibraryVisibilityController>();
    final scheme = Theme.of(context).colorScheme;

    final showFoldersUI = ctrl.visibleTabs["Folders"] == true;

    final folderEntries = ctrl.folderMap.entries.toList()
      ..sort((a, b) {
        final aName = _basename(a.key).toLowerCase();
        final bName = _basename(b.key).toLowerCase();
        return aName.compareTo(bName);
      });

    final enabledTabs = ctrl.visibleTabs.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .join(", ");

    final folderSummary = showFoldersUI
        ? "${folderEntries.where((e) => e.value).length} folders scanned"
        : "Disabled";

    return _CardContainer(
      title: "Library Visibility",
      subtitle: "Home tabs and per-folder scanning",
      child: Column(
        children: [

          // Home Tabs Section
          _ExpandableSection(
            title: "Home Tabs",
            summary: enabledTabs.isEmpty ? "None enabled" : enabledTabs,
            expanded: tabsExpanded,
            onToggle: () => setState(() => tabsExpanded = !tabsExpanded),
            child: Column(
              children: ctrl.visibleTabs.entries.map((entry) {
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(entry.key,
                      style: TextStyle(color: scheme.onSurface)),
                  value: entry.value,
                  onChanged: (_) => ctrl.toggleTab(entry.key),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 26),

          // Folder Scanning Section
          _ExpandableSection(
            title: "Folder Scanning",
            summary: folderSummary,
            expanded: foldersExpanded,
            onToggle: () => setState(() => foldersExpanded = !foldersExpanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if (!showFoldersUI) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Folder scanning is hidden because the Folders tab is disabled.\nEnable it above to configure folder visibility.",
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                if (showFoldersUI) ...[
                  if (folderEntries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "No folders detected yet.",
                        style: TextStyle(
                            color: scheme.onSurfaceVariant, fontSize: 13),
                      ),
                    ),

                  ...folderEntries.map((entry) {
                    final path = entry.key;
                    final enabled = entry.value;
                    final pretty = _basename(path);
                    final count = ctrl.folderSongCount[path] ?? 0;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.folder, color: scheme.primary),
                      title: Text(pretty),
                      subtitle: Text("$count songs • $path",
                          style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant)),
                      trailing: Switch(
                        value: enabled,
                        onChanged: (_) => ctrl.toggleFolder(path),
                      ),
                    );
                  }),

                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: ctrl.refreshFolders,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text("Refresh folders"),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}


////////////////////////////////////////////////////////////////////////////
/// LIBRARY CARD
////////////////////////////////////////////////////////////////////////////
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
      _defaultView = p.getString(_kKeyDefaultView) ?? 'list';
      setState(() {});
    });
  }

  void _setDefault(String v) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kKeyDefaultView, v);
    setState(() => _defaultView = v);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _CardContainer(
      title: 'Library',
      subtitle: 'Default view & sorting',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Default view', style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
          const SizedBox(height: 8),
          Row(
            children: [
              _RadioButton(label: 'List', selected: _defaultView == 'list', onTap: () => _setDefault('list')),
              const SizedBox(width: 12),
              _RadioButton(label: 'Grid', selected: _defaultView == 'grid', onTap: () => _setDefault('grid')),
            ],
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////
/// ABOUT CARD
////////////////////////////////////////////////////////////////////////////
class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return _CardContainer(
      title: 'About',
      subtitle: 'App information & policies',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _ListRow(icon: Icons.info_rounded, title: 'App version', subtitle: '1.0.0', onTap: null, dense: true),
          SizedBox(height: 8),
          _ListRow(icon: Icons.shield_outlined, title: 'Privacy & permissions', subtitle: 'Review permissions and privacy', onTap: null),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////
/// SHARED WIDGETS
////////////////////////////////////////////////////////////////////////////
class _CardContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _CardContainer({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.04)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: scheme.onSurface)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

class _ListRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool dense;

  const _ListRow({required this.icon, required this.title, this.subtitle, this.onTap, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: dense ? 6 : 10, horizontal: 4),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: scheme.onSurfaceVariant)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
            if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle!, style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13))],
          ])),
          if (onTap != null) const Icon(Icons.chevron_right_rounded),
        ]),
      ),
    );
  }
}

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
        decoration: BoxDecoration(color: selected ? scheme.primary : scheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? scheme.primary : scheme.outline.withValues(alpha: 0.06))),
        child: Text(label, style: TextStyle(color: selected ? scheme.onPrimary : scheme.onSurface, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
