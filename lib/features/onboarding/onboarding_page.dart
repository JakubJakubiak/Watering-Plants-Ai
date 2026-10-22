import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plantsai/app.dart';
import 'package:plantsai/core/theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  static const seenKey = 'hasSeenTutorial';

  static Future<bool> seen() async => (await SharedPreferences.getInstance()).getBool(seenKey) ?? false;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pages = PageController();
  int _index = 0;

  Future<void> _finish() async {
    await (await SharedPreferences.getInstance()).setBool(OnboardingPage.seenKey, true);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final slides = [
      (Icons.center_focus_strong_rounded, PlantColors.leaf, l10n.onboarding1Title, l10n.onboarding1Body),
      (Icons.water_drop_rounded, PlantColors.water, l10n.onboarding2Title, l10n.onboarding2Body),
      (Icons.forum_rounded, PlantColors.sun, l10n.onboarding3Title, l10n.onboarding3Body),
    ];
    final last = _index == slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _finish, child: Text(l10n.skip)),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final (icon, color, title, body) = slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.05)]),
                          ),
                          child: Icon(icon, size: 96, color: color),
                        )
                            .animate(key: ValueKey(i))
                            .scale(duration: 500.ms, curve: Curves.easeOutBack)
                            .then()
                            .shimmer(duration: 1200.ms),
                        const SizedBox(height: 40),
                        Text(title, style: theme.textTheme.headlineMedium, textAlign: TextAlign.center)
                            .animate(key: ValueKey('t$i'))
                            .fadeIn(delay: 150.ms)
                            .slideY(begin: 0.2),
                        const SizedBox(height: 12),
                        Text(
                          body,
                          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ).animate(key: ValueKey('b$i')).fadeIn(delay: 250.ms),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < slides.length; i++)
                  AnimatedContainer(
                    duration: 250.ms,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: last ? _finish : () => _pages.nextPage(duration: 350.ms, curve: Curves.easeOutCubic),
                  child: Text(last ? l10n.getStarted : l10n.next),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
