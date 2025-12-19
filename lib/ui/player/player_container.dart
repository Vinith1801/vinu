import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mini_player.dart';
import 'full_player.dart';
import 'package:vinu/state/player/audio_player_controller.dart';

class PlayerContainer extends StatefulWidget {
  const PlayerContainer({super.key});

  @override
  State<PlayerContainer> createState() => _PlayerContainerState();
}

class _PlayerContainerState extends State<PlayerContainer> {
  static const double _openDragThreshold = -600;

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: FullPlayer(
              onClose: () => Navigator.of(context).pop(),
            ),
          );
        },
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasQueue = context.select<AudioPlayerController, bool>(
      (c) => c.queue.playlist.isNotEmpty,
    );

    if (!hasQueue) return const SizedBox.shrink();

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _openFullScreen(context),
      onVerticalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        if (v < _openDragThreshold) {
          _openFullScreen(context);
        }
      },
      child: const SafeArea(
        top: false,
        child: MiniPlayer(),
      ),
    );
  }
}
