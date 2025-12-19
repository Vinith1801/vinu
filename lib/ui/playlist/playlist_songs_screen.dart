import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:vinu/state/player/audio_player_controller.dart';
import 'package:vinu/ui/shared/song_sort_mode.dart';

import '../../state/playlist/vinu_playlist.dart';
import '../../state/favorites/favorites_controller.dart';
import '../../state/library/library_controller.dart';
import '../../state/playlist/playlist_controller.dart';
import '../shared/song_list_view.dart';
import '../shared/song_sorter.dart';
import '../shared/song_toolbar.dart';

class PlaylistSongsScreen extends StatefulWidget {
  final VinuPlaylist playlist;

  const PlaylistSongsScreen({super.key, required this.playlist});

  @override
  State<PlaylistSongsScreen> createState() => _PlaylistSongsScreenState();
}

class _PlaylistSongsScreenState extends State<PlaylistSongsScreen> {
  SongSortMode sortMode = SongSortMode.title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final playlistCtrl = context.watch<PlaylistController>();
    final audio = context.read<AudioPlayerController>();
    final fav = context.watch<FavoritesController>();
    final lib = context.read<LibraryController>();

    final playlist =
        playlistCtrl.getPlaylist(widget.playlist.id) ?? widget.playlist;

    final songs = lib.songs
        .where((s) => playlist.songIds.contains(s.id))
        .toList();

    final sorted = SongSorter.sort(songs, sortMode);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        title: Text(
          playlist.name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: sorted.isEmpty
          ? Center(
              child: Text(
                'No songs in this playlist',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            )
          : Column(
              children: [
                SongToolbar(
                  activeSort: sortMode,
                  onShuffle: () {
                    final shuffled = List<SongModel>.from(sorted)..shuffle();
                    audio.queue.setPlaylist(shuffled, index: 0);
                  },
                  onSort: (m) => setState(() => sortMode = m),
                ),

                Expanded(
                  child: SongListView(
                    songs: sorted,
                    onPlay: (index) {
                      audio.queue.setPlaylist(sorted, index: index);
                    },
                    isFavorite: fav.isFavorite,
                    onToggleFavorite: fav.toggleFavorite,
                    onAddToPlaylist: (_) {},
                    onRemoveFromPlaylist: (songId) {
                      playlistCtrl.removeSong(playlist.id, songId);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
