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

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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
    final muted = scheme.onSurface.withValues(alpha: 0.06);
    final surface = scheme.surface;

    return SafeArea(
      child: Column(
        children: [
          const Header(),
          const SizedBox(height: 6),

          // -----------------------------
          //       TOP TAB BAR
          // -----------------------------
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

          const SizedBox(height: 10),

          // -----------------------------
          //   LIST / GRID TOGGLE
          // -----------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => isGridView = !isGridView),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outline),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                              isGridView
                                  ? Icons.view_list_rounded
                                  : Icons.grid_view_rounded,
                              key: ValueKey(isGridView),
                              size: 18,
                              color: text),
                        ),
                        const SizedBox(width: 8),
                        Text(isGridView ? "List" : "Grid",
                            style: TextStyle(color: text)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Text("${songs.length} tracks",
                    style: TextStyle(color: muted)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: tabController,
                    children: [
                      _songsTab(context, isGridView),
                      _favoritesTab(context, isGridView),
                      _playlistsTab(context),
                      _artistsTab(context),
                      _albumsTab(context),
                      _foldersTab(context, isGridView),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  //                     SONGS TAB
  // ======================================================
  Widget _songsTab(BuildContext context, bool grid) {
    final controller = context.read<AudioPlayerController>();
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.06);

    if (songs.isEmpty) {
      return Center(
        child: Text("No songs found", style: TextStyle(color: muted)),
      );
    }

    if (!grid) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: songs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final s = songs[i];
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: 1,
            child: TrackTile(
              title: s.title,
              artist: s.artist ?? "Unknown",
              songId: s.id,
              onTap: () =>
                  controller.setPlaylist(songs, initialIndex: i),
            ),
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
      itemCount: songs.length,
      itemBuilder: (context, i) {
        final s = songs[i];
        return _songGridCard(context, s,
            () => controller.setPlaylist(songs, initialIndex: i));
      },
    );
  }

  Widget _songGridCard(
      BuildContext context, SongModel s, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;
    final text = scheme.onSurface;
    final muted = scheme.onSurface.withValues(alpha: 0.06);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(blue: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: QueryArtworkWidget(
                id: s.id,
                type: ArtworkType.AUDIO,
                artworkHeight: 150,
                artworkWidth: double.infinity,
                nullArtworkWidget: Container(
                  height: 150,
                  color: scheme.surfaceContainerHighest,
                  child: Icon(Icons.music_note,
                      size: 40, color: muted),
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
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: text),
              ),
            ),

            const SizedBox(height: 6),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                s.artist ?? "Unknown Artist",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: muted),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ======================================================
  //                 FAVORITES TAB
  // ======================================================
  Widget _favoritesTab(BuildContext context, bool grid) {
    final fav = context.watch<FavoritesController>();
    final controller = context.read<AudioPlayerController>();
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.06);

    final favSongs =
        songs.where((s) => fav.isFavorite(s.id)).toList();

    if (favSongs.isEmpty) {
      return Center(
        child: Text("No favorites yet ❤️",
            style: TextStyle(color: muted)),
      );
    }

    if (!grid) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: favSongs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final s = favSongs[i];
          return TrackTile(
            title: s.title,
            artist: s.artist ?? "Unknown",
            songId: s.id,
            onTap: () => controller.setPlaylist(favSongs,
                initialIndex: i),
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
        return _songGridCard(context, s,
            () => controller.setPlaylist(favSongs, initialIndex: i));
      },
    );
  }

  // ======================================================
  //                 PLAYLISTS
  // ======================================================
  Widget _playlistsTab(BuildContext context) {
    final muted =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.queue_music_rounded,
              size: 72, color: muted.withValues(alpha: 0.04)),
          const SizedBox(height: 12),
          Text("No playlists yet",
              style: TextStyle(color: muted)),
        ],
      ),
    );
  }

  // ======================================================
  //                 ARTISTS
  // ======================================================
  Widget _artistsTab(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.06);

    if (artists.isEmpty) {
      return Center(
        child: Text("No artists", style: TextStyle(color: muted)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: artists.length,
      itemBuilder: (_, i) {
        final a = artists[i];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          leading: CircleAvatar(
              backgroundColor: scheme.surfaceContainerHighest,
              child: Icon(Icons.person, color: muted)),
          title: Text(
            a.artist,
            style: TextStyle(
                fontWeight: FontWeight.w700, color: scheme.onSurface),
          ),
          subtitle: Text("${a.numberOfTracks} Tracks",
              style: TextStyle(color: muted)),
        );
      },
    );
  }

  // ======================================================
  //                 ALBUMS
  // ======================================================
  Widget _albumsTab(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.06);

    if (albums.isEmpty) {
      return Center(
        child: Text("No albums", style: TextStyle(color: muted)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: albums.length,
      itemBuilder: (_, i) {
        final a = albums[i];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 56,
              height: 56,
              color: scheme.surfaceContainerHighest,
              child: Icon(Icons.album_rounded, color: muted),
            ),
          ),
          title: Text(a.album,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface)),
          subtitle:
              Text("${a.numOfSongs} Songs", style: TextStyle(color: muted)),
        );
      },
    );
  }

  // ======================================================
  //                 FOLDERS
  // ======================================================
  Widget _foldersTab(BuildContext context, bool grid) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.06);

    if (folders.isEmpty) {
      return Center(
        child: Text("No folders found", style: TextStyle(color: muted)),
      );
    }

    if (!grid) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: folders.length,
        itemBuilder: (_, i) {
          final f = folders[i];
          final name = f.split("/").last;

          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            leading: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.folder_rounded, color: scheme.primary),
            ),
            title: Text(name,
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface)),
            subtitle: Text(f, style: TextStyle(color: muted)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => FolderSongsScreen(folderPath: f)),
            ),
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
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => FolderSongsScreen(folderPath: f)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 6))
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_rounded,
                    size: 52, color: scheme.primary),
                const SizedBox(height: 10),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
