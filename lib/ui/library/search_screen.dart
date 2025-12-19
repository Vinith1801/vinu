import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:vinu/state/favorites/favorites_controller.dart';
import 'package:vinu/ui/playlist/add_to_playlist_sheet.dart';
import '../../state/library/library_controller.dart';
import 'package:vinu/state/player/audio_player_controller.dart';
import '../shared/track_tile.dart';
import 'album_songs_screen.dart';
import 'artist_songs_screen.dart';
import 'folder_songs_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = "";
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final lib = context.watch<LibraryController>();
    final audio = context.read<AudioPlayerController>();
    final fav = context.watch<FavoritesController>();
    final scheme = Theme.of(context).colorScheme;

    // Normalize query
    final q = query.trim().toLowerCase();

    // 1. SONGS
    final filteredSongs = q.isEmpty
        ? const <SongModel>[]
        : lib.songs.where((s) {
            return s.title.toLowerCase().contains(q) ||
                (s.artist ?? "").toLowerCase().contains(q);
          }).toList();

    // 2. ALBUMS
    final filteredAlbums = q.isEmpty
        ? const <AlbumModel>[]
        : lib.albums.where((a) {
            return a.album.toLowerCase().contains(q);
          }).toList();

    // 3. ARTISTS
    final filteredArtists = q.isEmpty
        ? const <ArtistModel>[]
        : lib.artists.where((a) {
            return a.artist.toLowerCase().contains(q);
          }).toList();

    // 4. FOLDERS
    final filteredFolders = q.isEmpty
        ? const <String>[]
        : lib.folders.where((f) {
            final name = f.split("/").last.toLowerCase();
            return name.contains(q);
          }).toList();

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: scheme.surface,
        leading: BackButton(color: scheme.onSurface),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: TextStyle(color: scheme.onSurface),
          decoration: InputDecoration(
            hintText: "Search songs, albums, artists...",
            hintStyle: TextStyle(color: scheme.onSurfaceVariant),
            border: InputBorder.none,
          ),
          onChanged: (t) {
            setState(() {
              query = t;
            });
          },
        ),
      ),

      body: q.isEmpty
          ? Center(
              child: Text(
                "Type to search",
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // SONG RESULTS
                if (filteredSongs.isNotEmpty) ...[
                  _header("Songs", scheme),
                  ...filteredSongs.map((s) => TrackTile(
                    title: s.title,
                    artist: s.artist ?? "Unknown Artist",
                    songId: s.id,
                    isFavorite: fav.isFavorite(s.id),
                    onTap: () => audio.queue.setPlaylist(
                      filteredSongs,
                      index: filteredSongs.indexOf(s),
                    ),
                    onToggleFavorite: () => fav.toggleFavorite(s.id),
                    onAddToPlaylist: () => AddToPlaylistSheet.show(context, s.id),
                  )),
                  const SizedBox(height: 22),
                ],

                // ALBUM RESULTS
                if (filteredAlbums.isNotEmpty) ...[
                  _header("Albums", scheme),
                  ...filteredAlbums.map(
                    (a) => ListTile(
                      leading: QueryArtworkWidget(
                        id: a.id,
                        type: ArtworkType.ALBUM,
                        artworkHeight: 55,
                        artworkWidth: 55,
                        nullArtworkWidget: Container(
                          width: 55,
                          height: 55,
                          color: scheme.surfaceContainerHighest,
                          child: Icon(Icons.album, color: scheme.onSurfaceVariant),
                        ),
                      ),
                      title: Text(a.album, style: TextStyle(color: scheme.onSurface)),
                      subtitle: Text("${a.numOfSongs} songs", style: TextStyle(color: scheme.onSurfaceVariant)),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AlbumSongsScreen(album: a)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                ],

                // ARTIST RESULTS
                if (filteredArtists.isNotEmpty) ...[
                  _header("Artists", scheme),
                  ...filteredArtists.map(
                    (a) => ListTile(
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: scheme.surfaceContainerHighest,
                        child: Icon(Icons.person, color: scheme.onSurfaceVariant),
                      ),
                      title: Text(a.artist, style: TextStyle(color: scheme.onSurface)),
                      subtitle: Text("${a.numberOfTracks} tracks", style: TextStyle(color: scheme.onSurfaceVariant)),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ArtistSongsScreen(artist: a)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                ],

                // FOLDER RESULTS
                if (filteredFolders.isNotEmpty) ...[
                  _header("Folders", scheme),
                  ...filteredFolders.map(
                    (f) {
                      final name = f.split("/").last;
                      final count = lib.getSongsByFolder(f).length;
                      return ListTile(
                        leading: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.folder_rounded, color: scheme.primary),
                        ),
                        title: Text(name, style: TextStyle(color: scheme.onSurface)),
                        subtitle: Text("$count songs", style: TextStyle(color: scheme.onSurfaceVariant)),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => FolderSongsScreen(folderPath: f)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                ],

                if (filteredSongs.isEmpty &&
                    filteredAlbums.isEmpty &&
                    filteredArtists.isEmpty &&
                    filteredFolders.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text("No results found", style: TextStyle(color: scheme.onSurfaceVariant)),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _header(String title, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: scheme.primary,
        ),
      ),
    );
  }
}
