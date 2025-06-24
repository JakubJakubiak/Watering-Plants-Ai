import 'package:plantsai/models/chat.dart';
import 'package:drift/drift.dart';

class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chatId => integer().references(Chats, #id)();
  TextColumn get content => text()();
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isUserMessage => boolean()();
}
