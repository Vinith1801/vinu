// lib/ui/screens/home_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../player/library_visibility_controller.dart';
import '../../player/library_controller.dart';
import '../widgets/header.dart';

// tabs
import 'home/tabs/songs_tab.dart';
import 'home/tabs/favorites_tab.dart';
import 'home/tabs/playlists_tab.dart';
import 'home/tabs/artists_tab.dart';
import 'home/tabs/albums_tab.dart';
import 'home/tabs/folders_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  List<String> _cachedActiveTabs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureInitialApply());
  }

  Future<void> _ensureInitialApply() async {
    final lib = context.read<LibraryController>();
    final vis = context.read<LibraryVisibilityController>();

    await lib.waitUntilReady();

    await vis.registerFolders(Map<String, int>.from(lib.folderSongCount));

    lib.applyVisibility(
      folderScanEnabled: vis.folderScanEnabled,
      enabledFolders: vis.enabledFolders,
    );

    _cachedActiveTabs = vis.activeTabs;

    vis.addListener(_onVisibilityChanged);

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    try {
      final vis = context.read<LibraryVisibilityController>();
      vis.removeListener(_onVisibilityChanged);
    } catch (_) {}
    _tabController?.dispose();
    super.dispose();
  }

  void _onVisibilityChanged() {
    final lib = context.read<LibraryController>();
    final vis = context.read<LibraryVisibilityController>();

    lib.applyVisibility(
      folderScanEnabled: vis.folderScanEnabled,
      enabledFolders: vis.enabledFolders,
    );

    final activeTabs = vis.activeTabs;
    if (!listEquals(activeTabs, _cachedActiveTabs)) {
      _syncTabs(activeTabs);
    } else {
      if (mounted) setState(() {});
    }
  }

  void _syncTabs(List<String> tabs) {
    _tabController?.dispose();
    _tabController = TabController(length: tabs.length, vsync: this);
    _cachedActiveTabs = List<String>.from(tabs);
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vis = context.watch<LibraryVisibilityController>();
    final activeTabs = vis.activeTabs;
    if (_tabController == null || _tabController!.length != activeTabs.length) {
      _syncTabs(activeTabs);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibility = context.watch<LibraryVisibilityController>();
    final activeTabs = visibility.activeTabs;

    final lib = context.watch<LibraryController>();

    if (activeTabs.isEmpty) {
      return Center(
        child: Text(
          "All sections are hidden.\nEnable some in Settings.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final text = scheme.onSurface;
    final muted = text.withAlpha((0.5 * 255).toInt());

    return SafeArea(
      child: Column(
        children: [
          const RepaintBoundary(child: Header()),
          const SizedBox(height: 6),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TabBar(
              controller: _tabController!,
              isScrollable: true,
              labelColor: text,
              unselectedLabelColor: muted,
              labelStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 3, color: scheme.primary),
                insets: const EdgeInsets.symmetric(horizontal: 12),
              ),
              tabs: activeTabs.map((t) => Tab(text: t)).toList(),
            ),
          ),

          const SizedBox(height: 12),

          lib.loading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: RepaintBoundary(
                    child: TabBarView(
                      controller: _tabController!,
                      children: activeTabs.map((t) {
                        switch (t) {
                          case "Songs":
                            return SongsTab(songs: lib.filteredSongs);
                          case "Favorites":
                            return FavoritesTab(songs: lib.filteredSongs);
                          case "Playlists":
                            return const PlaylistsTab();
                          case "Artists":
                            return ArtistsTab(artists: lib.filteredArtists);
                          case "Albums":
                            return AlbumsTab(albums: lib.filteredAlbums);
                          case "Folders":
                            return FoldersTab(folders: lib.filteredFolders);
                          default:
                            return const SizedBox.shrink();
                        }
                      }).toList(),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
