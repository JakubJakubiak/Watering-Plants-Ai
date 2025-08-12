import 'dart:convert';

import 'package:plantsai/database/chat_database.dart';
import 'package:plantsai/moduls/home_screen.dart';
import 'package:plantsai/providers/chat_notifier.dart';
import 'package:plantsai/repositories/chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:plantsai/utils/shared_preferences_helper.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:plantsai/languages/i10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await Firebase.initializeApp();
  await SharedPreferencesHelper.initialize();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await initializePurchases();
  signInAnonymously();

  final db = ChatDatabase();
  final firebaseFunctions = FirebaseFunctions.instance;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<RewardedAdProvider>(
          create: (_) => RewardedAdProvider(),
        ),
        ChangeNotifierProvider<CounterModel>(
          create: (_) => CounterModel(),
        ),
        StreamProvider<int>(
          create: (_) => tokensStream(),
          initialData: 0,
        ),
        Provider<ChatRepository>(
          create: (_) => ChatRepository(db, firebaseFunctions),
        ),
        ChangeNotifierProvider<LocaleProvider>(
          create: (_) => LocaleProvider(),
        ),
        ChangeNotifierProxyProvider<ChatRepository, ChatNotifier>(
            create: (context) => ChatNotifier(context.read<ChatRepository>()), update: (context, repository, previous) => ChatNotifier(repository)),
      ],
      child: const MyApp(),
    ),
  );
}

final purchasesConfiguration = PurchasesConfiguration('goog_JAECeoDvUtPzyJCMILswDqaphZy');

Future<void> signInAnonymously() async {
  if (FirebaseAuth.instance.currentUser != null) {
    return;
  }

  try {
    final mobileDeviceId = await MobileDeviceIdentifier().getDeviceId();
    final response = await FirebaseFunctions.instance.httpsCallable('createCustomToken').call<Map<String, dynamic>>({
      'uid': mobileDeviceId,
    });
    print('UsermobileDeviceId: $mobileDeviceId');
    final customToken = response.data['customToken'] as String?;
    if (customToken == null) {
      throw Exception('Failed to obtain custom token.');
    }

    final userCredential = await FirebaseAuth.instance.signInWithCustomToken(customToken);

    print('User: $userCredential');
  } on FirebaseAuthException catch (e) {
  } on Exception catch (e, st) {
    debugPrint('Failed to sign in anonymously. Error: $e, StackTrace: $st');
  }
}

Future<void> initializePurchases() async {
  try {
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(purchasesConfiguration);
    // await RevenueCatUI.presentPaywallIfNeeded("Pro");
  } catch (e) {
    print('Error configuring purchases: $e');
  }
}

class LocaleProvider with ChangeNotifier {
  final Map<String, String> languageNames = {
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

  Locale? _selectedLocale;

  LocaleProvider() {
    _loadSelectedLanguage();
  }
  String loaacles = Locale(Intl.getCurrentLocale().split('_')[0]).languageCode;
  Locale get selectedLocale => _selectedLocale ?? Locale(loaacles);
  String get selectedLanguage => languageNames[_selectedLocale?.languageCode ?? Intl.getCurrentLocale()] ?? 'English';
  Map<String, String> get supportedLanguages => languageNames;

  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? selectedLanguage = prefs.getString('selectedLanguage');

    if (selectedLanguage != null) {
      _selectedLocale = Locale(selectedLanguage);
    }

    notifyListeners();
  }

  void updateSelectedLanguage(String shortCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', shortCode);
    _selectedLocale = Locale(shortCode);
    notifyListeners();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(builder: (context, localeProvider, _) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Caption',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: localeProvider.selectedLocale ?? Locale("en"),
        themeMode: ThemeMode.system,
        darkTheme: ThemeData.dark().copyWith(
          iconTheme: const IconThemeData(
            color: Colors.white70,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        theme: ThemeData.light().copyWith(
          // scaffoldBackgroundColor: Colors.black,
          // iconTheme: const IconThemeData(
          //   color: Colors.white70,
          // ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
        builder: (context, child) {
          return FuturisticWrapper(child: child ?? const SizedBox());
        },
        home: const HomeScreen(),
      );
    });
  }
}

class FuturisticWrapper extends StatelessWidget {
  final Widget child;
  const FuturisticWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black,
            Colors.blueAccent.withOpacity(0.3),
            Colors.purpleAccent.withOpacity(0.3),
          ],
        ),
      ),
      child: child,
    ).animate().fadeIn(duration: const Duration(milliseconds: 500));
  }
}

class RewardedAdProvider with ChangeNotifier {
  bool rewardedAdTrue = false;

  void updateRewardedAdStatus(bool status) {
    rewardedAdTrue = status;
    notifyListeners();
  }
}

class CounterModel with ChangeNotifier {
  int _counter = 1;
  int get counter => _counter;

  void updateCounter(int counter) {
    _counter = counter;
    notifyListeners();
  }
}

Stream<int> tokensStream() async* {
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield 0;
    } else {
      yield* FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots().map((snapshot) {
        if (snapshot.exists && snapshot.data()!.containsKey('tokens')) {
          return snapshot.data()!['tokens'];
        }

        return 0;
      });
    }
  }
}
