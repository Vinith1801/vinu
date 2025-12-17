import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:vinu/ui/player/library_view_controller.dart';
import 'package:vinu/ui/shared/song_grid_tile.dart';
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
  final audio = context.read<AudioPlayerController>();
  final fav = context.watch<FavoritesController>();
  final view = context.watch<LibraryViewController>();

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
        child: view.viewMode == LibraryViewMode.list
            ? SongListView(
                songs: sortedSongs,
                onPlay: (index) {
                  audio.setPlaylist(sortedSongs, initialIndex: index);
                },
                isFavorite: fav.isFavorite,
                onToggleFavorite: fav.toggleFavorite,
                onAddToPlaylist: (songId) {
                  AddToPlaylistSheet.show(context, songId);
                },
              )
            : _SongsGridView(
                songs: sortedSongs,
              ),
      ),
    ],
  );
}
}

class _SongsGridView extends StatelessWidget {
  final List<SongModel> songs;

  const _SongsGridView({required this.songs});

  @override
  Widget build(BuildContext context) {
    final audio = context.read<AudioPlayerController>();
    final fav = context.watch<FavoritesController>();
    final view = context.watch<LibraryViewController>();

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: view.gridCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: _aspectRatioFor(view.gridCount),
      ),
      itemCount: songs.length,
      itemBuilder: (_, i) {
        final song = songs[i];
        return SongGridTile(
          songId: song.id,
          title: song.title,
          isFavorite: fav.isFavorite(song.id),
          onTap: () => audio.setPlaylist(songs, initialIndex: i),
          onToggleFavorite: () => fav.toggleFavorite(song.id),
          onAddToPlaylist: () {
            AddToPlaylistSheet.show(context, song.id);
          },
        );
      },
    );
  }
}

double _aspectRatioFor(int count) {
  switch (count) {
    case 2:
      return 0.75;
    case 3:
      return 0.65;
    case 4:
      return 0.55;
    default:
      return 0.55;
  }
}
