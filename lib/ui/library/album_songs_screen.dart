import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:vinu/ui/playlist/add_to_playlist_sheet.dart';

import '../../player/audio_player_controller.dart';
import '../../player/favorites_controller.dart';
import '../../player/library_controller.dart';
import '../shared/song_list_view.dart';

class AlbumSongsScreen extends StatelessWidget {
  final AlbumModel album;

  const AlbumSongsScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final lib = context.watch<LibraryController>();
    final audio = context.read<AudioPlayerController>();
    final fav = context.watch<FavoritesController>();

    final songs = lib.getSongsByAlbum(album.id);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        title: Text(
          album.album,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: songs.isEmpty
          ? Center(
              child: Text(
                'No songs found',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 16),

                // Album artwork
                QueryArtworkWidget(
                  id: album.id,
                  type: ArtworkType.ALBUM,
                  artworkHeight: 160,
                  artworkWidth: 160,
                  nullArtworkWidget: Container(
                    height: 160,
                    width: 160,
                    color: scheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.album,
                      size: 48,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  '${songs.length} songs',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: SongListView(
                    songs: songs,
                    onPlay: (index) {
                      audio.setPlaylist(songs, initialIndex: index);
                    },
                    isFavorite: fav.isFavorite,
                    onToggleFavorite: fav.toggleFavorite,
                    onAddToPlaylist: (songId) {
                      AddToPlaylistSheet.show(context, songId);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
