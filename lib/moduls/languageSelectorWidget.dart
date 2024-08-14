import 'dart:convert';

import 'package:rockidentifie/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectorWidget extends StatefulWidget {
  const LanguageSelectorWidget({super.key});

  @override
  State<LanguageSelectorWidget> createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends State<LanguageSelectorWidget> {
  // String _selectedLangShort = 'En';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(builder: (context, provider, _) {
      return _buildGradientCard(
        context,
        title: "Language ${provider.selectedLanguage}",
        icon: Icons.language,
        onTap: () => _showLanguageDialog(context),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 234, 66),
            Color.fromARGB(197, 0, 197, 251),
          ],
        ),
      );
    });
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
    final languageNames = Provider.of<LocaleProvider>(context, listen: false).supportedLanguages;
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
                    Provider.of<LocaleProvider>(context, listen: false).updateSelectedLanguage(langShort);

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
