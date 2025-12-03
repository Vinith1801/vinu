import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class LibraryController extends ChangeNotifier {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  // Main library datasets
  List<SongModel> songs = [];
  List<AlbumModel> albums = [];
  List<ArtistModel> artists = [];
  List<String> folders = [];

  // Folder → song count
  Map<String, int> folderSongCount = {};

  bool loading = true;
  bool permissionGranted = false;

  Future<void> init() async {
    await _requestPermission();
    if (!permissionGranted) {
      loading = false;
      notifyListeners();
      return;
    }

    await _loadLibrary();
    loading = false;
    notifyListeners();
  }

  Future<void> _requestPermission() async {
    permissionGranted = await _audioQuery.permissionsStatus();
    if (!permissionGranted) {
      permissionGranted = await _audioQuery.permissionsRequest();
    }
  }

  Future<void> _loadLibrary() async {
    songs = await _audioQuery.querySongs();
    albums = await _audioQuery.queryAlbums();
    artists = await _audioQuery.queryArtists();
    folders = await _audioQuery.queryAllPath();

    _computeFolderSongCounts();
  }

  void _computeFolderSongCounts() {
    folderSongCount.clear();
    for (final f in folders) {
      folderSongCount[f] =
          songs.where((s) => s.data.startsWith(f)).length;
    }
  }

  // Utils for screens
  List<SongModel> getSongsByAlbum(int albumId) =>
      songs.where((s) => s.albumId == albumId).toList();

  List<SongModel> getSongsByArtist(String artistName) =>
      songs.where((s) =>
          (s.artist ?? "").toLowerCase() ==
          artistName.toLowerCase()).toList();

  List<SongModel> getSongsByFolder(String folderPath) =>
      songs
          .where((s) => s.data.startsWith(folderPath))
          .toList()
        ..sort((a, b) => a.title.compareTo(b.title));
}
