import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/analytics.dart';
import 'core/locale_controller.dart';
import 'core/theme.dart';
import 'core/theme_controller.dart';
import 'features/shell/home_shell.dart';
import 'languages/i10n/app_localizations.dart';

class PlantsApp extends StatelessWidget {
  const PlantsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>().locale;
    final themeMode = context.watch<ThemeController>().mode;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      navigatorObservers: Analytics.observers,
      home: const HomeShell(),
    );
  }
}

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
