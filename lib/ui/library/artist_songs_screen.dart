import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:vinu/ui/playlist/add_to_playlist_sheet.dart';

import '../../player/audio_player_controller.dart';
import '../../player/favorites_controller.dart';
import '../../player/library_controller.dart';
import '../shared/song_list_view.dart';

class ArtistSongsScreen extends StatelessWidget {
  final ArtistModel artist;

  const ArtistSongsScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final lib = context.watch<LibraryController>();
    final audio = context.read<AudioPlayerController>();
    final fav = context.watch<FavoritesController>();

    final songs = lib.getSongsByArtist(artist.artist);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        title: Text(
          artist.artist,
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

                // Artist avatar
                CircleAvatar(
                  radius: 48,
                  backgroundColor: scheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.person,
                    size: 46,
                    color: scheme.onSurfaceVariant,
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
