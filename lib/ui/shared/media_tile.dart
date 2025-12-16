// lib/ui/widgets/media_tile.dart
import 'package:flutter/material.dart';
import 'artwork_loader.dart';

class MediaTile extends StatelessWidget {
  final Widget? artwork;
  final int? artworkId;
  final dynamic artworkType;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final double artworkSize;
  final BorderRadius? artworkRadius;

  const MediaTile({
    super.key,
    this.artwork,
    this.artworkId,
    this.artworkType,
    required this.title,
    this.subtitle,
    this.onTap,
    this.artworkSize = 56,
    this.artworkRadius,
  }) : assert(artwork != null || (artworkId != null && artworkType != null),
            'Provide either artwork widget, or artworkId+artworkType');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final art = artwork ??
        ArtworkLoader(
          id: artworkId as int,
          type: artworkType,
          size: artworkSize,
          borderRadius: artworkRadius ?? BorderRadius.circular(8),
        );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      leading: SizedBox(width: artworkSize, height: artworkSize, child: art),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onSurface)),
      subtitle: subtitle == null ? null : Text(subtitle!, style: TextStyle(color: scheme.onSurfaceVariant)),
      onTap: onTap,
    );
  }
}
