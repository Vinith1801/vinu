// lib/ui/screens/playlist_songs_screen.dart
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:vinu/models/vinu_playlist.dart';
import 'package:vinu/player/audio_player_controller.dart';
import 'package:vinu/player/playlist_controller.dart';
import '../widgets/track_tile.dart';

class PlaylistSongsScreen extends StatefulWidget {
  final VinuPlaylist playlist;
  const PlaylistSongsScreen({super.key, required this.playlist});

  @override
  State<PlaylistSongsScreen> createState() => _PlaylistSongsScreenState();
}

class _PlaylistSongsScreenState extends State<PlaylistSongsScreen> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<SongModel> _allSongs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAllSongs();
  }

  Future<void> _loadAllSongs() async {
    try {
      _allSongs = await _audioQuery.querySongs();
    } catch (_) {
      _allSongs = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final playlistCtrl = context.watch<PlaylistController>();
    final audioCtrl = context.read<AudioPlayerController>();

    // Get up-to-date playlist reference (controller may have changed it)
    final playlist = playlistCtrl.getPlaylist(widget.playlist.id) ?? widget.playlist;

    final playlistSongs = _allSongs.where((s) => playlist.songIds.contains(s.id)).toList();

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        title: Text(playlist.name, style: TextStyle(fontWeight: FontWeight.w800, color: scheme.onSurface)),
        actions: [
          IconButton(
            tooltip: 'Add songs',
            icon: const Icon(Icons.add),
            onPressed: _loading ? null : () => _showAddSongsDialog(context, _allSongs, playlist),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: scheme.primary))
          : playlistSongs.isEmpty
              ? Center(child: Text("No songs in this playlist", style: TextStyle(color: scheme.onSurface.withOpacity(0.6))))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: playlistSongs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final s = playlistSongs[i];
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
                        context.read<PlaylistController>().removeSong(playlist.id, s.id);
                      },
                      child: TrackTile(
                        title: s.title,
                        artist: s.artist ?? "Unknown Artist",
                        songId: s.id,
                        onTap: () {
                          // build list of SongModel in playlist order and play
                          audioCtrl.setPlaylist(playlistSongs, initialIndex: i);
                        },
                      ),
                    );
                  },
                ),
    );
  }

  void _showAddSongsDialog(BuildContext ctx, List<SongModel> allSongs, VinuPlaylist playlist) {
    showDialog(
      context: ctx,
      builder: (_) {
        return AlertDialog(
          title: const Text("Add songs"),
          content: SizedBox(
            width: double.maxFinite,
            height: 420,
            child: _AddSongsList(allSongs: allSongs, playlist: playlist),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
          ],
        );
      },
    );
  }
}

class _AddSongsList extends StatefulWidget {
  final List<SongModel> allSongs;
  final VinuPlaylist playlist;

  const _AddSongsList({required this.allSongs, required this.playlist});

  @override
  State<_AddSongsList> createState() => _AddSongsListState();
}

class _AddSongsListState extends State<_AddSongsList> {
  late List<SongModel> filtered;
  String query = "";

  @override
  void initState() {
    super.initState();
    filtered = widget.allSongs;
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<PlaylistController>();
    final scheme = Theme.of(context).colorScheme;

    final shown = filtered.where((s) => s.title.toLowerCase().contains(query.toLowerCase()) || (s.artist ?? "").toLowerCase().contains(query.toLowerCase())).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: "Search songs..."),
            onChanged: (t) => setState(() => query = t),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: shown.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final s = shown[i];
              final isAdded = widget.playlist.songIds.contains(s.id);
              return ListTile(
                title: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(s.artist ?? "Unknown", maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: isAdded
                    ? Icon(Icons.check, color: scheme.primary)
                    : TextButton(
                        child: const Text("Add"),
                        onPressed: () {
                          ctrl.addSong(widget.playlist.id, s.id);
                          setState(() {}); // refresh check icon
                        },
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}
