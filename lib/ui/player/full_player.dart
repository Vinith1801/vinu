import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinu/ui/player/player_skin_controller.dart';
import 'package:vinu/ui/player/skins/skin_classic.dart';
import 'package:vinu/ui/player/skins/skin_minimal.dart';
import 'package:vinu/ui/player/skins/skin_circular.dart';
import 'package:vinu/ui/player/widgets/queue_bottom_sheet.dart';
import 'package:vinu/state/player/audio_player_controller.dart';

class FullPlayer extends StatefulWidget {
  final VoidCallback onClose;

  const FullPlayer({super.key, required this.onClose});

  @override
  State<FullPlayer> createState() => _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> {
  void _openQueue() => QueueBottomSheet.show(context);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AudioPlayerController>();
    final skin = context.watch<PlayerSkinController>().selectedSkin;

    final Widget skinWidget = switch (skin) {
      PlayerSkinType.classic => SkinClassic(
          controller: controller,
          onClose: widget.onClose,
          openQueue: _openQueue,
        ),
      PlayerSkinType.minimal => SkinMinimal(
          controller: controller,
          onClose: widget.onClose,
          openQueue: _openQueue,
        ),
      PlayerSkinType.circular => SkinCircular(
          controller: controller,
          onClose: widget.onClose,
          openQueue: _openQueue,
        ),
    };

    return Scaffold(
      body: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: skinWidget,
        ),
      ),
    );
  }
}
