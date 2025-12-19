import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/audio/audio_engine.dart';

class PlaybackController extends ChangeNotifier {
  final AudioEngine engine;

  bool _isPlaying = false;
  bool isShuffling = false;
  LoopMode loopMode = LoopMode.off;

  PlaybackController(this.engine) {
    _isPlaying = engine.player.playing;
    engine.player.playingStream.listen((v) {
      if (_isPlaying != v) {
        _isPlaying = v;
        notifyListeners();
      }
    });
  }

  bool get isPlaying => _isPlaying;

  void togglePlayPause() {
    _isPlaying ? engine.player.pause() : engine.player.play();
  }

  void next() => engine.player.seekToNext();
  void previous() => engine.player.seekToPrevious();

  Future<void> seek(Duration d) => engine.player.seek(d);

  Future<void> setSpeed(double speed) =>
      engine.player.setSpeed(speed.clamp(0.25, 3.0));

  Future<void> toggleShuffle() async {
    isShuffling = !isShuffling;
    await engine.player.setShuffleModeEnabled(isShuffling);
    if (isShuffling) await engine.player.shuffle();
    notifyListeners();
  }

  void toggleRepeat() {
    loopMode = switch (loopMode) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    engine.player.setLoopMode(loopMode);
    notifyListeners();
  }
}
