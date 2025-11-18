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

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 6, vsync: this);
    loadData();
  }

  Future<void> loadData() async {
    bool permission = await _audioQuery.permissionsStatus();
    if (!permission) permission = await _audioQuery.permissionsRequest();
    if (!permission) return;

    songs = await _audioQuery.querySongs();
    artists = await _audioQuery.queryArtists();
    albums = await _audioQuery.queryAlbums();

    final folderSet = <String>{};
    for (var s in songs) {
      final p = s.data.substring(0, s.data.lastIndexOf("/"));
      folderSet.add(p);
    }
    folders = folderSet.toList();

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final premiumText = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2);

    return SafeArea(
      child: Column(
        children: [
          const Header(),
          const SizedBox(height: 4),

          // PREMIUM TAB BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: premiumText,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 3, color: Colors.black.withOpacity(0.9)),
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

          const SizedBox(height: 6),

          // GRID / LIST SWITCH
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => isGridView = !isGridView),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade200.withOpacity(0.6),
                    ),
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(isGridView ? Icons.list : Icons.grid_view_rounded, key: ValueKey(isGridView), size: 20),
                        ),
                        const SizedBox(width: 6),
                        Text(isGridView ? "List" : "Grid", style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _songsTab(context),
                _favoritesTab(context),
                _playlistsTab(),
                _artistsTab(),
                _albumsTab(),
                _foldersTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _songsTab(BuildContext context) {
    // Use read so the list doesn't rebuild on player ticks
    final controller = context.read<AudioPlayerController>();

    if (songs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!isGridView) {
      return ListView.separated(
        itemCount: songs.length,
        itemBuilder: (_, i) {
          final s = songs[i];
          return TrackTile(
            title: s.title,
            artist: s.artist ?? "Unknown",
            songId: s.id,
            onTap: () {
              controller.setPlaylist(songs, initialIndex: i);
              controller.playIndex(i);
            },
          );
        },
        separatorBuilder: (_, __) => Divider(height: 1, thickness: 0.7, color: Colors.grey.shade300),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: songs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: .78, crossAxisSpacing: 14, mainAxisSpacing: 14),
      itemBuilder: (_, i) {
        final s = songs[i];
        return GestureDetector(
          onTap: () {
            controller.setPlaylist(songs, initialIndex: i);
            controller.playIndex(i);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: QueryArtworkWidget(
                    id: s.id,
                    type: ArtworkType.AUDIO,
                    artworkHeight: 150,
                    artworkWidth: double.infinity,
                    nullArtworkWidget: Container(
                      height: 150,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.music_note, size: 45),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(s.title,
                      maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _artistsTab() {
    if (artists.isEmpty) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (_, i) {
        final a = artists[i];
        return ListTile(
          leading: CircleAvatar(backgroundColor: Colors.grey.shade300, child: const Icon(Icons.person, color: Colors.black87)),
          title: Text(a.artist),
          subtitle: Text("${a.numberOfTracks} Tracks"),
        );
      },
    );
  }

  Widget _albumsTab() {
    if (albums.isEmpty) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      itemCount: albums.length,
      itemBuilder: (_, i) {
        final a = albums[i];
        return ListTile(leading: const Icon(Icons.album_rounded, size: 32), title: Text(a.album), subtitle: Text("${a.numOfSongs} Songs"));
      },
    );
  }

  Widget _foldersTab(BuildContext context) {
    if (folders.isEmpty) return const Center(child: CircularProgressIndicator());

    if (!isGridView) {
      return ListView.builder(
        itemCount: folders.length,
        itemBuilder: (_, i) {
          final f = folders[i];
          return ListTile(
            leading: const Icon(Icons.folder_rounded, color: Colors.amber, size: 32),
            title: Text(f.split("/").last),
            subtitle: Text(f),
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .80, crossAxisSpacing: 14, mainAxisSpacing: 14),
      itemBuilder: (_, i) {
        final f = folders[i];
        final name = f.split("/").last;

        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FolderSongsScreen(folderPath: f))),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: const Offset(0, 4))]),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(color: Colors.amber.shade200, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.folder_rounded, size: 60, color: Colors.orange),
                ),
                const SizedBox(height: 10),
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _favoritesTab(BuildContext context) {
    // favorites can change; use watch so tab updates when favorites change
    final fav = context.watch<FavoritesController>();
    final controller = context.read<AudioPlayerController>();
    final favSongs = songs.where((s) => fav.isFavorite(s.id)).toList();

    if (favSongs.isEmpty) {
      return const Center(child: Text("No favorites yet ❤️", style: TextStyle(fontSize: 16)));
    }

    return ListView.builder(
      itemCount: favSongs.length,
      itemBuilder: (_, i) {
        final s = favSongs[i];
        return TrackTile(
          title: s.title,
          artist: s.artist ?? "Unknown",
          songId: s.id,
          onTap: () {
            controller.setPlaylist(favSongs, initialIndex: i);
            controller.playIndex(i);
          },
        );
      },
    );
  }

  Widget _playlistsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(Icons.queue_music_rounded, size: 80), SizedBox(height: 16), Text("No playlists yet")],
      ),
    );
  }
}
