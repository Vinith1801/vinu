// lib/ui/screens/home/tabs/artists_tab.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../artist_songs_screen.dart';

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
        child: Image.memory(
          _bytes!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
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

class ArtistsTab extends StatelessWidget {
  final List<ArtistModel> artists;
  const ArtistsTab({super.key, required this.artists});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = scheme.onSurface.withValues(alpha: 0.5);

    if (artists.isEmpty) {
      return Center(child: Text("No artists", style: TextStyle(color: muted)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: artists.length,
      itemBuilder: (_, i) {
        final a = artists[i];

        return ListTile(
          key: ValueKey(a.id),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          leading: _ArtworkLoader(
            id: a.id,
            type: ArtworkType.ARTIST,
            size: 56,
            borderRadius: BorderRadius.circular(28),
            placeholder: Container(
              color: scheme.surfaceContainerHighest,
              child: Icon(Icons.person, color: muted),
            ),
          ),
          title: Text(a.artist,
              style:
                  TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
          subtitle: Text("${a.numberOfTracks} tracks",
              style: TextStyle(color: muted)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ArtistSongsScreen(artist: a)),
            );
          },
        );
      },
    );
  }
}
