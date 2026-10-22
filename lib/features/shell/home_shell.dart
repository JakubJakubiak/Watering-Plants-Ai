import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plantsai/app.dart';
import 'package:plantsai/core/account_controller.dart';
import 'package:plantsai/core/ads.dart';
import 'package:plantsai/data/chat_repository.dart';
import 'package:plantsai/data/plant_care.dart';
import 'package:plantsai/database/chat_database.dart';
import 'package:plantsai/features/garden/garden_page.dart';
import 'package:plantsai/features/history/chats_page.dart';
import 'package:plantsai/features/onboarding/onboarding_page.dart';
import 'package:plantsai/features/paywall/paywall_page.dart';
import 'package:plantsai/features/scan/scan_page.dart';
import 'package:plantsai/features/settings/settings_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [ScanPage(), GardenPage(), ChatsPage(), SettingsPage()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onLaunch());
  }

  /// Pierwsze uruchomienie: onboarding. Kolejne: paywall dla wersji darmowej,
  /// najwyżej raz dziennie.
  Future<void> _onLaunch() async {
    if (!await OnboardingPage.seen()) {
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const OnboardingPage()));
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (prefs.getString('paywallShownDay') == today) return;
    // Daj RevenueCat chwilę na odczyt subskrypcji, żeby nie pokazać paywalla płacącym.
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted || context.read<AccountController>().isPro) return;
    await prefs.setString('paywallShownDay', today);
    if (mounted) showPaywall(context, source: 'launch');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdBox(),
          StreamBuilder<List<Chat>>(
            stream: context.read<ChatRepository>().watchGarden(),
            builder: (context, snapshot) {
              final due = (snapshot.data ?? const <Chat>[]).where((p) => p.needsWater).length;
              return NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() => _index = i),
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.center_focus_weak_rounded),
                    selectedIcon: const Icon(Icons.center_focus_strong_rounded),
                    label: l10n.navScan,
                  ),
                  NavigationDestination(
                    icon: Badge(isLabelVisible: due > 0, label: Text('$due'), child: const Icon(Icons.yard_outlined)),
                    selectedIcon: Badge(isLabelVisible: due > 0, label: Text('$due'), child: const Icon(Icons.yard_rounded)),
                    label: l10n.navGarden,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    selectedIcon: const Icon(Icons.chat_bubble_rounded),
                    label: l10n.navChats,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings_rounded),
                    label: l10n.navSettings,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
