import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_engine.dart';

class VinuAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioEngine engine;

  VinuAudioHandler(this.engine) {
    engine.player.playbackEventStream.listen(_broadcastState);

    // IMPORTANT: wait for READY before publishing MediaItem
    engine.player.processingStateStream.listen(_onProcessingState);

    engine.player.currentIndexStream.listen((_) {
      _publishMediaItemIfReady();
    });
  }

  /* -------------------- PLAYBACK STATE -------------------- */

  void _broadcastState(PlaybackEvent event) {
    final player = engine.player;

    playbackState.add(
      playbackState.value.copyWith(
        controls: const [
          MediaControl.skipToPrevious,
          MediaControl.play,
          MediaControl.pause,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: const [0, 1, 3],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        playing: player.playing,
        processingState: _mapProcessingState(player.processingState),
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
      ),
    );
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  /* -------------------- MEDIA ITEM (FIXED) -------------------- */

  void _onProcessingState(ProcessingState state) {
    if (state == ProcessingState.ready) {
      _publishMediaItemIfReady();
    }
  }

  void _publishMediaItemIfReady() {
    final player = engine.player;
    final index = player.currentIndex;
    final sequence = player.sequence;
    final duration = player.duration;

    if (index == null ||
        sequence == null ||
        index >= sequence.length ||
        duration == null ||
        duration == Duration.zero) {
      return;
    }

    final tag = sequence[index].tag;
    if (tag is! MediaItem) return;

    final itemWithDuration = tag.copyWith(duration: duration);

    // Only publish once per track
    if (mediaItem.value?.id != itemWithDuration.id ||
        mediaItem.value?.duration != itemWithDuration.duration) {
      mediaItem.add(itemWithDuration);
    }
  }

  /* -------------------- TRANSPORT CONTROLS -------------------- */

  @override
  Future<void> play() => engine.player.play();

  @override
  Future<void> pause() => engine.player.pause();

  @override
  Future<void> stop() => engine.player.stop();

  @override
  Future<void> seek(Duration position) =>
      engine.player.seek(position);

  @override
  Future<void> skipToNext() =>
      engine.player.seekToNext();

  @override
  Future<void> skipToPrevious() =>
      engine.player.seekToPrevious();

  /* -------------------- TASK REMOVAL POLICY -------------------- */

  @override
  Future<void> onTaskRemoved() async {
    final prefs = await SharedPreferences.getInstance();
    final allowBackground =
        prefs.getBool('play_in_background') ?? true;

    if (!allowBackground) {
      await engine.stopAndRelease();
    }

    await super.onTaskRemoved();
  }
}
