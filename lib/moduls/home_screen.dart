import 'dart:async';

import 'package:PlantsAI/main.dart';
import 'package:PlantsAI/moduls/chat/chat_history_screen.dart';
import 'package:PlantsAI/moduls/chat/new_chat_screen.dart';
import 'package:PlantsAI/moduls/game_over_dialog.dart';
import 'package:PlantsAI/moduls/payment/paymentrevenuecat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:PlantsAI/moduls/admob_service.dart';
import 'package:PlantsAI/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _currentIndex = 0;
  int counter = 0;

  BannerAd? _banner;
  RewardedAd? _rewardedAd;
  bool renderActive = false;
  bool isPro = false;

  int score = 0;
  int currentIndex = 0;
  List<Map<String, dynamic>> generatedHistory = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late StreamSubscription<DocumentSnapshot> _tokensSubscription;

  User? user;
  String userid = "";

  @override
  void initState() {
    super.initState();
    _createBanerAd();
    _loadRewardedAd();
    // _setupIsPro();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPaywallIfNeeded();
    });

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        try {
          await Purchases.logIn(user.uid);
        } catch (e) {
          print("Sign in error: ${e.toString()}");
        }
      }
    });

    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      EntitlementInfo? entitlement = customerInfo.entitlements.all['Pro'];
      bool isProActive = (entitlement?.isActive ?? false);
      setState(() {
        isPro = isProActive;
      });
    });
  }

  Future<void> _showPaywallIfNeeded() async {
    if (isPro) return;
    final navigator = Navigator.of(context);
    Offerings offerings = await Purchases.getOfferings();
    final offering = offerings.current;

    if (offering == null) return;

    navigator.push(
      MaterialPageRoute(builder: (context) => PaywallView(offering: offering)),
    );
  }

  void _createBanerAd() {
    if (!Constants.adsEnabled || isPro) return;
    _banner = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: AdMobService.bannerAdUnitId,
      listener: AdMobService.bannerAdListener,
      request: const AdRequest(),
    )..load();
  }

  void endGame() async {
    CounterModel counterModel = Provider.of<CounterModel>(context, listen: false);
    counter = counterModel.counter;
    // _setupIsPro();

    showGameOverDialog(counter);
  }

  void showGameOverDialog(int counter) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => GameOverDialog(
          score: counter,
          isPro: isPro,
          onContinuePlaying: (BuildContext dialogContext) async {
            if (_rewardedAd != null && Constants.adsEnabled) {
              await _rewardedAd?.show(
                onUserEarnedReward: (ad, reward) {
                  addPoints();
                  Navigator.of(dialogContext).pop();
                },
              );
            } else {
              Navigator.of(dialogContext).pop();
            }
          },
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        opaque: false,
        barrierDismissible: false,
        fullscreenDialog: true,
      ),
    );
  }

  void addPoints() async {
    // CounterModel counterModel = Provider.of<CounterModel>(context, listen: false);
    // int counter = counterModel.counter;
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('runPoinst');
      await callable.call();
    } catch (error) {
      print(error);
    }
    // setState(() {
    //   counter += 4;
    //   saveBestScore(counter);
    // });
  }

  Future<void> _loadRewardedAd() async {
    if (!Constants.adsEnabled || isPro) return;
    await RewardedAd.load(
      adUnitId: AdMobService.rewardedAdUnitID,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) =>
                // log('ad onAdShowedFullScreenContent.'),
                print('ad onAdShowedFullScreenContent.'),
            onAdDismissedFullScreenContent: (ad) async {
              print('ad onAdDismissedFullScreenContent.');
              await ad.dispose();
              await _loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              print('ad onAdFailedToShowFullScreenContent: $error');
              ad.dispose();
            },
            onAdImpression: (ad) => print('ad impression.'),
          );
        },
        onAdFailedToLoad: (error) {
          print('RewardedAd failed to load: $error  ${AdMobService.rewardedAdUnitID}');
          _rewardedAd = null;
        },
      ),
    );
  }

  void rewardedAdTrueFuzcion() {
    Provider.of<RewardedAdProvider>(context, listen: false).updateRewardedAdStatus(true);
  }

  @override
  Widget build(BuildContext context) {
    final int tokens = Provider.of<int>(context);

    return Consumer<CounterModel>(builder: (context, counterModel, _) {
      final _pages = [
        const NewChatScreen(),
        ChatHistoryScreen(key: UniqueKey()),
      ];
      return Scaffold(
        appBar: AppBar(
          actions: [
            ActionChip(
              avatar: const Icon(Icons.add_circle_rounded, color: Colors.blueAccent),
              label: isPro ? const Text('Pro') : Text('$tokens uses'),
              side: const BorderSide(
                color: Colors.blueAccent,
                width: 2,
              ),
              tooltip: 'Watch an ad to get 4 more uses',
              onPressed: () async {
                endGame();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                double bannerHeight = 60;
                double bannerWidth = constraints.maxWidth;

                return (_banner == null && renderActive == false)
                    ? Container(height: 0)
                    : SizedBox(
                        height: bannerHeight,
                        width: bannerWidth,
                        child: AdWidget(ad: _banner!),
                      );
              },
            )
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.chat),
              label: 'New Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              label: 'Chat History',
            ),
          ],
        ),
      );
    });
  }
}
