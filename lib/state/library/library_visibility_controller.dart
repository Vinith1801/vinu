import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryVisibilityController extends ChangeNotifier {
  static const _kTabs = 'settings.visibility.tabs';
  static const _kFolderScan = 'settings.visibility.folderScanEnabled';
  static const _kFolderMap = 'settings.visibility.folderMap';

  // Callback to tell HomeScreen to re-scan
  VoidCallback? onFolderSettingsChanged;

  // Default visibility for home tabs
  final Map<String, bool> visibleTabs = {
    "Songs": true,
    "Favorites": true,
    "Playlists": true,
    "Artists": true,
    "Albums": true,
    "Folders": true,
  };

  bool folderScanEnabled = true;

  // folderPath -> enabled (toggle)
  Map<String, bool> folderMap = {};

  // folderPath -> count of songs
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

    // Load folder scanning ON/OFF
    folderScanEnabled = p.getBool(_kFolderScan) ?? true;

    // Load folder map
    final storedMap = p.getStringList(_kFolderMap);
    if (storedMap != null) {
      for (var entry in storedMap) {
        final parts = entry.split("|");
        if (parts.length == 2) {
          folderMap[parts[0]] = parts[1] == "1";
        }
      }
    }

    notifyListeners();
  }

  // ---------------------------------------------
// Manually trigger folder refresh
// Notifies HomeScreen to re-scan the library
// ---------------------------------------------
void refreshFolders() {
  // Notify HomeScreen that a refresh is requested
  onFolderSettingsChanged?.call();

  // UI rebuild for consistency
  notifyListeners();
}


  // Save tab visibility
  Future<void> _saveTabs() async {
    final p = await SharedPreferences.getInstance();
    final list = visibleTabs.entries
        .map((e) => "${e.key}|${e.value ? 1 : 0}")
        .toList();
    await p.setStringList(_kTabs, list);
  }

  // Save folder map
  Future<void> _saveFolderMap() async {
    final p = await SharedPreferences.getInstance();
    final list = folderMap.entries
        .map((e) => "${e.key}|${e.value ? 1 : 0}")
        .toList();
    await p.setStringList(_kFolderMap, list);
  }

  // Toggle tab visibility
  Future<void> toggleTab(String key) async {
    visibleTabs[key] = !(visibleTabs[key] ?? true);
    await _saveTabs();
    notifyListeners();
  }

  List<String> get activeTabs =>
      visibleTabs.entries.where((e) => e.value).map((e) => e.key).toList();

  // ---------------------------------------------
  // REGISTER FOLDERS WITH SONG COUNT
  // Called from HomeScreen.loadData()
  // ---------------------------------------------
  Future<void> registerFolders(Map<String, int> counts) async {
    bool changed = false;

    counts.forEach((path, count) {
      folderSongCount[path] = count;

      if (!folderMap.containsKey(path)) {
        folderMap[path] = true; // default ON
        changed = true;
      }
    });

    if (changed) {
      await _saveFolderMap();
    }

    // Notify HomeScreen to update folder list live
    onFolderSettingsChanged?.call();

    notifyListeners();
  }

  // ---------------------------------------------
  // Toggle a single folder scanning switch
  // ---------------------------------------------
  Future<void> toggleFolder(String path) async {
    folderMap[path] = !(folderMap[path] ?? true);
    await _saveFolderMap();

    // Tell HomeScreen to re-scan and rebuild songs list
    onFolderSettingsChanged?.call();

    notifyListeners();
  }

  // ---------------------------------------------
  // GLOBAL folder scanning ON/OFF
  // This MUST also trigger HomeScreen refresh
  // ---------------------------------------------
  Future<void> toggleFolderScan() async {
    folderScanEnabled = !folderScanEnabled;

    final p = await SharedPreferences.getInstance();
    await p.setBool(_kFolderScan, folderScanEnabled);

    // Now the Songs list should refresh immediately
    onFolderSettingsChanged?.call();

    notifyListeners();
  }

  // Enabled folders list
  List<String> get enabledFolders =>
      folderMap.entries.where((e) => e.value).map((e) => e.key).toList();
}
