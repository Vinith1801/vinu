import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesController extends ChangeNotifier {
  List<int> favoriteIds = [];

  FavoritesController() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    favoriteIds =
        prefs.getStringList("favorites")?.map(int.parse).toList() ?? [];
    notifyListeners();
  }

  Future<void> toggleFavorite(int songId) async {
    final prefs = await SharedPreferences.getInstance();

    if (favoriteIds.contains(songId)) {
      favoriteIds.remove(songId);
    } else {
      favoriteIds.add(songId);
    }

    await prefs.setStringList(
      "favorites",
      favoriteIds.map((id) => id.toString()).toList(),
    );

    notifyListeners();
  }

  bool isFavorite(int songId) => favoriteIds.contains(songId);
}
