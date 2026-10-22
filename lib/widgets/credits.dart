import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plantsai/app.dart';
import 'package:plantsai/core/account_controller.dart';
import 'package:plantsai/core/ads.dart';
import 'package:plantsai/core/analytics.dart';
import 'package:plantsai/core/theme.dart';
import 'package:plantsai/features/paywall/paywall_page.dart';

/// Licznik kredytów / znaczek Pro w pasku aplikacji.
class CreditsChip extends StatelessWidget {
  const CreditsChip({super.key});

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountController>();
    final scheme = Theme.of(context).colorScheme;
    if (account.isPro) {
      return Chip(
        avatar: const Icon(Icons.workspace_premium_rounded, color: PlantColors.sun, size: 18),
        label: const Text('Pro'),
        backgroundColor: PlantColors.sun.withValues(alpha: 0.15),
      );
    }
    return ActionChip(
      avatar: Icon(Icons.bolt_rounded, color: scheme.primary, size: 18),
      label: Text(context.l10n.credits(account.credits)),
      onPressed: () => showCreditsSheet(context, source: 'chip'),
    );
  }
}

/// Arkusz z opcjami, gdy brakuje kredytów: reklama z nagrodą albo Pro.
Future<void> showCreditsSheet(BuildContext context, {required String source}) {
  final account = context.read<AccountController>();
  if (account.credits <= 0) Analytics.outOfCredits(source);
  return showModalBottomSheet<void>(
    context: context,
    builder: (_) => const _CreditsSheet(),
  );
}

class _CreditsSheet extends StatefulWidget {
  const _CreditsSheet();

  @override
  State<_CreditsSheet> createState() => _CreditsSheetState();
}

class _CreditsSheetState extends State<_CreditsSheet> {
  bool _busy = false;

  Future<void> _watchAd() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final account = context.read<AccountController>();
    final ads = context.read<AdsController>();
    if (account.account.rewardsLeft <= 0) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.rewardLimit)));
      return;
    }
    if (!ads.rewardedReady) {
      ads.preload();
      messenger.showSnackBar(SnackBar(content: Text(l10n.adNotReady)));
      return;
    }
    setState(() => _busy = true);
    final earned = await ads.showRewarded();
    if (earned && await account.claimReward()) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.creditsAdded(account.account.rewardCredits))));
      if (mounted) Navigator.of(context).pop();
    } else if (mounted) {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final account = context.watch<AccountController>();
    final info = account.account;
    final empty = account.credits <= 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(empty ? Icons.battery_alert_rounded : Icons.bolt_rounded, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              empty ? l10n.outOfCreditsTitle : l10n.credits(account.credits),
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.outOfCreditsBody(info.dailyFreeCredits, info.rewardCredits),
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                showPaywall(context, source: 'credits_sheet');
              },
              icon: const Icon(Icons.workspace_premium_rounded),
              label: Text(l10n.goPro),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _busy ? null : _watchAd,
              icon: _busy
                  ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.play_circle_outline_rounded),
              label: Text(l10n.watchAd(info.rewardCredits)),
            ),
          ],
        ),
      ),
    );
  }
}
