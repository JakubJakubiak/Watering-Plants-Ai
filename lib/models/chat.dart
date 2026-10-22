import 'dart:convert';

import 'package:drift/drift.dart';

/// Rozmowa z AI. Gdy dotyczy rozpoznanej rośliny, jest też wpisem w ogrodzie
/// (`inGarden`) z planem podlewania.
class Chats extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get quickQuestions => text().map(const ListStringConverter()).withDefault(const Constant('[]'))();
  TextColumn get lastMessage => text().nullable()();
  TextColumn get imagePath => text().nullable()();

  // Od wersji 4 schematu: profil opieki zwrócony przez AI.
  TextColumn get species => text().nullable()();
  TextColumn get care => text().map(const JsonMapConverter()).nullable()();
  IntColumn get wateringDays => integer().nullable()();
  DateTimeColumn get lastWateredAt => dateTime().nullable()();
  BoolColumn get inGarden => boolean().withDefault(const Constant(false))();
}

/// Historia podlewania rośliny.
class WaterLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chatId => integer().references(Chats, #id)();
  DateTimeColumn get wateredAt => dateTime()();
}

class ListStringConverter extends TypeConverter<List<String>, String> {
  const ListStringConverter();

  @override
  List<String> fromSql(String fromDb) {
    return (jsonDecode(fromDb) as List).cast<String>();
  }

  @override
  String toSql(List<String> value) {
    return jsonEncode(value);
  }
}

class JsonMapConverter extends TypeConverter<Map<String, dynamic>, String> {
  const JsonMapConverter();

  @override
  Map<String, dynamic> fromSql(String fromDb) => Map<String, dynamic>.from(jsonDecode(fromDb) as Map);

  @override
  String toSql(Map<String, dynamic> value) => jsonEncode(value);
}
