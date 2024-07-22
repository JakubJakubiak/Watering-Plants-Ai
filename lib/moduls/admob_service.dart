import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return 'ca-app-pub-3940256099942544/2934735716'; // test ad ID
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-5915784054696948/6052949323';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-5915784054696948/9426559499';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) return 'ca-app-pub-3940256099942544/5354046379';
    if (Platform.isAndroid) {
      return 'ca-app-pub-5915784054696948/8104397590';
    } else if (Platform.isIOS) {
      return '';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitID {
    if (kDebugMode) return 'ca-app-pub-3940256099942544/5224354917';
    if (Platform.isAndroid) {
      return 'ca-app-pub-5915784054696948/8104397590';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-5915784054696948/6894892781';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) => debugPrint('Ad loaded'),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      debugPrint('Ad failed to load: $error');
    },
    onAdOpened: (ad) => debugPrint('Ad opened'),
    onAdClosed: (ad) => debugPrint('Ad closed'),
  );
}
