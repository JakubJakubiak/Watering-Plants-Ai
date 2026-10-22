import 'dart:async';

import 'package:ai_hub_client/ai_hub_client.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'analytics.dart';
import 'config.dart';

/// Token sesji ai-hub w SharedPreferences.
class PrefsTokenStore implements AiHubTokenStore {
  static const _key = 'aiHubToken';

  @override
  Future<String?> read() async => (await SharedPreferences.getInstance()).getString(_key);

  @override
  Future<void> write(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    token == null ? await prefs.remove(_key) : await prefs.setString(_key, token);
  }
}

/// Stan konta: kredyty z ai-hub + subskrypcja z RevenueCat.
/// Serwer i tak egzekwuje limity; tu trzymamy to, co pokazuje UI.
class AccountController extends ChangeNotifier {
  AccountController(this.hub);

  final AiHubClient hub;
  StreamSubscription<AiHubAccount>? _subscription;

  AiHubAccount _account = AiHubAccount.empty;
  bool _storePro = false;
  bool _connecting = false;
  String? _error;

  AiHubAccount get account => _account;
  int get credits => _account.credits;

  /// Pro według serwera albo według sklepu (zanim webhook dotrze do serwera).
  bool get isPro => _account.isPro || _storePro;
  bool get canChat => isPro || _account.credits > 0;
  bool get connecting => _connecting;
  String? get error => _error;

  Future<void> start() async {
    _subscription = hub.accountChanges.listen((account) {
      _account = account;
      notifyListeners();
    });
    await Future.wait([connect(), _startPurchases()]);
  }

  Future<void> connect() async {
    _connecting = true;
    notifyListeners();
    try {
      await hub.connect();
      _error = null;
    } on AiHubException catch (e) {
      _error = e.code;
      debugPrint('ai-hub connect failed: $e');
    } finally {
      _connecting = false;
      notifyListeners();
    }
  }

  /// Dolicza kredyty po obejrzanej reklamie. Zwraca false przy dziennym limicie.
  Future<bool> claimReward() async {
    try {
      await hub.claimReward();
      Analytics.rewardClaimed();
      return true;
    } on AiHubException catch (e) {
      debugPrint('reward failed: $e');
      return false;
    }
  }

  /// Gdy serwer odrzucił zapytanie, a błąd niesie aktualny stan konta.
  void applyFromError(AiHubException e) {
    if (e.account != null) {
      _account = e.account!;
      notifyListeners();
    }
  }

  Future<void> _startPurchases() async {
    try {
      // app_user_id w RevenueCat = deviceId (tak jak wcześniej uid z Firebase),
      // więc istniejące subskrypcje zostają przy użytkownikach.
      await Purchases.logIn(hub.deviceId);
      _onCustomerInfo(await Purchases.getCustomerInfo());
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfo);
    } catch (e) {
      debugPrint('RevenueCat unavailable: $e');
    }
  }

  void _onCustomerInfo(CustomerInfo info) {
    final pro = info.entitlements.all[AppConfig.proEntitlement]?.isActive ?? false;
    if (pro == _storePro) return;
    _storePro = pro;
    Analytics.setUserProperty('is_pro', pro ? 'true' : 'false');
    notifyListeners();
    if (pro && !_account.isPro) {
      hub.refreshSubscription().catchError((Object e) {
        debugPrint('subscription refresh failed: $e');
        return _account;
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
