//lib/player/library_visibility_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryVisibilityController extends ChangeNotifier {
  static const _kTabs = 'settings.visibility.tabs';
  static const _kFolderScan = 'settings.visibility.folderScanEnabled';
  static const _kFolderMap = 'settings.visibility.folderMap';

  final Map<String, bool> visibleTabs = {
    "Songs": true,
    "Favorites": true,
    "Playlists": true,
    "Artists": true,
    "Albums": true,
    "Folders": true,
  };

  bool folderScanEnabled = true;

  // folderPath -> enabled
  Map<String, bool> folderMap = {};

  // NEW: folderPath -> song count
  Map<String, int> folderSongCount = {};

  LibraryVisibilityController() {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();

    // Load tab visibility
    final storedTabs = p.getStringList(_kTabs);
    if (storedTabs != null) {
      for (var entry in storedTabs) {
        final parts = entry.split("|");
        if (parts.length == 2) {
          visibleTabs[parts[0]] = parts[1] == "1";
        }
      }
    }

    // Load folder scan on/off
    folderScanEnabled = p.getBool(_kFolderScan) ?? true;

    // Load folder map (enabled/disabled)
    final folderList = p.getStringList(_kFolderMap);
    if (folderList != null) {
      for (var entry in folderList) {
        final parts = entry.split("|");
        if (parts.length == 2) {
          folderMap[parts[0]] = parts[1] == "1";
        }
      }
    }

    notifyListeners();
  }

  Future<void> _saveTabs() async {
    final p = await SharedPreferences.getInstance();
    final list = visibleTabs.entries.map((e) => "${e.key}|${e.value ? 1 : 0}").toList();
    await p.setStringList(_kTabs, list);
  }

  Future<void> _saveFolderMap() async {
    final p = await SharedPreferences.getInstance();
    final list = folderMap.entries.map((e) => "${e.key}|${e.value ? 1 : 0}").toList();
    await p.setStringList(_kFolderMap, list);
  }

  Future<void> toggleTab(String key) async {
    visibleTabs[key] = !(visibleTabs[key] ?? true);
    await _saveTabs();
    notifyListeners();
  }

  List<String> get activeTabs =>
      visibleTabs.entries.where((e) => e.value).map((e) => e.key).toList();


  // ----------------------------------------------------
  // NEW: Register folders WITH song count
  // ----------------------------------------------------
  void registerFolders(Map<String, int> folderCounts) async {
    bool changed = false;

    folderCounts.forEach((path, count) {
      folderSongCount[path] = count;

      if (!folderMap.containsKey(path)) {
        folderMap[path] = true; // default ON
        changed = true;
      }
    });

    if (changed) {
      await _saveFolderMap();
    }

    notifyListeners();
  }

  Future<void> toggleFolder(String path) async {
    folderMap[path] = !(folderMap[path] ?? true);
    await _saveFolderMap();
    notifyListeners();
  }

  List<String> get enabledFolders =>
      folderMap.entries.where((e) => e.value).map((e) => e.key).toList();
}
