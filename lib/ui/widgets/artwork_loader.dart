// lib/ui/widgets/artwork_loader.dart
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';

class ArtworkLoader extends StatefulWidget {
  final int id;
  final ArtworkType type;
  final double size;
  final BorderRadius borderRadius;
  final Widget? placeholder;

  const ArtworkLoader({
    super.key,
    required this.id,
    required this.type,
    required this.size,
    required this.borderRadius,
    this.placeholder,
  });

  @override
  State<ArtworkLoader> createState() => _ArtworkLoaderState();
}

class _ArtworkLoaderState extends State<ArtworkLoader>
    with AutomaticKeepAliveClientMixin {
  Uint8List? _memoryBytes;
  File? _diskFile;
  bool _loading = false;

  // Global memory cache (fastest)
  static final Map<String, Uint8List> _memoryCache = {};

  String get _cacheKey => "${widget.type}_${widget.id}";

  @override
  void initState() {
    super.initState();
    _loadArtwork();
  }

  @override
  void didUpdateWidget(covariant ArtworkLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id || oldWidget.type != widget.type) {
      _memoryBytes = null;
      _diskFile = null;
      _loadArtwork();
    }
  }

  Future<void> _loadArtwork() async {
    // 1. MEMORY CACHE CHECK
    if (_memoryCache.containsKey(_cacheKey)) {
      _memoryBytes = _memoryCache[_cacheKey];
      if (mounted) setState(() {});
      return;
    }

    // 2. DISK CACHE CHECK
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/art_${_cacheKey}.png");

    if (file.existsSync()) {
      final bytes = await file.readAsBytes();
      if (bytes.isNotEmpty) {
        _diskFile = file;
        _memoryCache[_cacheKey] = bytes;
        _memoryBytes = bytes;
        if (mounted) setState(() {});
        return;
      }
    }

    // 3. LOAD FROM DEVICE (slowest)
    if (_loading) return;
    _loading = true;

    final bytes = await OnAudioQuery().queryArtwork(
      widget.id,
      widget.type,
      format: ArtworkFormat.PNG,
      size: 1200,
    );

    if (!mounted) return;

    if (bytes != null && bytes.isNotEmpty) {
      _memoryCache[_cacheKey] = bytes;
      _memoryBytes = bytes;

      // Save to disk cache
      await file.writeAsBytes(bytes, flush: true);
      _diskFile = file;
    }

    _loading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget child;

    if (_memoryBytes != null) {
      child = Image.memory(
        _memoryBytes!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
      );
    } else if (_diskFile != null && _diskFile!.existsSync()) {
      child = Image.file(
        _diskFile!,
        fit: BoxFit.cover,
        width: widget.size,
        height: widget.size,
      );
    } else {
      child = widget.placeholder ??
          Container(
            width: widget.size,
            height: widget.size,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(Icons.music_note, color: Theme.of(context).colorScheme.onSurfaceVariant),
          );
    }

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: RepaintBoundary(child: SizedBox(width: widget.size, height: widget.size, child: child)),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
