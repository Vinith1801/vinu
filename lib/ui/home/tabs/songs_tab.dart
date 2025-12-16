import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:vinu/ui/shared/song_sort_mode.dart';

import '../../../player/audio_player_controller.dart';
import '../../../player/favorites_controller.dart';
import '../../playlist/add_to_playlist_sheet.dart';
import '../../shared/song_list_view.dart';
import '../../shared/song_sorter.dart';
import '../../shared/song_toolbar.dart';

class SongsTab extends StatefulWidget {
  final List<SongModel> songs;

  const SongsTab({super.key, required this.songs});

  @override
  State<SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends State<SongsTab> {
  SongSortMode sortMode = SongSortMode.title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final audio = context.read<AudioPlayerController>();
    final fav = context.watch<FavoritesController>();

    if (widget.songs.isEmpty) {
      return Center(
        child: Text(
          'No songs found',
          style: TextStyle(
            color: scheme.onSurface.withValues(alpha: 0.5),
            fontSize: 15,
          ),
        ),
      );
    }

    final sortedSongs = SongSorter.sort(widget.songs, sortMode);

    return Column(
      children: [
        SongToolbar(
          activeSort: sortMode,
          onShuffle: () {
            final shuffled = List<SongModel>.from(sortedSongs)..shuffle();
            audio.setPlaylist(shuffled, initialIndex: 0);
          },
          onSort: (mode) => setState(() => sortMode = mode),
        ),

        Expanded(
          child: SongListView(
            songs: sortedSongs,
            onPlay: (index) {
              audio.setPlaylist(sortedSongs, initialIndex: index);
            },
            isFavorite: fav.isFavorite,
            onToggleFavorite: fav.toggleFavorite,
            onAddToPlaylist: (songId) {
              AddToPlaylistSheet.show(context, songId);
            },
          ),
        ),
      ],
    );
  }
}
