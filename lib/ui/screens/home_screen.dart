import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import '../../player/audio_player_controller.dart';
import '../widgets/header.dart';
import '../widgets/track_tile.dart';
import '../screens/folder_songs_screen.dart';

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

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    loadData();
  }

  Future<void> loadData() async {
    bool permission = await _audioQuery.permissionsStatus();
    if (!permission) permission = await _audioQuery.permissionsRequest();
    if (!permission) return;

    songs = await _audioQuery.querySongs();
    artists = await _audioQuery.queryArtists();
    albums = await _audioQuery.queryAlbums();

    // Folder extraction
    final folderSet = <String>{};
    for (var s in songs) {
      String path = s.data;
      String folder = path.substring(0, path.lastIndexOf("/"));
      folderSet.add(folder);
    }
    folders = folderSet.toList();

    if (mounted) setState(() {});
  }

 @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Header(),

          // -----------------------------------------
          // 🔥 TAB BAR (TOP)
          // -----------------------------------------
          TabBar(
            controller: tabController,
            isScrollable: true,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            indicatorColor: Colors.black,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: "Songs"),
              Tab(text: "Artists"),
              Tab(text: "Albums"),
              Tab(text: "Folders"),
            ],
          ),

          const SizedBox(height: 8),

          // -----------------------------------------
          // 🔘 LIST / GRID TOGGLE BELOW TABS
          // -----------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {
                  setState(() => isGridView = !isGridView);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isGridView ? Icons.list : Icons.grid_view,
                        size: 20,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isGridView ? "List View" : "Grid View",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // -----------------------------------------
          // TAB VIEWS
          // -----------------------------------------
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _songsTab(context),
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

  // SONGS TAB
  Widget _songsTab(BuildContext context) {
    final controller = Provider.of<AudioPlayerController>(context);

    if (songs.isEmpty) return const Center(child: CircularProgressIndicator());

    if (!isGridView) {
      // LIST VIEW
      return ListView.builder(
        itemCount: songs.length,
        itemBuilder: (_, i) {
          final s = songs[i];
          return TrackTile(
            title: s.title,
            artist: s.artist ?? "Unknown",
            songId: s.id,
            onTap: () {
              controller.setPlaylist(songs);
              controller.playSong(s);
            },
          );
        },
      );
    }

    // GRID VIEW
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: songs.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (_, i) {
        final s = songs[i];
        return GestureDetector(
          onTap: () {
            controller.setPlaylist(songs);
            controller.playSong(s);
          },
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: QueryArtworkWidget(
                  id: s.id,
                  type: ArtworkType.AUDIO,
                  artworkHeight: 120,
                  artworkWidth: 120,
                  nullArtworkWidget: Container(
                    height: 120,
                    width: 120,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.music_note, size: 40),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  // ARTISTS TAB
  Widget _artistsTab() {
    if (artists.isEmpty) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (_, i) {
        final a = artists[i];
        return ListTile(
          leading: const Icon(Icons.person),
          title: Text(a.artist),
          subtitle: Text("${a.numberOfTracks} Tracks"),
        );
      },
    );
  }

  // ALBUMS TAB
  Widget _albumsTab() {
    if (albums.isEmpty) return const Center(child: CircularProgressIndicator());

    return ListView.builder(
      itemCount: albums.length,
      itemBuilder: (_, i) {
        final a = albums[i];
        return ListTile(
          leading: const Icon(Icons.album),
          title: Text(a.album),
          subtitle: Text("${a.numOfSongs} Songs"),
        );
      },
    );
  }

  // FOLDERS TAB
  Widget _foldersTab(BuildContext context) {
    if (folders.isEmpty) return const Center(child: CircularProgressIndicator());

    if (!isGridView) {
      // LIST VIEW
      return ListView.builder(
        itemCount: folders.length,
        itemBuilder: (_, i) {
          final f = folders[i];
          return ListTile(
            leading: const Icon(Icons.folder, size: 32),
            title: Text(f.split("/").last),
            subtitle: Text(f),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FolderSongsScreen(folderPath: f),
                ),
              );
            },
          );
        },
      );
    }

    // GRID VIEW
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: folders.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (_, i) {
        final f = folders[i];
        final folderName = f.split("/").last;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FolderSongsScreen(folderPath: f),
              ),
            );
          },
          child: Column(
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.folder, size: 70, color: Colors.orange),
              ),
              const SizedBox(height: 8),
              Text(
                folderName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
