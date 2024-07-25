import 'dart:ui';

import 'package:PlantsAI/database/chat_database.dart';
import 'package:PlantsAI/moduls/home_screen.dart';
import 'package:PlantsAI/providers/chat_notifier.dart';
import 'package:PlantsAI/repositories/chat_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:PlantsAI/utils/shared_preferences_helper.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  await signInAnonymously();

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
        ChangeNotifierProxyProvider<ChatRepository, ChatNotifier>(
            create: (context) => ChatNotifier(context.read<ChatRepository>()), update: (context, repository, previous) => ChatNotifier(repository))
      ],
      child: const MyApp(),
    ),
  );
}

final purchasesConfiguration = PurchasesConfiguration('goog_JAECeoDvUtPzyJCMILswDqaphZy');

Future<void> signInAnonymously() async {
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});
// Colors.white70
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Caption',
      // locale: systemLocale,
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
      home: const FuturisticWrapper(child: HomeScreen()),
    );
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
