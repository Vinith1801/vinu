// lib/ui/screens/home/tabs/albums_tab.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../album_songs_screen.dart';

class _ArtworkLoader extends StatefulWidget {
  final int id;
  final ArtworkType type;
  final double size;
  final BorderRadius borderRadius;
  final Widget placeholder;

  const _ArtworkLoader({
    required this.id,
    required this.type,
    required this.size,
    required this.borderRadius,
    required this.placeholder,
  });

  @override
  State<_ArtworkLoader> createState() => _ArtworkLoaderState();
}

class _ArtworkLoaderState extends State<_ArtworkLoader>
    with AutomaticKeepAliveClientMixin {
  Uint8List? _bytes;
  bool _loading = false;

  static final Map<String, Uint8List> _memoryCache = {};

  String get _key => "${widget.type}_${widget.id}";

  @override
  void initState() {
    super.initState();
    _loadArtwork();
  }

  void _loadArtwork() {
    if (_memoryCache.containsKey(_key)) {
      _bytes = _memoryCache[_key];
      if (mounted) setState(() {});
      return;
    }

    if (_loading) return;
    _loading = true;

    OnAudioQuery()
        .queryArtwork(widget.id, widget.type, format: ArtworkFormat.PNG)
        .then((bytes) {
      if (bytes != null) {
        _memoryCache[_key] = bytes;
        if (mounted) setState(() => _bytes = bytes);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_bytes != null) {
      return ClipRRect(
        borderRadius: widget.borderRadius,
        child: RepaintBoundary(
          child: Image.memory(
            _bytes!,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: widget.placeholder,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class AlbumsTab extends StatelessWidget {
  final List<AlbumModel> albums;
  const AlbumsTab({super.key, required this.albums});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.5);

    if (albums.isEmpty) {
      return Center(child: Text("No albums", style: TextStyle(color: muted)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: albums.length,
      itemBuilder: (_, i) {
        final a = albums[i];

        return ListTile(
          key: ValueKey(a.id),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          leading: _ArtworkLoader(
            id: a.id,
            type: ArtworkType.ALBUM,
            size: 56,
            borderRadius: BorderRadius.circular(8),
            placeholder: Container(
              color: scheme.surfaceContainerHighest,
              child: Icon(Icons.album_rounded, color: muted),
            ),
          ),
          title: Text(a.album,
              style:
                  TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
          subtitle:
              Text("${a.numOfSongs} songs", style: TextStyle(color: muted)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AlbumSongsScreen(album: a)),
            );
          },
        );
      },
    );
  }
}
