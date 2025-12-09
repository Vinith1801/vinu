// lib/ui/widgets/artwork_loader.dart
import 'dart:typed_data';
import 'dart:io';
import 'dart:collection';

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

  static final LinkedHashMap<String, Uint8List> _memoryCache =
      LinkedHashMap<String, Uint8List>();

  static const int _maxEntries = 200; // tune this value (100-400) per device expectations

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

  // -------------------------
  // LRU helpers
  // -------------------------
  static Uint8List? _cacheGet(String key) {
    final v = _memoryCache.remove(key);
    if (v == null) return null;
    // Re-insert to mark as most-recently-used
    _memoryCache[key] = v;
    return v;
  }

  static void _cacheSet(String key, Uint8List data) {
    // If exists, remove so we can re-insert (new MRU)
    if (_memoryCache.containsKey(key)) {
      _memoryCache.remove(key);
    }
    _memoryCache[key] = data;

    // Evict oldest entries if limit reached
    while (_memoryCache.length > _maxEntries) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
  }

  Future<void> _loadArtwork() async {
    // 1. MEMORY CACHE CHECK (fast, synchronous read from RAM)
    final mem = _cacheGet(_cacheKey);
    if (mem != null) {
      _memoryBytes = mem;
      if (mounted) setState(() {});
      return;
    }

    // 2. DISK CACHE CHECK (async non-blocking)
    try {
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/art_${_cacheKey}.png");
      final exists = await file.exists();
      if (exists) {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          _diskFile = file;
          _cacheSet(_cacheKey, bytes);
          _memoryBytes = bytes;
          if (mounted) setState(() {});
          return;
        }
      }
    } catch (_) {
      // ignore disk errors -- will fallback to queryArtwork
    }

    // 3. LOAD FROM DEVICE (slowest) -- guard concurrent calls
    if (_loading) return;
    _loading = true;

    try {
      final bytes = await OnAudioQuery().queryArtwork(
        widget.id,
        widget.type,
        format: ArtworkFormat.PNG,
        size: 1200,
      );

      if (!mounted) return;

      if (bytes != null && bytes.isNotEmpty) {
        // Update caches
        _cacheSet(_cacheKey, bytes);
        _memoryBytes = bytes;

        // Save to disk cache (best-effort)
        try {
          final dir = await getTemporaryDirectory();
          final file = File("${dir.path}/art_${_cacheKey}.png");
          await file.writeAsBytes(bytes, flush: true);
          _diskFile = file;
        } catch (_) {
          // ignore disk write failures
        }
      }
    } catch (_) {
      // ignore
    } finally {
      _loading = false;
      if (mounted) setState(() {});
    }
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
      // small-risk synchronous check here, but diskFile was established earlier via async read
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
            child: Icon(Icons.music_note,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          );
    }

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: RepaintBoundary(
        child: SizedBox(width: widget.size, height: widget.size, child: child),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
