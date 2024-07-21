import 'package:PlantsAI/utils/gaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:PlantsAI/moduls/payment/paymentrevenuecat.dart';
import 'package:PlantsAI/utils/gaps.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
// import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_screen.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({
    super.key,
    required this.score,
    // required this.onPlayAgain,
    required this.onContinuePlaying,
    required this.isPro,
    // required this.limitAdmob
  });
  final int score;
  final bool isPro;
  // final int limitAdmob;
  // final VoidCallback onPlayAgain;
  final void Function(BuildContext dialogContext) onContinuePlaying;

  // void _showPremiumUI() {
  //   print("Showing Premium UI");
  // }

  // void _showFreeUI() {
  //   print("Showing Free UI");
  // }

  // Future<void> _checkPremiumStatus() async {
  //   try {
  //     User? user = FirebaseAuth.instance.currentUser;
  //     if (user != null) {
  //       IdTokenResult idTokenResult = await user.getIdTokenResult();
  //       if (idTokenResult.claims != null && idTokenResult.claims!['activeEntitlements'] != null && idTokenResult.claims!['activeEntitlements'].contains("Subs")) {
  //         // Show premium UI.
  //         _showPremiumUI();
  //       } else {
  //         // Show regular user UI.
  //         _showFreeUI();
  //       }
  //     }
  //   } catch (error) {
  //     print(error);
  //   } finally {}
  // }

  Future<void> _showPaywallIfNeeded(BuildContext context) async {
    // check if user is pro
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
        title: const Text('Coin Topping Up'),
      ),
      body: FractionallySizedBox(
        heightFactor: 0.7,
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20),
          child: Column(
            children: [
              const Spacer(),
              Text(
                isPro ? 'You already have subscriptions' : 'Buy a subcrubion tailored to you',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: Sizes.p48,
                      child: FilledButton(
                        onPressed: () async {
                          final outerContext = context;
                          await showDialog<AlertDialog>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Continue Playing?'),
                                content: const Text(
                                  'Watch an ad to continue playing?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('No'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      onContinuePlaying(outerContext);
                                    },
                                    child: const Text('Yes'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueAccent.withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.currency_exchange_outlined,
                              size: Sizes.p48,
                            ),
                            Text(
                              'Add Coins',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  gapW16,
                  SizedBox(
                      height: Sizes.p48,
                      child: FilledButton(
                        onPressed: () async {
                          try {
                            // CustomerInfo customerInfo = await Purchases.getCustomerInfo();

                            if (isPro) {
                              // launchUrl(Uri.parse(customerInfo.managementURL!));
                            } else {
                              _showPaywallIfNeeded(context);
                              // final navigator = Navigator.of(context);
                              // Offerings offerings = await Purchases.getOfferings();
                              // final offering = offerings.current;

                              // if (offering == null) return;

                              // navigator.push(
                              //   MaterialPageRoute(builder: (context) => PaywallView(offering: offering)),
                              // );
                            }
                          } catch (e) {
                            print('Error downloading or displaying an offer: ${e.toString()}');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueAccent.withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          // padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          isPro ? 'Cancel' : 'Subscribe',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                ],
              ),
              gapH16,
              SizedBox(
                height: Sizes.p48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.replay,
                        size: 42,
                      ),
                      gapW16,
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
