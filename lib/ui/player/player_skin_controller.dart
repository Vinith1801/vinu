import 'package:flutter/material.dart';

class PlayerSkinController extends ChangeNotifier {
  int selectedSkin = 0;

  void setSkin(int index) {
    selectedSkin = index;
    notifyListeners();
  }
}
