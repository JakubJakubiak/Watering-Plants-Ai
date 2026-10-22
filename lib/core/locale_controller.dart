import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics.dart';

/// Język interfejsu i odpowiedzi AI.
class LocaleController with ChangeNotifier {
  static const languageNames = {
    'en': 'English',
    'pl': 'Polski',
    'es': 'Español',
    'de': 'Deutsch',
    'fr': 'Français',
    'it': 'Italiano',
    'ar': 'العربية',
    'hi': 'हिन्दी',
    'ja': '日本語',
    'zh': '中文',
    'uk': 'Українська',
  };

  LocaleController() {
    _load();
  }

  Locale? _selected;

  String get _systemCode {
    final code = PlatformDispatcher.instance.locale.languageCode;
    return languageNames.containsKey(code) ? code : 'en';
  }

  Locale get locale => _selected ?? Locale(_systemCode);

  /// Nazwa języka przekazywana do modelu, np. "Polski".
  String get languageName => languageNames[locale.languageCode] ?? 'English';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('selectedLanguage');
    if (code != null && languageNames.containsKey(code)) {
      _selected = Locale(code);
      notifyListeners();
    }
  }

  Future<void> select(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', code);
    _selected = Locale(code);
    Analytics.languageChanged(code);
    notifyListeners();
  }
}
