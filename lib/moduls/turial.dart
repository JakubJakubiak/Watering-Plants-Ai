import 'package:flutter/material.dart';

class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final List<TutorialStep> steps = [
    TutorialStep(
      image: 'assets/step1.png',
      description: 'Witaj w naszej aplikacji! Tutaj możesz przeglądać różne produkty.',
    ),
    TutorialStep(
      image: 'assets/step2.png',
      description: 'Kliknij na produkt, aby zobaczyć więcej szczegółów.',
    ),
    TutorialStep(
      image: 'assets/step3.png',
      description: 'Możesz dodawać produkty do koszyka i dokonywać zakupów.',
    ),
  ];

  int currentStep = 0;

  void nextStep() {
    if (currentStep < steps.length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              steps[currentStep].image,
              height: 200,
              width: 200,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                steps[currentStep].description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: nextStep,
              child: Text(currentStep < steps.length - 1 ? 'Dalej' : 'Zakończ'),
            ),
          ],
        ),
      ),
    );
  }
}

class TutorialStep {
  final String image;
  final String description;

  TutorialStep({required this.image, required this.description});
}
