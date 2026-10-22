import 'package:flutter/material.dart';
import 'package:plantsai/core/theme.dart';
import 'package:plantsai/languages/i10n/app_localizations.dart';

/// Tłumaczy wartości enum z odpowiedzi AI na etykiety i ikony.
extension CareLabels on AppLocalizations {
  String lightLabel(String value) => switch (value) {
        'low' => lightLow,
        'medium' => lightMedium,
        'bright_indirect' => lightBrightIndirect,
        'full_sun' => lightFullSun,
        _ => value,
      };

  String levelLabel(String value) => switch (value) {
        'low' => levelLow,
        'medium' => levelMedium,
        'high' => levelHigh,
        _ => value,
      };

  String difficultyLabel(String value) => switch (value) {
        'easy' => difficultyEasy,
        'medium' => difficultyMedium,
        'hard' => difficultyHard,
        _ => value,
      };

  String healthLabel(String value) => switch (value) {
        'healthy' => healthHealthy,
        'needs_attention' => healthNeedsAttention,
        'sick' => healthSick,
        _ => healthUnknown,
      };

  /// "Podlej za 3 dni" / "Spóźnione o 2 dni".
  String wateringStatus(int daysLeft) => daysLeft < 0 ? overdue(-daysLeft) : waterIn(daysLeft);
}

Color healthColor(String value) => switch (value) {
      'healthy' => PlantColors.leaf,
      'needs_attention' => PlantColors.sun,
      'sick' => PlantColors.danger,
      _ => Colors.grey,
    };

IconData lightIcon(String value) => switch (value) {
      'low' => Icons.cloud_rounded,
      'medium' => Icons.wb_cloudy_rounded,
      'full_sun' => Icons.wb_sunny_rounded,
      _ => Icons.light_mode_rounded,
    };
