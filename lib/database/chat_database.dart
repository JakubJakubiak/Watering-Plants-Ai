import 'package:PlantsAI/models/models.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'chat_database.g.dart';

@DriftDatabase(tables: [Chats, Messages])
class ChatDatabase extends _$ChatDatabase {
  ChatDatabase(): super(driftDatabase(name: 'chat.db'));

  @override 
  int get schemaVersion => 1;
}