// lib/ui/screens/playlist_songs_screen.dart
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../../models/vinu_playlist.dart';
import '../../player/audio_player_controller.dart';
import '../../player/playlist_controller.dart';
import '../../player/library_controller.dart';
import '../widgets/track_tile.dart';
import '../widgets/song_toolbar.dart';

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
    final audioCtrl = context.read<AudioPlayerController>();
    final lib = context.read<LibraryController>();

    final updated = playlistCtrl.getPlaylist(widget.playlist.id) ?? widget.playlist;

    // Instant list from centralized library
    final playlistSongs = lib.songs.where((s) => updated.songIds.contains(s.id)).toList();

    // Copy + apply sort
    final List<SongModel> list = List<SongModel>.from(playlistSongs);
    _applySort(list);

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        title: Text(updated.name,
            style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add songs',
            onPressed: () => _showAddSongsDialog(context, lib.songs, updated),
          )
        ],
      ),

      body: list.isEmpty
          ? Center(child: Text("No songs in this playlist", style: TextStyle(color: scheme.onSurfaceVariant)))
          : Column(
              children: [
                SongToolbar(
                  songs: list,
                  activeSort: sortMode,
                  onShuffle: () {
                    final shuffled = List<SongModel>.from(list)..shuffle();
                    audioCtrl.setPlaylist(shuffled, initialIndex: 0);
                  },
                  onSort: (mode) {
                    setState(() => sortMode = mode);
                  },
                ),

                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final s = list[i];
                      return Dismissible(
                        key: ValueKey(s.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.redAccent,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          playlistCtrl.removeSong(updated.id, s.id);
                        },
                        child: TrackTile(
                          title: s.title,
                          artist: s.artist ?? "Unknown Artist",
                          songId: s.id,
                          onTap: () => audioCtrl.setPlaylist(list, initialIndex: i),
                          insidePlaylist: true,
                          playlistId: updated.id,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _applySort(List<SongModel> list) {
    switch (sortMode) {
      case SongSortMode.title:
        list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SongSortMode.artist:
        list.sort((a, b) =>
            (a.artist ?? '').toLowerCase().compareTo((b.artist ?? '').toLowerCase()));
        break;
      case SongSortMode.duration:
        list.sort((a, b) => (a.duration ?? 0).compareTo(b.duration ?? 0));
        break;
      case SongSortMode.date:
        list.sort((a, b) => (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0));
        break;
    }
  }

  void _showAddSongsDialog(BuildContext ctx, List<SongModel> allSongs, VinuPlaylist playlist) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text("Add songs"),
        content: SizedBox(
          width: double.maxFinite,
          height: 420,
          child: _AddSongsList(allSongs: allSongs, playlist: playlist),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
        ],
      ),
    );
  }
}

// Reuse _AddSongsList from your previous code (keeps behavior identical)
class _AddSongsList extends StatefulWidget {
  final List<SongModel> allSongs;
  final VinuPlaylist playlist;

  const _AddSongsList({required this.allSongs, required this.playlist});

  @override
  State<_AddSongsList> createState() => _AddSongsListState();
}

class _AddSongsListState extends State<_AddSongsList> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final playlistCtrl = context.read<PlaylistController>();
    final scheme = Theme.of(context).colorScheme;

    final shown = widget.allSongs.where((s) {
      final q = query.toLowerCase();
      return s.title.toLowerCase().contains(q) ||
          (s.artist ?? "").toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: "Search songs...",
          ),
          onChanged: (t) => setState(() => query = t),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: ListView.separated(
            itemCount: shown.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final s = shown[i];
              final isAdded = widget.playlist.songIds.contains(s.id);

              return ListTile(
                title: Text(s.title),
                subtitle: Text(s.artist ?? "Unknown"),
                trailing: isAdded
                    ? Icon(Icons.check, color: scheme.primary)
                    : TextButton(
                        child: const Text("Add"),
                        onPressed: () {
                          playlistCtrl.addSong(widget.playlist.id, s.id);
                          setState(() {});
                        },
                      ),
              );
            },
          ),
        )
      ],
    );
  }
}
