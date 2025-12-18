import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PlayerSkinType {
  classic,
  minimal,
  circular,
}

class PlayerSkinController extends ChangeNotifier {
  static const _prefsKey = 'player.skin';

  PlayerSkinType _skin = PlayerSkinType.classic;

  PlayerSkinType get selectedSkin => _skin;

  PlayerSkinController() {
    _loadSkin();
  }

  Future<void> _loadSkin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);

      if (raw == null) return;

      final restored = PlayerSkinType.values
          .where((e) => e.name == raw)
          .cast<PlayerSkinType?>()
          .firstOrNull;

      if (restored != null) {
        _skin = restored;
        notifyListeners();
      }
    } catch (_) {
      // silent fallback
    }
  }

  Future<void> setSkin(PlayerSkinType skin) async {
    if (_skin == skin) return;

    _skin = skin;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, skin.name);
    } catch (_) {
      // ignore write failure
    }
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
