import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';

/// Firebase służy już tylko do analityki: zdarzenia aktywności i statystyki.
/// Gdy Firebase nie wystartował (np. brak GoogleService-Info.plist na iOS),
/// wszystkie wywołania są cichym no-opem.
class Analytics {
  Analytics._();

  static FirebaseAnalytics? _instance;

  static void attach(FirebaseAnalytics analytics) => _instance = analytics;

  static List<NavigatorObserver> get observers =>
      _instance == null ? const [] : [FirebaseAnalyticsObserver(analytics: _instance!)];

  static Future<void> log(String name, [Map<String, Object>? parameters]) async {
    final analytics = _instance;
    if (analytics == null) return;
    try {
      await analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      debugPrint('analytics $name failed: $e');
    }
  }

  static Future<void> setUserProperty(String name, String? value) async {
    try {
      await _instance?.setUserProperty(name: name, value: value);
    } catch (_) {}
  }

  // Nazwy zdarzeń w jednym miejscu, żeby raporty w Firebase były spójne.
  static Future<void> scanStarted(String source) => log('scan_started', {'source': source});
  static Future<void> plantIdentified({required String name, required bool hasCare}) =>
      log('plant_identified', {'plant': name, 'has_care': hasCare ? 1 : 0});
  static Future<void> messageSent({required bool quickQuestion}) =>
      log('chat_message_sent', {'quick_question': quickQuestion ? 1 : 0});
  static Future<void> aiError(String code) => log('ai_error', {'code': code});
  static Future<void> outOfCredits(String where) => log('out_of_credits', {'where': where});
  static Future<void> rewardClaimed() => log('reward_claimed');
  static Future<void> paywallShown(String source) => log('paywall_shown', {'source': source});
  static Future<void> purchaseCompleted(String product) => log('purchase_completed', {'product': product});
  static Future<void> plantWatered() => log('plant_watered');
  static Future<void> plantRemoved() => log('plant_removed');
  static Future<void> libraryOpened(String plant) => log('library_plant_opened', {'plant': plant});
  static Future<void> languageChanged(String code) => log('language_changed', {'language': code});
  static Future<void> plantShared() => log('plant_shared');
}
