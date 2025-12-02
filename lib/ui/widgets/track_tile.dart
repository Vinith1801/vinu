// lib/ui/widgets/track_tile.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../player/favorites_controller.dart';
import '../../player/audio_player_controller.dart';

class TrackTile extends StatelessWidget {
  final String title;
  final String artist;
  final int songId;
  final VoidCallback onTap;

  const TrackTile({
    super.key,
    required this.title,
    required this.artist,
    required this.songId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Artwork
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 55,
                height: 55,
                child: _Artwork(
                  key: ValueKey(songId), // IMPORTANT FIX
                  songId: songId,
                  placeholder: Container(
                    height: 55,
                    width: 55,
                    color: scheme.surfaceContainerHighest,
                    child: Icon(Icons.music_note,
                        color: scheme.onSurfaceVariant),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // TITLE + ARTIST
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            _FavoriteButton(songId: songId),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// ARTWORK WIDGET – FIXED & REBUILDS CORRECTLY
// ------------------------------------------------------------
class _Artwork extends StatefulWidget {
  final int songId;
  final Widget placeholder;

  const _Artwork({
    super.key,
    required this.songId,
    required this.placeholder,
  });

  @override
  State<_Artwork> createState() => _ArtworkState();
}

class _ArtworkState extends State<_Artwork> {
  Uri? _uri;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadArtwork();
  }

  @override
  void didUpdateWidget(covariant _Artwork oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.songId != widget.songId) {
      _uri = null;
      _loading = false;
      _loadArtwork();
    }
  }

  void _loadArtwork() {
    final ctrl = context.read<AudioPlayerController>();

    final cached = ctrl.getCachedArtworkUri(widget.songId);
    if (cached != null) {
      _uri = cached;
      if (mounted) setState(() {});
      return;
    }

    if (!_loading) {
      _loading = true;
      ctrl.ensureArtworkForId(widget.songId).then((uri) {
        if (mounted) {
          setState(() {
            _uri = uri;
            _loading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uri != null) {
      final file = File.fromUri(_uri!);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    return widget.placeholder;
  }
}

// ------------------------------------------------------------
// FAVORITE BUTTON
// ------------------------------------------------------------
class _FavoriteButton extends StatelessWidget {
  final int songId;

  const _FavoriteButton({required this.songId});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Selector<FavoritesController, bool>(
      selector: (_, fav) => fav.isFavorite(songId),
      builder: (_, isFav, __) {
        return GestureDetector(
          onTap: () => context.read<FavoritesController>().toggleFavorite(songId),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isFav),
              color: isFav ? scheme.primary : scheme.onSurfaceVariant.withValues(alpha: 0.6),
              size: 26,
            ),
          ),
        );
      },
    );
  }
}
