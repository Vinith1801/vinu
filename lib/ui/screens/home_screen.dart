// lib/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../player/library_visibility_controller.dart';
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
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<SongModel> songs = [];
  List<ArtistModel> artists = [];
  List<AlbumModel> albums = [];
  List<String> folders = [];

  TabController? _tabController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    // Live refresh when folder toggles or tab visibility changes
    final visibility = context.read<LibraryVisibilityController>();
    visibility.onFolderSettingsChanged = () {
      if (mounted) loadData();
    };

    loadData();
  }

  @override
  void dispose() {
    try {
      final visibility = context.read<LibraryVisibilityController>();
      visibility.onFolderSettingsChanged = null;
    } catch (_) {}

    _tabController?.dispose();
    super.dispose();
  }

  // Build a new TabController when tabs change
  void _rebuildTabs(List<String> tabs) {
    _tabController?.dispose();
    _tabController = TabController(length: tabs.length, vsync: this);
    setState(() {});
  }

  // Safe, cross-platform folder extractor
  String _folderFromPath(String path) {
    final normalized = path.replaceAll("\\", "/");
    final idx = normalized.lastIndexOf("/");
    if (idx <= 0) return "";
    return normalized.substring(0, idx);
  }

  Future<void> loadData() async {
    try {
      bool permission = await _audioQuery.permissionsStatus();
      if (!permission) permission = await _audioQuery.permissionsRequest();
      if (!permission) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final visibility = context.read<LibraryVisibilityController>();

      final qSongs = await _audioQuery.querySongs();
      final qArtists = await _audioQuery.queryArtists();
      final qAlbums = await _audioQuery.queryAlbums();

      // --------------------------------------------------------------
      // CLEANED: Build folder → song count with safe path extraction
      // --------------------------------------------------------------
      final Map<String, int> folderCounts = {};
      for (var s in qSongs) {
        final folder = _folderFromPath(s.data);
        if (folder.isEmpty) continue;

        folderCounts[folder] = (folderCounts[folder] ?? 0) + 1;
      }

      // Controller stores toggles & persists new folders
      await visibility.registerFolders(folderCounts);

      // --------------------------------------------------------------
      // CLEANED: Filter songs by enabled folders
      // --------------------------------------------------------------
      List<SongModel> filteredSongs = qSongs;

      if (visibility.folderScanEnabled && visibility.enabledFolders.isNotEmpty) {
        final enabled = Set<String>.from(visibility.enabledFolders);

        filteredSongs = qSongs.where((s) {
          final folder = _folderFromPath(s.data);
          return enabled.contains(folder);
        }).toList();
      }

      final enabledFolders = visibility.enabledFolders;

      if (!mounted) return;

      setState(() {
        songs = filteredSongs;
        artists = qArtists;
        albums = qAlbums;
        folders = enabledFolders;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint("Error loading media: $e\n$st");
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibility = context.watch<LibraryVisibilityController>();
    final activeTabs = visibility.activeTabs;

    // Sync TabController
    if (_tabController == null || _tabController!.length != activeTabs.length) {
      _rebuildTabs(activeTabs);
    }

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
    final muted = text.withValues(alpha: 0.5);

    return SafeArea(
      child: Column(
        children: [
          const Header(),
          const SizedBox(height: 6),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TabBar(
              controller: _tabController!,
              isScrollable: true,
              labelColor: text,
              unselectedLabelColor: muted,
              labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 3, color: scheme.primary),
                insets: const EdgeInsets.symmetric(horizontal: 12),
              ),
              tabs: activeTabs.map((t) => Tab(text: t)).toList(),
            ),
          ),

          const SizedBox(height: 12),

          _loading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: TabBarView(
                    controller: _tabController!,
                    children: activeTabs.map((t) {
                      switch (t) {
                        case "Songs":
                          return SongsTab(songs: songs);

                        case "Favorites":
                          return FavoritesTab(songs: songs);

                        case "Playlists":
                          return const PlaylistsTab();

                        case "Artists":
                          return ArtistsTab(artists: artists);

                        case "Albums":
                          return AlbumsTab(albums: albums);

                        case "Folders":
                          return FoldersTab(folders: folders);

                        default:
                          return const SizedBox.shrink();
                      }
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }
}
