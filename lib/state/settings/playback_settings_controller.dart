import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaybackSettingsController extends ChangeNotifier {
  static const _key = 'play_in_background';
  bool _value = true;

  bool get playInBackground => _value;

  PlaybackSettingsController() {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _value = p.getBool(_key) ?? true;
    notifyListeners();
  }

  Future<void> set(bool v) async {
    _value = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_key, v);
    notifyListeners();
  }
}
