import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../player/audio_player_controller.dart';
import '../widgets/header.dart';
import '../widgets/track_tile.dart';
import '../screens/folder_songs_screen.dart';
import './../../player/favorites_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<SongModel> songs = [];
  List<ArtistModel> artists = [];
  List<AlbumModel> albums = [];
  List<String> folders = [];

  bool isGridView = false;
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
        setState(() {
          _loading = false;
        });
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
    final accent = Theme.of(context).colorScheme.primary;
    final premiumText = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[900]);

    return SafeArea(
      child: Column(
        children: [
          const Header(),
          const SizedBox(height: 6),

          // Tabs (Apple-music style subtle)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: premiumText,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 3, color: accent),
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

          const SizedBox(height: 10),

          // Grid / List toggle (Apple style pill)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => isGridView = !isGridView),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                              key: ValueKey(isGridView),
                              size: 18,
                              color: Colors.grey.shade800),
                        ),
                        const SizedBox(width: 8),
                        Text(isGridView ? "List" : "Grid", style: TextStyle(color: Colors.grey.shade800)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Optional: small info badge
                Text("${songs.length} tracks", style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Content
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: tabController,
                    children: [
                      _songsTab(context, isGridView),
                      _favoritesTab(context, isGridView),
                      _playlistsTab(),
                      _artistsTab(),
                      _albumsTab(),
                      _foldersTab(context, isGridView),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _songsTab(BuildContext context, bool grid) {
    final controller = context.read<AudioPlayerController>();

    if (songs.isEmpty) {
      return const Center(child: Text("No songs found", style: TextStyle(color: Colors.black54)));
    }

    if (!grid) {
      // List - use separated List for airy spacing
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: songs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final s = songs[i];
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: 1,
            child: TrackTile(
              title: s.title,
              artist: s.artist ?? "Unknown",
              songId: s.id,
              onTap: () => controller.setPlaylist(songs, initialIndex: i),
            ),
          );
        },
      );
    }

    // Grid view (2 columns, Apple-like card)
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: songs.length,
      itemBuilder: (context, i) {
        final s = songs[i];
        return _songGridCard(context, s, () => context.read<AudioPlayerController>().setPlaylist(songs, initialIndex: i));
      },
    );
  }

  Widget _songGridCard(BuildContext context, SongModel s, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SQUARE artwork — Apple Style
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: QueryArtworkWidget(
                id: s.id,
                type: ArtworkType.AUDIO,
                artworkHeight: 150,
                artworkWidth: double.infinity,
                nullArtworkWidget: Container(
                  height: 150,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.music_note, size: 40, color: Colors.black26),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                s.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                s.artist ?? "Unknown Artist",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _favoritesTab(BuildContext context, bool grid) {
    final fav = context.watch<FavoritesController>();
    final controller = context.read<AudioPlayerController>();

    final favSongs = songs.where((s) => fav.isFavorite(s.id)).toList();

    if (favSongs.isEmpty) {
      return const Center(child: Text("No favorites yet ❤️", style: TextStyle(color: Colors.black54)));
    }

    if (!grid) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: favSongs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final s = favSongs[i];
          return TrackTile(
            title: s.title,
            artist: s.artist ?? "Unknown",
            songId: s.id,
            onTap: () => controller.setPlaylist(favSongs, initialIndex: i),
          );
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: favSongs.length,
      itemBuilder: (context, i) {
        final s = favSongs[i];
        return _songGridCard(context, s, () => context.read<AudioPlayerController>().setPlaylist(favSongs, initialIndex: i));
      },
    );
  }

  Widget _playlistsTab() {
    // Placeholder - kept minimal for now
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.queue_music_rounded, size: 72, color: Colors.black26),
          SizedBox(height: 12),
          Text("No playlists yet", style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _artistsTab() {
    if (artists.isEmpty) return const Center(child: Text("No artists", style: TextStyle(color: Colors.black54)));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: artists.length,
      itemBuilder: (_, i) {
        final a = artists[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          leading: CircleAvatar(backgroundColor: Colors.grey.shade200, child: const Icon(Icons.person, color: Colors.black54)),
          title: Text(a.artist, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text("${a.numberOfTracks} Tracks", style: TextStyle(color: Colors.grey.shade600)),
        );
      },
    );
  }

  Widget _albumsTab() {
    if (albums.isEmpty) return const Center(child: Text("No albums", style: TextStyle(color: Colors.black54)));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: albums.length,
      itemBuilder: (_, i) {
        final a = albums[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(width: 56, height: 56, color: Colors.grey.shade100, child: const Icon(Icons.album_rounded, color: Colors.black26)),
          ),
          title: Text(a.album, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text("${a.numOfSongs} Songs", style: TextStyle(color: Colors.grey.shade600)),
        );
      },
    );
  }

  Widget _foldersTab(BuildContext context, bool grid) {
    if (folders.isEmpty) return const Center(child: Text("No folders found", style: TextStyle(color: Colors.black54)));

    if (!grid) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: folders.length,
        itemBuilder: (_, i) {
          final f = folders[i];
          final name = f.split("/").last;
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            leading: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.folder_rounded, color: Colors.orange),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(f, style: TextStyle(color: Colors.grey.shade600)),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => FolderSongsScreen(folderPath: f)));
            },
          );
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: folders.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: .92,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (_, i) {
        final f = folders[i];
        final name = f.split("/").last;
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FolderSongsScreen(folderPath: f))),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 6))
            ]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_rounded, size: 52, color: Colors.orange.shade400),
                const SizedBox(height: 10),
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );
      },
    );
  }
}
