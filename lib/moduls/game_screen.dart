import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rockidentifie/main.dart';
import 'package:rockidentifie/moduls/text_generator.dart';
import 'package:cloud_functions/cloud_functions.dart';

class GameScreen extends StatefulWidget {
  final int counter;
  const GameScreen({super.key, required this.counter});

  @override
  State<GameScreen> createState() => _GameScreenState();

  static void updateCounter() {}
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  int get counter => widget.counter;
  // dart fix --apply
  //  dart format .

  List<Map<String, dynamic>> gameImages = [];
  Animation<double>? animation;
  dynamic sizeW;
  dynamic sizeH;

  final messageController = TextEditingController();

  List<Map<String, dynamic>> items = [];

  bool isLoadingMessage = false;
  bool renderactive = true;

  TextEditingController searchController = TextEditingController();
  String _currentCategory = 'Short';

  final _scrollController = ScrollController();

  Map<String, dynamic> displayedText = {'': ""};
  String generatedText = "";

  String serverLink = "";
  double textLength = 0;
  // int renderedTextLength = 0;
  bool isEnabled = false;
  bool rewardedAdTrue = false;

  @override
  void initState() {
    super.initState();
    _loadResult();
  }

  Future<int> _loadResult() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int result = prefs.getInt('counter') ?? 10;
    updateCounter(result);

    return result;
  }

  void updateCounter(counter) async {
    Provider.of<CounterModel>(context, listen: false).updateCounter(counter);
  }

  void onChipSelected(String currentCategory) {
    HapticFeedback.mediumImpact();

    setState(() {
      _currentCategory = currentCategory;
    });
  }

  void testyFuccionTest() async {
    final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('functionName');
    final results = await callable.call();
    print(results);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        controller: _scrollController,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Write a short description to elaborate',
                filled: true,
                fillColor: Colors.grey[800],
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 26.0,
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
              ),
              maxLength: 150,
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  displayedText = {"text": value};
                });
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(
                    value: 'Short',
                    label: Text('Short'),
                  ),
                  ButtonSegment<String>(
                    value: 'Medium',
                    label: Text('Medium'),
                  ),
                  ButtonSegment<String>(
                    value: 'Long',
                    label: Text('Long'),
                  ),
                ],
                selected: <String>{_currentCategory},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _currentCategory = newSelection.first;
                  });
                  onChipSelected(_currentCategory);
                },
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.blueAccent;
                    }
                    return Colors.blueAccent.withOpacity(0.3);
                  }),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  side: WidgetStateProperty.all(
                    const BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Textgenerator(
              displayedText: displayedText,
              currentCategory: _currentCategory,
              scrollController: _scrollController,
              counter: counter,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: generatedText));
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    duration: Duration(milliseconds: 100),
                    content: Text('Text copied to clipboard'),
                  ),
                );
              },
              child: Text(
                generatedText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
