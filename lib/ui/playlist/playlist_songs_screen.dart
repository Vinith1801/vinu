import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:vinu/ui/playlist/playlist_dialogs.dart';

import '../../state/favorites/favorites_controller.dart';
import '../../state/library/library_controller.dart';
import '../../state/player/audio_player_controller.dart';
import '../../state/playlist/playlist_controller.dart';
import '../../state/playlist/vinu_playlist.dart';

import '../shared/song_list_view.dart';
import '../shared/song_sort_mode.dart';
import '../shared/song_sorter.dart';
import '../shared/song_toolbar.dart';

class PlaylistSongsScreen extends StatefulWidget {
  final VinuPlaylist playlist;
  const PlaylistSongsScreen({super.key, required this.playlist});

  @override
  State<PlaylistSongsScreen> createState() => _PlaylistSongsScreenState();
}

class _PlaylistSongsScreenState extends State<PlaylistSongsScreen> {
  SongSortMode _sortMode = SongSortMode.title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final playlistCtrl = context.watch<PlaylistController>();
    final playlist =
        playlistCtrl.getPlaylist(widget.playlist.id) ?? widget.playlist;

    final songs = _playlistSongs(context, playlist);
    final sorted = SongSorter.sort(songs, _sortMode);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: _PlaylistAppBar(
        playlist: playlist,
        songCount: sorted.length,
        onRename: () => PlaylistDialogs.showRename(context, playlist),
        onDelete: () async {
          final ok = await PlaylistDialogs.confirmDelete(context, playlist);
          if (ok) {
            playlistCtrl.deletePlaylist(playlist.id);
            if (context.mounted) Navigator.pop(context);
          }
        },
      ),
      body: Column(
        children: [
          SongToolbar(
            activeSort: _sortMode,
            onSort: (m) => setState(() => _sortMode = m),
            onShuffle: () {
              final audio = context.read<AudioPlayerController>();
              final shuffled = [...sorted]..shuffle();
              audio.queue.setPlaylist(shuffled, index: 0);
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: sorted.isEmpty
                ? const _EmptyState()
                : _SongList(
                    songs: sorted,
                    playlist: playlist,
                  ),
          ),
        ],
      ),
    );
  }

  List<SongModel> _playlistSongs(
    BuildContext context,
    VinuPlaylist playlist,
  ) {
    final library = context.read<LibraryController>();
    final ids = playlist.songIds.toSet();
    return library.songs.where((s) => ids.contains(s.id)).toList();
  }
}

class _PlaylistAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VinuPlaylist playlist;
  final int songCount;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _PlaylistAppBar({
    required this.playlist,
    required this.songCount,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(playlist.name,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          Text(
            '$songCount song${songCount == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Rename',
          icon: const Icon(Icons.edit_rounded),
          onPressed: onRename,
        ),
        IconButton(
          tooltip: 'Delete',
          icon: const Icon(Icons.delete_outline_rounded),
          onPressed: onDelete,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SongList extends StatelessWidget {
  final List<SongModel> songs;
  final VinuPlaylist playlist;

  const _SongList({
    required this.songs,
    required this.playlist,
  });

  @override
  Widget build(BuildContext context) {
    final audio = context.read<AudioPlayerController>();
    final favs = context.read<FavoritesController>();
    final playlists = context.read<PlaylistController>();

    return SongListView(
      songs: songs,
      onPlay: (i) => audio.queue.setPlaylist(songs, index: i),
      isFavorite: favs.isFavorite,
      onToggleFavorite: favs.toggleFavorite,
      onAddToPlaylist: (_) {},
      onRemoveFromPlaylist: (songId) {
        playlists.removeSong(playlist.id, songId);
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'This playlist is empty',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
