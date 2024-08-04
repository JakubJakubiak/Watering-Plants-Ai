import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectorWidget extends StatefulWidget {
  const LanguageSelectorWidget({Key? key}) : super(key: key);

  @override
  _LanguageSelectorWidgetState createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends State<LanguageSelectorWidget> {
  String _selectedLanguage = 'English';
  // String _selectedLangShort = 'En';

  final Map<String, String> languageNames = {
    'en': 'English',
    'pl': 'Polski',
    'es': 'Español',
    'de': 'Deutsch',
    'fr': 'Français',
    'ar': 'العربية',
    'hi': 'हिन्दी',
    'ja': '日本語',
    'zh': '中文',
    'uk': 'Українська',
  };

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  void _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? selectedLanguageJson = prefs.getString('selectedLanguage');

    if (selectedLanguageJson != null) {
      Map<String, dynamic> selectedLanguage = jsonDecode(selectedLanguageJson);
      setState(() {
        _selectedLanguage = selectedLanguage['language'] ?? 'English';

        // _selectedLangShort = selectedLanguage['languageshort'] ?? 'en';
      });
    }
  }

  void _saveSelectedLanguage(String language, String languageshort) async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> selectedLanguage = {'language': language, 'languageshort': languageshort};
    String selectedLanguageJson = jsonEncode(selectedLanguage);
    await prefs.setString('selectedLanguage', selectedLanguageJson);
  }

  @override
  Widget build(BuildContext context) {
    return _buildGradientCard(
      context,
      title: "Language $_selectedLanguage",
      icon: Icons.language,
      onTap: () => _showLanguageDialog(context),
      gradient: const LinearGradient(
        colors: [
          Color.fromARGB(255, 0, 234, 66),
          Color.fromARGB(197, 0, 197, 251),
        ],
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

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select language'),
          content: SingleChildScrollView(
            child: ListBody(
              children: languageNames.keys.map((String langShort) {
                String? language = languageNames[langShort];
                return ListTile(
                  title: Text(language!),
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language;
                      // _selectedLangShort = langShort;
                    });
                    _saveSelectedLanguage(language, langShort);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
