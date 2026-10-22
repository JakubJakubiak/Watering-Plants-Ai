import 'dart:io';

import 'package:ai_hub_client/ai_hub_client.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/account_controller.dart';
import 'core/ads.dart';
import 'core/analytics.dart';
import 'core/app_paths.dart';
import 'core/config.dart';
import 'core/locale_controller.dart';
import 'core/theme_controller.dart';
import 'data/chat_repository.dart';
import 'database/chat_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  await Future.wait([
    AppPaths.init(),
    _initFirebase(),
    _initPurchases(),
    MobileAds.instance.initialize(),
  ]);

  final hub = AiHubClient(
    baseUrl: Uri.parse(AppConfig.aiHubUrl),
    app: AppConfig.aiHubApp,
    clientKey: AppConfig.aiHubClientKey,
    deviceId: await _deviceId(),
    tokenStore: PrefsTokenStore(),
    platform: Platform.operatingSystem,
  );
  final account = AccountController(hub)..start();
  final ads = AdsController(account)..preload();
  final db = ChatDatabase();

  runApp(
    MultiProvider(
      providers: [
        Provider<AiHubClient>.value(value: hub),
        Provider<ChatRepository>(create: (_) => ChatRepository(db, hub)),
        ChangeNotifierProvider<AccountController>.value(value: account),
        ChangeNotifierProvider<AdsController>.value(value: ads),
        ChangeNotifierProvider<LocaleController>(create: (_) => LocaleController()),
        ChangeNotifierProvider<ThemeController>(create: (_) => ThemeController()),
      ],
      child: const PlantsApp(),
    ),
  );
}

/// Firebase tylko do analityki. Bez pliku konfiguracyjnego (np. iOS) aplikacja działa dalej.
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
    Analytics.attach(FirebaseAnalytics.instance);
  } catch (e) {
    debugPrint('Firebase disabled: $e');
  }
}

Future<void> _initPurchases() async {
  if (!Platform.isAndroid) return; // Klucz RevenueCat jest tylko dla Google Play.
  try {
    if (kDebugMode) await Purchases.setLogLevel(LogLevel.info);
    await Purchases.configure(PurchasesConfiguration(AppConfig.revenueCatAndroidKey));
  } catch (e) {
    debugPrint('RevenueCat configure failed: $e');
  }
}

/// Stały identyfikator urządzenia — ten sam, którego używał Firebase (uid)
/// i RevenueCat. Gdy wtyczka zawiedzie, generujemy i zapamiętujemy własny.
Future<String> _deviceId() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('deviceId');
  if (saved != null) return saved;
  String? id;
  try {
    id = await MobileDeviceIdentifier().getDeviceId();
  } catch (e) {
    debugPrint('device id unavailable: $e');
  }
  if (id == null || id.length < 8) {
    id = 'gen-${DateTime.now().microsecondsSinceEpoch}-${Object().hashCode}';
  }
  await prefs.setString('deviceId', id);
  return id;
}
