// lib/ui/player/mini_artwork.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../player/audio_player_controller.dart';

class MiniArtwork extends StatefulWidget {
  final int songId;
  final Widget? placeholder;

  const MiniArtwork({super.key, required this.songId, this.placeholder});

  @override
  State<MiniArtwork> createState() => _MiniArtworkState();
}

class _MiniArtworkState extends State<MiniArtwork> {
  Uri? _uri;
  bool _loading = false;
  bool _fileExists = false;

  @override
  void initState() {
    super.initState();
    _loadArtwork();
  }

  @override
  void didUpdateWidget(covariant MiniArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songId != widget.songId) {
      _uri = null;
      _fileExists = false;
      _loading = false;
      _loadArtwork();
    }
  }

  void _loadArtwork() {
    final ctrl = context.read<AudioPlayerController>();

    final cached = ctrl.getCachedArtworkUri(widget.songId);
    if (cached != null) {
      _uri = cached;
      _fileExists = File.fromUri(cached).existsSync();
      if (mounted) setState(() {});
      return;
    }

    if (_loading) return;
    _loading = true;

    ctrl.ensureArtworkForId(widget.songId).then((uri) {
      if (!mounted) return;
      _uri = uri;
      _fileExists = uri != null && File.fromUri(uri).existsSync();
      _loading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_uri != null && _fileExists) {
      return Image.file(
        File.fromUri(_uri!),
        fit: BoxFit.cover,
      );
    }

    return widget.placeholder ??
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(Icons.music_note, size: 26, color: Theme.of(context).colorScheme.onSurface),
        );
  }
}
