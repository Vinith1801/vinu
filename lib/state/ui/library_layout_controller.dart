import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LibraryViewMode { list, grid }

class LibraryLayoutController extends ChangeNotifier {
  static const _kViewMode = 'library.viewMode';
  static const _kGridCount = 'library.gridCount';

  LibraryViewMode viewMode = LibraryViewMode.list;
  int gridCount = 2;

  LibraryLayoutController() {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();

    viewMode = LibraryViewMode.values[
        p.getInt(_kViewMode) ?? LibraryViewMode.list.index
    ];

    gridCount = p.getInt(_kGridCount) ?? 2;
    gridCount = gridCount.clamp(2, 4);

    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kViewMode, viewMode.index);
    await p.setInt(_kGridCount, gridCount);
  }

  void setViewMode(LibraryViewMode mode) {
    viewMode = mode;
    _save();
    notifyListeners();
  }

  void setGridCount(int count) {
    gridCount = count.clamp(2, 4);
    _save();
    notifyListeners();
  }
}
