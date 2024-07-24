import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Step {
  final String image;
  final String titlScrin;
  final String description;

  Step({required this.image, required this.titlScrin, required this.description});
}

class TutorialScreen extends StatefulWidget {
  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int currentStep = 0;
  List<Step> steps = [
    Step(image: 'assets/step1.png', titlScrin: 'Step 1 description', description: "ff"),
    Step(image: 'assets/step2.png', titlScrin: 'Step 2 description', description: "ff"),
    Step(image: 'assets/step3.png', titlScrin: 'Step 3 description', description: "ff"),
  ];

  void nextStep() {
    setState(() {
      if (currentStep < steps.length - 1) {
        currentStep++;
      } else {
        Navigator.of(context).pop();
        _loadTutorialStatusFromStorage();
      }
    });
  }

  Future<bool> _loadTutorialStatusFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenTutorial') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            color: Colors.black.withOpacity(0.5),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(steps.length, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.0),
                        width: 12.0,
                        height: 12.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentStep == index ? Colors.white : Colors.grey,
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      steps[currentStep].titlScrin,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      steps[currentStep].description,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    steps[currentStep].image,
                    height: 200,
                    width: 200,
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: nextStep,
                    child: Text(currentStep < steps.length - 1 ? 'Continue' : 'Complete'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
