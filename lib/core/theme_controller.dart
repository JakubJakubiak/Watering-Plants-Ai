import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController with ChangeNotifier {
  ThemeController() {
    _load();
  }

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> _load() async {
    final saved = (await SharedPreferences.getInstance()).getString('themeMode');
    final mode = ThemeMode.values.where((m) => m.name == saved).firstOrNull;
    if (mode != null && mode != _mode) {
      _mode = mode;
      notifyListeners();
    }
  }

  Future<void> select(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    await (await SharedPreferences.getInstance()).setString('themeMode', mode.name);
  }
}
