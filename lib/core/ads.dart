import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'account_controller.dart';
import 'config.dart';

class AdUnits {
  static String get banner {
    if (kDebugMode) return 'ca-app-pub-3940256099942544/6300978111';
    return Platform.isAndroid ? 'ca-app-pub-5915784054696948/6052949323' : 'ca-app-pub-5915784054696948/9426559499';
  }

  static String get interstitial {
    if (kDebugMode) return 'ca-app-pub-3940256099942544/1033173712';
    return Platform.isAndroid ? 'ca-app-pub-5915784054696948/8104397590' : '';
  }

  static String get rewarded {
    if (kDebugMode) return 'ca-app-pub-3940256099942544/5224354917';
    return Platform.isAndroid ? 'ca-app-pub-5915784054696948/8104397590' : 'ca-app-pub-5915784054696948/6894892781';
  }
}

/// Reklamy w wersji darmowej: pełnoekranowa co [AppConfig.interstitialEvery]
/// zapytań do AI i dobrowolna reklama z nagrodą (kredyty).
class AdsController extends ChangeNotifier {
  AdsController(this._account);

  final AccountController _account;
  RewardedAd? _rewarded;
  InterstitialAd? _interstitial;
  int _aiRequests = 0;

  bool get _enabled => AppConfig.adsEnabled && !_account.isPro;
  bool get rewardedReady => _rewarded != null;

  void preload() {
    if (!_enabled) return;
    if (_rewarded == null) _loadRewarded();
    if (_interstitial == null && AdUnits.interstitial.isNotEmpty) _loadInterstitial();
  }

  void _loadRewarded() {
    RewardedAd.load(
      adUnitId: AdUnits.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          notifyListeners();
        },
        onAdFailedToLoad: (error) => debugPrint('rewarded failed: $error'),
      ),
    );
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: AdUnits.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (error) => debugPrint('interstitial failed: $error'),
      ),
    );
  }

  /// Pokazuje reklamę z nagrodą; true, gdy użytkownik ją obejrzał do końca.
  Future<bool> showRewarded() async {
    final ad = _rewarded;
    if (ad == null) {
      preload();
      return false;
    }
    _rewarded = null;
    notifyListeners();
    final done = Completer<bool>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!done.isCompleted) done.complete(earned);
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!done.isCompleted) done.complete(false);
        preload();
      },
    );
    await ad.show(onUserEarnedReward: (_, __) => earned = true);
    return done.future;
  }

  /// Wołane przy każdym zapytaniu do AI; co n-te pokazuje reklamę pełnoekranową.
  void onAiRequest() {
    if (!_enabled) return;
    _aiRequests++;
    final ad = _interstitial;
    if (ad == null || _aiRequests % AppConfig.interstitialEvery != 0) return;
    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        preload();
      },
    );
    ad.show();
  }
}

/// Baner na dole ekranu; znika w wersji Pro.
class BannerAdBox extends StatefulWidget {
  const BannerAdBox({super.key});

  @override
  State<BannerAdBox> createState() => _BannerAdBoxState();
}

class _BannerAdBoxState extends State<BannerAdBox> {
  BannerAd? _banner;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pro = context.watch<AccountController>().isPro;
    if (!AppConfig.adsEnabled || pro) {
      _banner?.dispose();
      _banner = null;
      _loaded = false;
    } else {
      _banner ??= BannerAd(
        size: AdSize.banner,
        adUnitId: AdUnits.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) => setState(() => _loaded = true),
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            debugPrint('banner failed: $error');
          },
        ),
      )..load();
    }
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    if (banner == null || !_loaded) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        height: banner.size.height.toDouble(),
        width: double.infinity,
        child: AdWidget(ad: banner),
      ),
    );
  }
}
