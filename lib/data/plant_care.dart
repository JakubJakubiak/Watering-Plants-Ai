import 'package:plantsai/database/chat_database.dart';

/// Profil opieki zwracany przez AI (pole `care` w schemacie plantsai na serwerze).
class PlantCare {
  const PlantCare({
    required this.species,
    required this.wateringDays,
    required this.light,
    required this.humidity,
    required this.temperature,
    required this.difficulty,
    required this.health,
    required this.healthNote,
    required this.toxicToPets,
  });

  final String species;
  final int wateringDays;
  final String light;
  final String humidity;
  final String temperature;
  final String difficulty;
  final String health;
  final String healthNote;
  final bool toxicToPets;

  static PlantCare? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    return PlantCare(
      species: map['species'] as String? ?? '',
      wateringDays: ((map['wateringDays'] as num?)?.toInt() ?? 7).clamp(1, 60),
      light: map['light'] as String? ?? '',
      humidity: map['humidity'] as String? ?? '',
      temperature: map['temperature'] as String? ?? '',
      difficulty: map['difficulty'] as String? ?? '',
      health: map['health'] as String? ?? 'unknown',
      healthNote: map['healthNote'] as String? ?? '',
      toxicToPets: map['toxicToPets'] == true,
    );
  }
}

/// Odpowiedź modelu dla plantsai: `{ name, response, quickQuestions, care }`.
class PlantReply {
  const PlantReply({required this.name, required this.response, required this.quickQuestions, this.careMap});

  final String name;
  final String response;
  final List<String> quickQuestions;
  final Map<String, dynamic>? careMap;

  PlantCare? get care => PlantCare.fromMap(careMap);

  factory PlantReply.fromMap(Map<String, dynamic> map) {
    final care = map['care'];
    return PlantReply(
      name: (map['name'] as String? ?? '').trim(),
      response: map['response'] as String? ?? '',
      quickQuestions: [
        for (final q in (map['quickQuestions'] as List? ?? const [])) if (q is String && q.trim().isNotEmpty) q.trim(),
      ],
      careMap: care is Map ? Map<String, dynamic>.from(care) : null,
    );
  }
}

DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);

/// Harmonogram podlewania liczony z danych rośliny.
extension GardenSchedule on Chat {
  PlantCare? get plantCare => PlantCare.fromMap(care);

  DateTime? get nextWatering {
    final days = wateringDays;
    final last = lastWateredAt;
    if (days == null || last == null) return null;
    return _day(last).add(Duration(days: days));
  }

  /// Dni do podlewania: 0 = dziś, ujemne = spóźnione, null = brak planu.
  int? daysUntilWatering([DateTime? now]) {
    final next = nextWatering;
    if (next == null) return null;
    return next.difference(_day(now ?? DateTime.now())).inDays;
  }

  bool get needsWater => (daysUntilWatering() ?? 1) <= 0;

  /// 0..1 — ile minęło z bieżącego cyklu podlewania (1 = trzeba podlać).
  double get waterProgress {
    final days = wateringDays;
    final left = daysUntilWatering();
    if (days == null || left == null) return 0;
    return (1 - left / days).clamp(0.0, 1.0);
  }

  String get displayName => name.isEmpty ? 'Plant #$id' : name;
}
