// lib/ui/player/full_player.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vinu/ui/player/player_skin_controller.dart';
import 'package:vinu/ui/player/skins/skin_classic.dart';
import 'package:vinu/ui/player/skins/skin_glassy_blur.dart';
import 'package:vinu/ui/player/skins/skin_minimal.dart';
import 'package:vinu/ui/player/skins/skin_minimal_pro.dart';
import 'package:vinu/ui/player/skins/skin_neon_glow.dart';
import 'package:vinu/ui/player/skins/skin_retro_tape.dart';
import 'package:vinu/ui/player/skins/skin_vinyl_ultra.dart';
import 'package:vinu/ui/player/widgets/queue_bottom_sheet.dart';

import '../../player/audio_player_controller.dart';

class FullPlayer extends StatefulWidget {
  final VoidCallback onClose;

  const FullPlayer({super.key, required this.onClose});

  @override
  State<FullPlayer> createState() => _FullPlayerState();
}

class _FullPlayerState extends State<FullPlayer> {

  // -----------------------------
  // QUEUE BOTTOM SHEET
  // -----------------------------
  void _openQueue() => QueueBottomSheet.show(context);

  @override
Widget build(BuildContext context) {
  final controller = context.watch<AudioPlayerController>();
  final skinIndex = context.watch<PlayerSkinController>().selectedSkin;

  final skins = [
    SkinClassic(controller: controller, onClose: widget.onClose, openQueue: _openQueue),
    SkinMinimal(controller: controller, onClose: widget.onClose, openQueue: _openQueue),
    SkinMinimalPro(controller: controller, onClose: widget.onClose, openQueue: _openQueue),
    SkinNeonGlow(controller: controller, onClose: widget.onClose, openQueue: _openQueue),
    SkinRetroTape(controller: controller, onClose: widget.onClose, openQueue: _openQueue),
    SkinGlassyBlur(controller: controller, onClose: widget.onClose, openQueue: _openQueue),
    SkinVinylUltra(controller: controller, onClose: widget.onClose, openQueue: _openQueue),
  ];

  return Scaffold(
    body: SafeArea(child: skins[skinIndex]),
  );
}

}
