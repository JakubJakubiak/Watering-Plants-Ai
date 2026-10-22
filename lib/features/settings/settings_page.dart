import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:plantsai/app.dart';
import 'package:plantsai/core/account_controller.dart';
import 'package:plantsai/core/config.dart';
import 'package:plantsai/core/locale_controller.dart';
import 'package:plantsai/core/theme.dart';
import 'package:plantsai/core/theme_controller.dart';
import 'package:plantsai/features/paywall/paywall_page.dart';
import 'package:plantsai/widgets/credits.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.watch<LocaleController>();
    final theme = context.watch<ThemeController>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(title: Text(l10n.navSettings)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList.list(
              children: [
                const _AccountCard(),
                const SizedBox(height: 24),
                _Group(
                  title: l10n.appSection,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.translate_rounded),
                      title: Text(l10n.language),
                      subtitle: Text(locale.languageName),
                      onTap: () => _pickLanguage(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: Text(l10n.theme),
                      trailing: SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(value: ThemeMode.system, icon: const Icon(Icons.brightness_auto_rounded), tooltip: l10n.themeSystem),
                          ButtonSegment(value: ThemeMode.light, icon: const Icon(Icons.light_mode_rounded), tooltip: l10n.themeLight),
                          ButtonSegment(value: ThemeMode.dark, icon: const Icon(Icons.dark_mode_rounded), tooltip: l10n.themeDark),
                        ],
                        selected: {theme.mode},
                        onSelectionChanged: (s) => theme.select(s.first),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.star_outline_rounded),
                      title: Text(l10n.rateApp),
                      onTap: () => InAppReview.instance.openStoreListing(),
                    ),
                    ListTile(
                      leading: const Icon(Icons.shield_outlined),
                      title: Text(l10n.privacyPolicy),
                      onTap: () => launchUrlString(AppConfig.privacyUrl),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    l10n.version('2.0.0'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _pickLanguage(BuildContext context) {
    final controller = context.read<LocaleController>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final entry in LocaleController.languageNames.entries)
                ListTile(
                  title: Text(entry.value),
                  trailing: controller.locale.languageCode == entry.key ? const Icon(Icons.check_rounded) : null,
                  onTap: () {
                    controller.select(entry.key);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final account = context.watch<AccountController>();
    final pro = account.isPro;

    return Card(
      color: pro ? PlantColors.sun.withValues(alpha: 0.15) : theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(pro ? Icons.workspace_premium_rounded : Icons.bolt_rounded,
                    size: 32, color: pro ? PlantColors.sun : theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pro ? l10n.proActive : l10n.credits(account.credits), style: theme.textTheme.titleLarge),
                      Text(
                        pro ? l10n.proSubtitle : l10n.creditsRenew(account.account.dailyFreeCredits),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (pro)
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final info = await Purchases.getCustomerInfo();
                    final url = info.managementURL;
                    if (url != null) await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  } catch (e) {
                    debugPrint('management url failed: $e');
                  }
                },
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(l10n.manageSubscription),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => showPaywall(context, source: 'settings'),
                      icon: const Icon(Icons.workspace_premium_rounded),
                      label: Text(l10n.goPro),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => showCreditsSheet(context, source: 'settings'),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l10n.addCoins, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              ),
            if (account.error != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.wifi_off_rounded, size: 18, color: theme.colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.offline, style: TextStyle(color: theme.colorScheme.error))),
                  TextButton(onPressed: account.connect, child: Text(l10n.reconnect)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(title, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }
}
