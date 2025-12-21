import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AudioEngine {
  final AudioPlayer player = AudioPlayer();

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> stopAndRelease() async {
    await player.stop();
    await player.dispose();
  }
}
