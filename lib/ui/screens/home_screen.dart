// lib/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../widgets/header.dart';

// tab widgets
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
    with SingleTickerProviderStateMixin {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<SongModel> songs = [];
  List<ArtistModel> artists = [];
  List<AlbumModel> albums = [];
  List<String> folders = [];

  late TabController tabController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 6, vsync: this);
    loadData();
  }

  Future<void> loadData() async {
    try {
      bool permission = await _audioQuery.permissionsStatus();
      if (!permission) permission = await _audioQuery.permissionsRequest();
      if (!permission) {
        setState(() => _loading = false);
        return;
      }

      final qSongs = await _audioQuery.querySongs();
      final qArtists = await _audioQuery.queryArtists();
      final qAlbums = await _audioQuery.queryAlbums();

      final folderSet = <String>{};
      for (var s in qSongs) {
        final p = s.data.substring(0, s.data.lastIndexOf("/"));
        folderSet.add(p);
      }

      if (mounted) {
        setState(() {
          songs = qSongs;
          artists = qArtists;
          albums = qAlbums;
          folders = folderSet.toList();
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading media: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = scheme.onSurface;
    final muted = scheme.onSurface.withValues(alpha: 0.5);

    return SafeArea(
      child: Column(
        children: [
          const Header(),
          const SizedBox(height: 6),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              labelColor: text,
              unselectedLabelColor: muted,
              labelStyle: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600, color: text),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 3, color: scheme.primary),
                insets: const EdgeInsets.symmetric(horizontal: 12),
              ),
              tabs: const [
                Tab(text: "Songs"),
                Tab(text: "Favorites"),
                Tab(text: "Playlists"),
                Tab(text: "Artists"),
                Tab(text: "Albums"),
                Tab(text: "Folders"),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _loading
              ? const Expanded(child: Center(child: CircularProgressIndicator()))
              : Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      SongsTab(songs: songs),
                      FavoritesTab(songs: songs),
                      const PlaylistsTab(),
                      ArtistsTab(artists: artists),
                      AlbumsTab(albums: albums),
                      FoldersTab(folders: folders),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
