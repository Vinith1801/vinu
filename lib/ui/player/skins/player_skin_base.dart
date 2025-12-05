import 'package:flutter/material.dart';
import '../../../player/audio_player_controller.dart';

abstract class PlayerSkin extends StatelessWidget {
  final AudioPlayerController controller;
  final VoidCallback onClose;
  final VoidCallback openQueue;

  const PlayerSkin({
    super.key,
    required this.controller,
    required this.onClose,
    required this.openQueue,
  });
}
