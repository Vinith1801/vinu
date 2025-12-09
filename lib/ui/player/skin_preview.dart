// lib/ui/player/skin_preview.dart
import 'package:flutter/material.dart';

class SkinPreview extends StatelessWidget {
  final String name;
  final Widget preview;
  final bool selected;
  final VoidCallback onTap;

  const SkinPreview({
    super.key,
    required this.name,
    required this.preview,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outline.withAlpha(30),
            width: selected ? 3 : 1,
          ),
          boxShadow: [
            if (!selected)
              BoxShadow(
                color: Colors.black.withValues( alpha:0.03),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            // Preview region with overlayed Applied badge if selected
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox.expand(child: preview),
                  ),
                  if (selected)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Applied',
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
