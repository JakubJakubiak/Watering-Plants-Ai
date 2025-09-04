import 'dart:ui';

import 'package:plantsai/moduls/payment/subscribe_Button%20.dart';
import 'package:plantsai/utils/gaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plantsai/moduls/payment/paymentrevenuecat.dart';
import 'package:plantsai/utils/gaps.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_screen.dart';
import 'languageSelectorWidget.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({
    super.key,
    required this.onContinuePlaying,
    required this.isPro,
  });
  final bool isPro;
  final void Function(BuildContext dialogContext) onContinuePlaying;

  void _showFreeUI() {
    print("Showing Free UI");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Coins and subscriptions'),
          elevation: 0,
          backgroundColor: const Color(0xFF16213e),
        ),
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1a1a2e),
                  Color(0xFF16213e),
                  Color(0xFF0f3460),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    flex: 1,
                    child: Transform.scale(
                        scale: 0.8,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.asset(
                            'lib/logoicon/icon.png',
                            fit: BoxFit.cover,
                          ),
                        )),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          const LanguageSelectorWidget(),
                          const SizedBox(height: 16),
                          SizedBox(
                            child: SubscribeButton(
                              isPro: isPro,
                              onContinuePlaying: onContinuePlaying,
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ));
  }
}
