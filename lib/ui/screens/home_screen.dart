//lib/ui/screens/home_screen.dart
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
    loadData();
  }

  // Create new TAB CONTROLLER anytime visibility changes
  void _rebuildTabs(List<String> tabs) {
    _tabController?.dispose();
    _tabController = TabController(length: tabs.length, vsync: this);
    setState(() {});
  }

  Future<void> loadData() async {
    try {
      bool permission = await _audioQuery.permissionsStatus();
      if (!permission) permission = await _audioQuery.permissionsRequest();
      if (!permission) {
        setState(() => _loading = false);
        return;
      }

      final visibility = context.read<LibraryVisibilityController>();

      final qSongs = await _audioQuery.querySongs();
      final qArtists = await _audioQuery.queryArtists();
      final qAlbums = await _audioQuery.queryAlbums();

      // --------------------------
      // BUILD FOLDER -> SONG COUNT
      // --------------------------
      final Map<String, int> folderCounts = {};

      for (var s in qSongs) {
        final folder = s.data.substring(0, s.data.lastIndexOf("/"));
        folderCounts[folder] = (folderCounts[folder] ?? 0) + 1;
      }

      // Register counts + initialize folder toggles
      visibility.registerFolders(folderCounts);

      // Filter only enabled folders
      List<String> enabled = visibility.enabledFolders;

      if (!mounted) return;

      setState(() {
        songs = qSongs;
        artists = qArtists;
        albums = qAlbums;
        folders = enabled; // apply filtering
        _loading = false;
      });

    } catch (e) {
      debugPrint("Error loading media: $e");
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibility = context.watch<LibraryVisibilityController>();
    final activeTabs = visibility.activeTabs;

    // Ensure TabController stays in sync
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
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
