import 'package:rockidentifie/models/models.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'chat_database.g.dart';

@DriftDatabase(tables: [Chats, Messages])
class ChatDatabase extends _$ChatDatabase {
  ChatDatabase() : super(driftDatabase(name: 'chat.db'));

  @override
  int get schemaVersion => 3;

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
      });

  Future<void> updateQuickQuestions(int chatId, List<String> newQuickQuestions) async {
    await (update(chats)..where((t) => t.id.equals(chatId))).write(ChatsCompanion(
      quickQuestions: Value(newQuickQuestions),
    ));
  }

  Future<void> updateName(int chatId, String newName) async {
    await (update(chats)..where((t) => t.id.equals(chatId))).write(ChatsCompanion(
      name: Value(newName),
    ));
  }

  Future<void> updateLastMessage(int chatId, String newLastMessage) async {
    await (update(chats)..where((t) => t.id.equals(chatId))).write(ChatsCompanion(
      lastMessage: Value(newLastMessage),
    ));
  }
}
