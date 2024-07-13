import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HistoryModule extends StatefulWidget {
  const HistoryModule({Key? key}) : super(key: key);

  @override
  State<HistoryModule> createState() => _HistoryModuleState();
}

class _HistoryModuleState extends State<HistoryModule> {
  List<Map<String, dynamic>> generatedHistory = [];

  @override
  void initState() {
    super.initState();
    _loadGeneratedHistory();
    // _addElementToList();
  }

  // Future<void> _addElementToList() async {
  //   print('/////generatedHistory///////${widget.imageData['mimeType']}/////');
  //   setState(() {
  //     generatedHistory.insert(0, {
  //       'base64Image': widget.imageData['base64Image'],
  //       'mimeType': widget.imageData['mimeType'],
  //       'description': widget.imageData['mimeType'],
  //     });
  //   });
  //   // await _saveGenerateHistory();
  // }

  Future<void> _loadGeneratedHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonStringList = prefs.getStringList('HistoryChat');
    if (jsonStringList != null) {
      setState(() {
        generatedHistory = jsonStringList.map((jsonString) {
          return jsonDecode(jsonString) as Map<String, dynamic>;
        }).toList();
      });
      print('/////generatedHistory/////_loadGeneratedHistory///$generatedHistory');
    }
  }

  Future<void> _saveGenerateHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonStringList = generatedHistory.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('HistoryChat', jsonStringList);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showFloatingMessage('Copied to clipboard');
  }

  void _shareText(String text) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      text,
      subject: 'Generated text',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  void _showFloatingMessage(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ).animate().fade().scale(
                alignment: Alignment.bottomCenter,
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                curve: Curves.easeOutBack,
              ),
        ),
      ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'History',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.blueAccent.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: generatedHistory.isEmpty
                  ? Center(
                      child: Text(
                        'No history',
                        style: TextStyle(color: Colors.white.withOpacity(0.6)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: generatedHistory.length,
                      itemBuilder: (context, index) {
                        String description = '${generatedHistory[index]['description']}';
                        String base64Image = generatedHistory[index]['base64Image'] ?? '';
                        Uint8List imageBytes = base64Image.isNotEmpty ? base64Decode(base64Image) : Uint8List(0);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                          child: GestureDetector(
                            onTap: () => _showActions("description"),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blueAccent.withOpacity(0.2),
                                    Colors.purpleAccent.withOpacity(0.2),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 0.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  if (imageBytes.isNotEmpty)
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(16.0),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: Image.memory(
                                            imageBytes,
                                            width: 100,
                                            height: 200,
                                          ),
                                        )),
                                  const SizedBox(height: 25),
                                  Text(
                                    description,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ).animate().fadeIn().slide(),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActions(String text) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionButton(
              icon: Icons.content_copy,
              label: 'Copy',
              onTap: () {
                _copyToClipboard(text);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            _ActionButton(
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: () {
                _shareText(text);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
