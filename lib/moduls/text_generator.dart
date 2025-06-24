import 'dart:convert';
import 'package:plantsai/moduls/modern_full_width_button.dart';
import 'package:plantsai/utils/gaps.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

import '../main.dart';

class Textgenerator extends StatefulWidget {
  final String currentCategory;
  final Map<String, dynamic> displayedText;
  final ScrollController scrollController;
  final int counter;

  const Textgenerator({
    super.key,
    required this.displayedText,
    required this.currentCategory,
    required this.scrollController,
    required this.counter,
  });

  @override
  State<Textgenerator> createState() => _TextgeneratorState();
}

class Message {
  String user;
  String text;

  Message({required this.user, required this.text});
}

class _TextgeneratorState extends State<Textgenerator> {
  final timeMilliseconds = const Duration(milliseconds: 250);
  bool isLoadingMessage = false;
  String generatedText = "";
  String promptText = "";

  int get counter => widget.counter;
  List<Map<String, dynamic>> generatedHistory = [];

  get currentCategory => widget.currentCategory;
  get message => widget.displayedText["text"];

  @override
  void initState() {
    super.initState();
    _loadGeneratedHistory();
  }

  Future<String> textMessage(message) async {
    setState(() {
      isLoadingMessage = true;
    });
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('textMobileAnaliz');
      final response = await callable.call(<String, dynamic>{
        'promptTextUsers': message,
        'promptTag': currentCategory,
      });

      if (response.data != null && response.data['descriptionText'] != null) {
        final description = response.data['descriptionText'] as String;
        setState(() {
          generatedText = description;
          generatedHistory.insert(0, {
            'base64Image': "",
            'description': description,
          });
          isLoadingMessage = false;
        });
        await _saveGenerateHistory();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });

      return generatedText;
    } catch (error) {
      print(error);
    }
    return "";
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text copied to clipboard'),
        duration: Duration(milliseconds: 200),
      ),
    );
  }

  void shareText(String text) async {
    await Share.share(
      text,
      subject: generatedText,
    );
  }

  Future<void> _loadGeneratedHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonStringList = prefs.getStringList('generatedHistory');
    if (jsonStringList != null) {
      setState(() {
        generatedHistory = jsonStringList.map((jsonString) {
          return jsonDecode(jsonString) as Map<String, dynamic>;
        }).toList();
      });
    }
  }

  Future<void> _saveGenerateHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonStringList = generatedHistory.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('generatedHistory', jsonStringList);
  }

  // Widget _buildAnalyzeButton() {
  //   return ModernFullWidthButton(
  //     onPressed: (counter > 0) ? imagesAnaliz : null,
  //     isLoading: isLoadingMessage,
  //     text: 'Analyze Image',
  //   ).animate().fadeIn(delay: timeMilliseconds);
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ModernFullWidthButton(
          onPressed: (counter > 0)
              ? () async {
                  final text = await textMessage(message);

                  setState(() {
                    isLoadingMessage = false;
                    generatedText = text;
                  });
                }
              : null,
          isLoading: false,
          text: 'Generate',
        ),
        gapH16,
        // gapH16,
        isLoadingMessage == true
            ? const CircularProgressIndicator()
            : generatedText == ""
                ? const Column()
                : Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.content_copy_outlined,
                                onPressed: () => copyToClipboard(generatedText),
                              ),
                            ),
                            gapW16,
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.share_outlined,
                                onPressed: () => shareText(generatedText),
                              ),
                            ),
                          ],
                        ),
                      ),
                      gapH16,
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blueAccent.withOpacity(0.1),
                              Colors.purpleAccent.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          generatedText,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
      ],
    );
  }
}

Widget _buildActionButton({required IconData icon, required VoidCallback onPressed}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.blueAccent.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
    child: Icon(icon),
  );
}
