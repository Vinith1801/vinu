import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vinu_playlist.dart';

class PlaylistController extends ChangeNotifier {
  static const _kKey = "vinu.playlists";

  List<VinuPlaylist> playlists = [];

  PlaylistController() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_kKey) ?? [];
      playlists = list
          .map((e) => VinuPlaylist.fromJson(jsonDecode(e) as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {
      playlists = [];
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = playlists.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_kKey, jsonList);
  }

  Future<void> createPlaylist(String name) async {
    final p = VinuPlaylist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songIds: [],
    );
    playlists.add(p);
    await _save();
    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    playlists.removeWhere((p) => p.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final idx = playlists.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    playlists[idx].name = newName;
    await _save();
    notifyListeners();
  }

  Future<void> addSong(String playlistId, int songId) async {
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    if (idx == -1) return;
    final p = playlists[idx];
    if (!p.songIds.contains(songId)) {
      p.songIds.add(songId);
      await _save();
      notifyListeners();
    }
  }

  Future<void> removeSong(String playlistId, int songId) async {
    final idx = playlists.indexWhere((p) => p.id == playlistId);
    if (idx == -1) return;
    final p = playlists[idx];
    p.songIds.remove(songId);
    await _save();
    notifyListeners();
  }

  VinuPlaylist? getPlaylist(String id) {
    for (final p in playlists) {
      if (p.id == id) return p;
    }
    return null;
  }
}
