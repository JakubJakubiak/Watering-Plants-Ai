import 'package:rockidentifie/moduls/payment/paymentrevenuecat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SubscribeButton extends StatefulWidget {
  final bool isPro;
  final void Function(BuildContext dialogContext) onContinuePlaying;

  const SubscribeButton({
    Key? key,
    required this.onContinuePlaying,
    this.isPro = false,
  }) : super(key: key);

  @override
  _SubscribeButtonState createState() => _SubscribeButtonState();
}

class _SubscribeButtonState extends State<SubscribeButton> {
  bool get isPro => widget.isPro;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        isPro
            ? const Column()
            : _buildGradientCard(
                context,
                title: AppLocalizations.of(context).addCoins,
                icon: Icons.monetization_on,
                onTap: () => isPro ? null : _showContinuePlayingDialog(context),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF005BEA),
                    Color.fromARGB(197, 0, 197, 251),
                  ],
                ),
              ),
        const SizedBox(height: 16),
        _buildGradientCard(
          context,
          title: isPro ? AppLocalizations.of(context).unsubscribe : AppLocalizations.of(context).subscribe,
          icon: Icons.star,
          onTap: () async {
            try {
              if (isPro) {
                CustomerInfo customerInfo = await Purchases.getCustomerInfo();
                launchUrl(Uri.parse(customerInfo.managementURL!));
              } else {
                _showPaywallIfNeeded(context);
              }
            } catch (e) {
              print('Error downloading or displaying an offer: ${e.toString()}');
            }
          },
          gradient: LinearGradient(
            colors: isPro
                ? const [
                    Colors.red,
                    Colors.redAccent,
                  ]
                : const [
                    Color(0xFFFF5E3A),
                    Color(0xFFFF2A68),
                  ],
          ),
        ),
      ],
    );
  }

  Future<void> _showPaywallIfNeeded(BuildContext context) async {
    final navigator = Navigator.of(context);
    Offerings offerings = await Purchases.getOfferings();
    final offering = offerings.current;

    if (offering == null) return;

    navigator.push(
      MaterialPageRoute(
        builder: (context) => PaywallView(offering: offering, loadingX: true),
      ),
    );
  }

  Widget _buildGradientCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 36),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  void _showContinuePlayingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Continue playing?'),
          content: const Text('Do you want to watch a commercial to continue playing?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                widget.onContinuePlaying(dialogContext);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
