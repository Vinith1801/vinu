// lib/player/library_controller.dart
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class LibraryController extends ChangeNotifier {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  // ------------------------------------------------------------
  // MASTER LISTS (raw)
  // ------------------------------------------------------------
  List<SongModel> _allSongs = [];
  List<AlbumModel> _allAlbums = [];
  List<ArtistModel> _allArtists = [];
  List<String> _allFolders = [];

  // Exposed read-only getters
  List<SongModel> get songs => _allSongs;
  List<AlbumModel> get albums => _allAlbums;
  List<ArtistModel> get artists => _allArtists;
  List<String> get folders => _allFolders;

  // ------------------------------------------------------------
  // FILTERED LISTS (UI uses these)
  // ------------------------------------------------------------
  List<SongModel> filteredSongs = [];
  List<AlbumModel> filteredAlbums = [];
  List<ArtistModel> filteredArtists = [];
  List<String> filteredFolders = [];

  /// Folder → number of songs inside
  Map<String, int> folderSongCount = {};

  bool loading = true;
  bool permissionGranted = false;

  LibraryController();

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------
  Future<void> init() async {
    await _requestPermission();

    if (!permissionGranted) {
      loading = false;
      notifyListeners();
      return;
    }

    await _loadLibrary();

    // Default filtered = show everything
    filteredSongs = List.from(_allSongs);
    filteredAlbums = List.from(_allAlbums);
    filteredArtists = List.from(_allArtists);
    filteredFolders = List.from(_allFolders);

    loading = false;
    notifyListeners();
  }

  Future<void> waitUntilReady() async {
    while (loading) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  // ------------------------------------------------------------
  // PERMISSIONS
  // ------------------------------------------------------------
  Future<void> _requestPermission() async {
    permissionGranted = await _audioQuery.permissionsStatus();
    if (!permissionGranted) {
      permissionGranted = await _audioQuery.permissionsRequest();
    }
  }

  // ------------------------------------------------------------
  // LOAD DEVICE LIBRARY (songs, albums, artists, folders)
  // ------------------------------------------------------------
  Future<void> _loadLibrary() async {
    _allSongs = await _audioQuery.querySongs();
    _allAlbums = await _audioQuery.queryAlbums();
    _allArtists = await _audioQuery.queryArtists();
    _allFolders = await _audioQuery.queryAllPath();

    // Build folder counts properly
    final Map<String, int> folderCounts = {};

    for (var s in _allSongs) {
      final folder = extractFolder(s.data);

      if (folder.isEmpty) continue;

      folderCounts[folder] = (folderCounts[folder] ?? 0) + 1;
    }

    // This was the bug. You were assigning the wrong variable.
    folderSongCount = folderCounts;
  }

  // ------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------
  /// Extract folder path from a full file path.
  String extractFolder(String path) {
    final normalized = path.replaceAll("\\", "/");
    final idx = normalized.lastIndexOf("/");
    if (idx <= 0) return "";
    return normalized.substring(0, idx);
  }

  // ------------------------------------------------------------
  // VISIBILITY FILTERS (called by HomeScreen)
  // ------------------------------------------------------------
  void applyVisibility({
    required bool folderScanEnabled,
    required List<String> enabledFolders,
  }) {
    // Songs filtering
    if (folderScanEnabled && enabledFolders.isNotEmpty) {
      final allowed = Set<String>.from(enabledFolders);
      filteredSongs = _allSongs.where((s) {
        final folder = extractFolder(s.data);
        return allowed.contains(folder);
      }).toList();
    } else {
      filteredSongs = List<SongModel>.from(_allSongs);
    }

    // Albums & artists
    filteredAlbums = List<AlbumModel>.from(_allAlbums);
    filteredArtists = List<ArtistModel>.from(_allArtists);

    // FIX: Always show all folders
    filteredFolders = List<String>.from(_allFolders);

    notifyListeners();
  }

  // ------------------------------------------------------------
  // LEGACY / QUERY HELPERS
  // ------------------------------------------------------------
  List<SongModel> getSongsByAlbum(int albumId) =>
      filteredSongs.where((s) => s.albumId == albumId).toList();

  List<SongModel> getSongsByArtist(String artistName) =>
      filteredSongs
          .where((s) =>
              (s.artist ?? "").toLowerCase() ==
              artistName.toLowerCase())
          .toList();

  List<SongModel> getSongsByFolder(String folderPath) =>
      filteredSongs.where((s) => extractFolder(s.data) == folderPath).toList();
}
