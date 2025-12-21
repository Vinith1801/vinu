import 'package:flutter/material.dart';
import '../../core/audio/audio_engine.dart';
import 'playback_controller.dart';
import 'queue_controller.dart';
import 'position_controller.dart';
import 'artwork_controller.dart';

class AudioPlayerController extends ChangeNotifier {
  final AudioEngine engine;

  late final PlaybackController playback;
  late final QueueController queue;
  late final PositionController position;
  late final ArtworkController artwork;

  AudioPlayerController(this.engine) {
    artwork = ArtworkController();
    playback = PlaybackController(engine);
    queue = QueueController(engine, artwork);
    position = PositionController(engine);

    playback.addListener(notifyListeners);
    queue.addListener(notifyListeners);
  }

  @override
  void dispose() {
    playback.removeListener(notifyListeners);
    queue.removeListener(notifyListeners);
    position.dispose();
    super.dispose();
  }
}
