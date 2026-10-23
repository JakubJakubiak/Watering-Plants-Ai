// Buduje bazę z przykładowymi roślinami do zrzutów sklepowych (bez działającego AI).
//
//   OUT=/tmp/chat.db flutter test store/demo/seed_demo_db_test.dart
//
// Potem wgraj bazę i zdjęcia z store/demo/plants/ do aplikacji debug — patrz README, sekcja "Sklep".
// Zdjęcia roślin: Pexels (licencja pozwala na użycie komercyjne, bez atrybucji).
import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantsai/database/chat_database.dart';

Map<String, dynamic> care(String species, int days, String light, String health, String note, bool toxic) => {
      'species': species,
      'wateringDays': days,
      'light': light,
      'humidity': 'medium',
      'temperature': '18–24 °C',
      'difficulty': 'easy',
      'health': health,
      'healthNote': note,
      'toxicToPets': toxic,
    };

void main() {
  test('seed', () async {
    final file = File(Platform.environment['OUT'] ?? 'build/demo_chat.db');
    if (file.existsSync()) file.deleteSync();
    final db = ChatDatabase.forTesting(NativeDatabase(file));
    final now = DateTime.now();
    final plants = [
      (
        'Monstera',
        care('Monstera deliciosa', 7, 'bright_indirect', 'healthy', 'Leaves look firm, glossy and evenly green.', true),
        9,
        'plants/monstera.jpg'
      ),
      (
        'Peace Lily',
        care('Spathiphyllum wallisii', 4, 'medium', 'needs_attention',
            'Leaf tips are browning — raise the humidity a little.', true),
        4,
        'plants/peace_lily.jpg'
      ),
      (
        'Snake Plant',
        care('Dracaena trifasciata', 14, 'low', 'healthy', 'Upright, firm leaves — in great shape.', true),
        3,
        'plants/snake_plant.jpg'
      ),
      (
        'Rubber Plant',
        care('Ficus elastica', 6, 'bright_indirect', 'healthy', 'Healthy new growth at the top.', true),
        2,
        'plants/rubber_plant.jpg'
      ),
    ];
    for (final (name, c, ago, img) in plants) {
      final chat = await db.into(db.chats).insertReturning(ChatsCompanion.insert(
          name: name,
          createdAt: now.subtract(Duration(days: 20 - ago)),
          quickQuestions: const Value(['How often to fertilize?', 'When should I repot?', 'Why are leaves yellow?']),
          imagePath: Value(img),
          lastMessage: Value('$name looks healthy. Water when the top 3 cm of soil is dry.'),
          species: Value(c['species'] as String),
          care: Value(c),
          wateringDays: Value(c['wateringDays'] as int),
          lastWateredAt: Value(now.subtract(Duration(days: ago))),
          inGarden: const Value(true)));
      await db.into(db.messages).insert(MessagesCompanion.insert(
          chatId: chat.id,
          content: 'What plant is this? How is it doing and how should I care for it?',
          imagePath: Value(img),
          timestamp: now,
          isUserMessage: true));
      await db.into(db.messages).insert(MessagesCompanion.insert(
          chatId: chat.id,
          content:
              'This is a **$name** (*${c['species']}*) and it looks healthy! 🌿\n\n- **Water:** every ${c['wateringDays']} days, when the top 3 cm of soil is dry\n- **Light:** bright, indirect — avoid harsh afternoon sun\n- **Feeding:** once a month in spring and summer\n- **Tip:** wipe the leaves every few weeks so they can breathe',
          timestamp: now,
          isUserMessage: false));
      for (var i = 0; i < 4; i++) {
        await db.into(db.waterLogs).insert(WaterLogsCompanion.insert(
            chatId: chat.id, wateredAt: now.subtract(Duration(days: ago + i * (c['wateringDays'] as int)))));
      }
    }
    await db.close();
  });
}
