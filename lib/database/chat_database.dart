import 'package:plantsai/models/models.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'chat_database.g.dart';

@DriftDatabase(tables: [Chats, Messages, WaterLogs])
class ChatDatabase extends _$ChatDatabase {
  ChatDatabase() : super(driftDatabase(name: 'chat.db'));

  ChatDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (m) async {
        await m.createAll();
      }, onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(chats, chats.quickQuestions);
        }
        if (from < 3) {
          await m.addColumn(chats, chats.lastMessage);
          await m.addColumn(chats, chats.imagePath);
        }
        if (from < 4) {
          await m.addColumn(chats, chats.species);
          await m.addColumn(chats, chats.care);
          await m.addColumn(chats, chats.wateringDays);
          await m.addColumn(chats, chats.lastWateredAt);
          await m.addColumn(chats, chats.inGarden);
          await m.createTable(waterLogs);
        }
      });

  Future<void> updateChat(int chatId, ChatsCompanion fields) async {
    await (update(chats)..where((t) => t.id.equals(chatId))).write(fields);
  }
}
