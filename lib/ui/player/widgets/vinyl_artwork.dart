import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:vinu/state/player/audio_player_controller.dart';
import 'package:vinu/ui/shared/artwork_loader.dart';

class VinylArtwork extends StatefulWidget {
  final int songId;
  final double size;

  const VinylArtwork({super.key, required this.songId, this.size = 300});

  @override
  State<VinylArtwork> createState() => _VinylArtworkState();
}

class _VinylArtworkState extends State<VinylArtwork> with TickerProviderStateMixin {
  late final AnimationController _rotateCtrl;
  late final AnimationController _tonearmCtrl;

  @override
  void initState() {
    super.initState();

    _rotateCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 14));
    _tonearmCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      reverseDuration: const Duration(milliseconds: 360),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final isPlaying = context.watch<AudioPlayerController>().playback.isPlaying;
    if (isPlaying) {
      if (!_rotateCtrl.isAnimating) _rotateCtrl.repeat();
      _tonearmCtrl.forward();
    } else {
      _rotateCtrl.stop();
      _tonearmCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _tonearmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final artSize = widget.size * 0.73;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Black base (vinyl)
          Container(
            width: widget.size,
            height: widget.size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
          ),

          // Grooves
          ...List.generate(4, (i) {
            final radius = widget.size - (i * 32);
            return Container(
              width: radius,
              height: radius,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues( alpha:0.5),
                  width: 1,
                ),
              ),
            );
          }),

          // Gloss sweep
          Transform.rotate(
            angle: -0.4,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  startAngle: 0,
                  endAngle: math.pi * 2,
                  colors: [
                    Colors.white.withValues( alpha:0.23),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.white.withValues( alpha:0.23),
                  ],
                  stops: const [0.0, 0.18, 0.82, 1.0],
                ),
              ),
            ),
          ),

          // Rotating artwork (unified loader)
          RotationTransition(
            turns: _rotateCtrl,
            child: ClipOval(
              child: SizedBox(
                width: artSize,
                height: artSize,
                child: ArtworkLoader(
                  id: widget.songId,
                  type: ArtworkType.AUDIO,
                  size: artSize,
                  borderRadius: BorderRadius.circular(artSize / 2),
                  placeholder: Container(
                    width: artSize,
                    height: artSize,
                    color: Colors.grey.shade900,
                    child: Icon(
                      Icons.music_note,
                      size: artSize * 0.27,
                      color: Colors.white.withValues( alpha:0.7),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Center cap
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),

          // Tonearm (positioned)
          Positioned(
            right: -18,
            top: -18,
            child: AnimatedBuilder(
              animation: _tonearmCtrl,
              builder: (context, child) {
                return Transform.rotate(
                  angle: -0.6 + _tonearmCtrl.value * 0.55,
                  alignment: Alignment.topLeft,
                  child: child,
                );
              },
              child: _buildTonearm(scheme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTonearm(ColorScheme scheme) {
    final armColor = scheme.onSurface;
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: armColor.withValues( alpha:0.5),
                border: Border.all(color: armColor.withValues( alpha:0.3), width: 2),
              ),
            ),
          ),
          Positioned(
            left: 10,
            top: 10,
            child: Container(
              width: 6,
              height: 110,
              decoration: BoxDecoration(
                color: armColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              ),
            ),
          ),
          Positioned(
            left: 4,
            top: 112,
            child: Transform.rotate(
              angle: 0.28,
              child: Container(
                width: 28,
                height: 20,
                decoration: BoxDecoration(
                  color: armColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
