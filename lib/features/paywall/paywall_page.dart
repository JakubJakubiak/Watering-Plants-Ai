import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:plantsai/app.dart';
import 'package:plantsai/core/analytics.dart';
import 'package:plantsai/core/config.dart';
import 'package:plantsai/core/theme.dart';

/// Otwiera paywall z bieżącą ofertą RevenueCat. Zwraca true po zakupie.
Future<bool> showPaywall(BuildContext context, {required String source}) async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final unavailable = context.l10n.paywallUnavailable;
  Offering? offering;
  try {
    offering = (await Purchases.getOfferings()).current;
  } catch (e) {
    debugPrint('offerings failed: $e');
  }
  if (offering == null || offering.availablePackages.isEmpty) {
    messenger.showSnackBar(SnackBar(content: Text(unavailable)));
    return false;
  }
  Analytics.paywallShown(source);
  final bought = await navigator.push<bool>(
    MaterialPageRoute(fullscreenDialog: true, builder: (_) => PaywallPage(offering: offering!)),
  );
  return bought ?? false;
}

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key, required this.offering});

  final Offering offering;

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  late Package _selected = _initialPackage();
  bool _busy = false;

  List<Package> get _packages => [
        if (widget.offering.annual != null) widget.offering.annual!,
        if (widget.offering.monthly != null) widget.offering.monthly!,
        if (widget.offering.weekly != null) widget.offering.weekly!,
        ...widget.offering.availablePackages.where(
          (p) => p.packageType != PackageType.annual && p.packageType != PackageType.monthly && p.packageType != PackageType.weekly,
        ),
      ];

  Package _initialPackage() => widget.offering.annual ?? widget.offering.availablePackages.first;

  int? get _annualSavings {
    final weekly = widget.offering.weekly?.storeProduct.price;
    final annual = widget.offering.annual?.storeProduct.price;
    if (weekly == null || annual == null || weekly <= 0) return null;
    final percent = ((weekly * 52 - annual) / (weekly * 52) * 100).round();
    return percent > 0 ? percent : null;
  }

  Future<void> _purchase() async {
    setState(() => _busy = true);
    final navigator = Navigator.of(context);
    try {
      final result = await Purchases.purchase(PurchaseParams.package(_selected));
      if (result.customerInfo.entitlements.all[AppConfig.proEntitlement]?.isActive ?? false) {
        Analytics.purchaseCompleted(_selected.storeProduct.identifier);
        navigator.pop(true);
        return;
      }
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) != PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('purchase failed: $e');
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _restore() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final restored = context.l10n.purchasesRestored;
    try {
      final info = await Purchases.restorePurchases();
      if (info.entitlements.all[AppConfig.proEntitlement]?.isActive ?? false) {
        messenger.showSnackBar(SnackBar(content: Text(restored)));
        navigator.pop(true);
      }
    } catch (e) {
      debugPrint('restore failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final benefits = [
      (Icons.center_focus_strong_rounded, l10n.proBenefitScans),
      (Icons.forum_rounded, l10n.proBenefitChat),
      (Icons.water_drop_rounded, l10n.proBenefitGarden),
      (Icons.block_rounded, l10n.proBenefitNoAds),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [scheme.primaryContainer, scheme.surface, scheme.surface],
                  stops: const [0, 0.45, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      Center(
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [BoxShadow(color: scheme.primary.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))],
                          ),
                          child: Icon(Icons.eco_rounded, size: 56, color: scheme.onPrimary),
                        ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(end: 1.06, duration: 1400.ms, curve: Curves.easeInOut),
                      ),
                      const SizedBox(height: 20),
                      Text(l10n.paywallTitle, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Text(
                        l10n.paywallSubtitle,
                        style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      for (final (i, (icon, label)) in benefits.indexed)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: scheme.primary.withValues(alpha: 0.12),
                                child: Icon(icon, size: 20, color: scheme.primary),
                              ),
                              const SizedBox(width: 14),
                              Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
                            ],
                          ),
                        ).animate().fadeIn(delay: (80 * i).ms).slideX(begin: 0.1),
                      const SizedBox(height: 24),
                      for (final package in _packages)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PackageTile(
                            package: package,
                            selected: package == _selected,
                            savings: package.packageType == PackageType.annual ? _annualSavings : null,
                            onTap: () => setState(() => _selected = package),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _busy ? null : _purchase,
                      child: _busy
                          ? const SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                          : Text(l10n.continueLabel),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(onPressed: _restore, child: Text(l10n.restorePurchases)),
                    TextButton(onPressed: () => launchUrlString(AppConfig.privacyUrl), child: Text(l10n.privacyPolicy)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PackageTile extends StatelessWidget {
  const _PackageTile({required this.package, required this.selected, required this.onTap, this.savings});

  final Package package;
  final bool selected;
  final int? savings;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final product = package.storeProduct;
    final trial = product.introductoryPrice?.price == 0;

    final (title, price) = switch (package.packageType) {
      PackageType.annual => (l10n.yearly, l10n.perYear(product.priceString)),
      PackageType.monthly => (l10n.monthly, l10n.perMonth(product.priceString)),
      PackageType.weekly => (l10n.weekly, l10n.perWeek(product.priceString)),
      _ => (product.title, product.priceString),
    };

    return AnimatedContainer(
      duration: 200.ms,
      decoration: BoxDecoration(
        color: selected ? scheme.primaryContainer.withValues(alpha: 0.6) : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  color: selected ? scheme.primary : scheme.outline),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(price, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                    if (trial)
                      Text(l10n.freeTrial,
                          style: theme.textTheme.labelMedium?.copyWith(color: scheme.primary, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              if (savings != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: PlantColors.sun, borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    l10n.savePercent(savings!),
                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.black, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
