import 'dart:ui';

import 'package:PlantsAI/utils/gaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:PlantsAI/moduls/payment/paymentrevenuecat.dart';
import 'package:PlantsAI/utils/gaps.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_screen.dart';
import 'languageSelectorWidget.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({
    super.key,
    required this.score,
    required this.onContinuePlaying,
    required this.isPro,
  });
  final int score;
  final bool isPro;
  final void Function(BuildContext dialogContext) onContinuePlaying;

  void _showFreeUI() {
    print("Showing Free UI");
  }

  Future<void> _showPaywallIfNeeded(BuildContext context) async {
    final navigator = Navigator.of(context);
    Offerings offerings = await Purchases.getOfferings();
    final offering = offerings.current;

    if (offering == null) return;

    navigator.push(
      MaterialPageRoute(builder: (context) => PaywallView(offering: offering)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coins and subscriptions'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Transform.scale(
                  scale: 0.5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.asset(
                      'lib/logoicon/icon.png',
                      fit: BoxFit.cover,
                    ),
                  )),
              const Spacer(),
              Expanded(
                flex: isPro ? 2 : 3,
                child: const LanguageSelectorWidget(),
              ),
              const SizedBox(height: 16),
              isPro
                  ? Column()
                  : _buildGradientCard(
                      context,
                      title: isPro ? "Only For No Premiun" : 'Add Coins',
                      icon: Icons.monetization_on,
                      onTap: () => isPro ? null : _showContinuePlayingDialog(context),
                      gradient: LinearGradient(
                        colors: isPro
                            ? const [
                                Color.fromARGB(255, 62, 64, 68),
                                Color.fromARGB(197, 1, 14, 18),
                              ]
                            : const [
                                Color(0xFF005BEA),
                                Color.fromARGB(197, 0, 197, 251),
                              ],
                      ),
                    ),
              const SizedBox(height: 16),
              _buildGradientCard(
                context,
                title: isPro ? 'Unsubscribe' : 'Subscribe',
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
              const Spacer(),
            ],
          ),
        ),
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
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Continue playing?'),
          content: const Text('Do you want to watch a commercial to continue playing?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onContinuePlaying(context);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
