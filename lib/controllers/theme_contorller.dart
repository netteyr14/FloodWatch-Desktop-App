import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  bool isDark = false;

  void toggleTheme() {
    isDark = !isDark;
    notifyListeners();
  }
}

final themeController = ThemeController();
