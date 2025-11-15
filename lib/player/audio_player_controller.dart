import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AudioPlayerController extends ChangeNotifier {
  final player = AudioPlayer();
  List<SongModel> playlist = [];
  int currentIndex = 0;

  void setPlaylist(List<SongModel> songs) {
    playlist = songs;
  }

  Future<void> playSong(SongModel song) async {
    currentIndex = playlist.indexOf(song);

    try {
      await player.setAudioSource(
        AudioSource.uri(Uri.parse(song.uri!)),
      );
      player.play();
      notifyListeners();
    } catch (e) {
      debugPrint("Playback Error: $e");
    }
  }

  void togglePlayPause() {
    player.playing ? player.pause() : player.play();
    notifyListeners();
  }

  void next() {
    if (currentIndex < playlist.length - 1) {
      currentIndex++;
      playSong(playlist[currentIndex]);
    }
  }

  void previous() {
    if (currentIndex > 0) {
      currentIndex--;
      playSong(playlist[currentIndex]);
    }
  }

  void seek(Duration position) {
    player.seek(position);
  }

  SongModel? get currentSong {
    if (playlist.isEmpty) return null;
    return playlist[currentIndex];
  }

  bool get isPlaying => player.playing;

  Stream<Duration> get positionStream => player.positionStream;
  Stream<Duration?> get durationStream => player.durationStream;
  Stream<Duration> get bufferStream => player.bufferedPositionStream;
}
