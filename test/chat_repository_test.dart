import 'dart:convert';
import 'dart:io';

import 'package:ai_hub_client/ai_hub_client.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:plantsai/core/app_paths.dart';
import 'package:plantsai/data/chat_repository.dart';
import 'package:plantsai/data/plant_care.dart';
import 'package:plantsai/database/chat_database.dart';

const _account = {
  'credits': 4,
  'isPro': false,
  'proUntil': null,
  'rewardsLeft': 10,
  'rewardCredits': 4,
  'dailyFreeCredits': 3,
};

const _reply = {
  'name': 'Monstera',
  'response': '**Monstera deliciosa** looks healthy.',
  'quickQuestions': ['How much light?', 'When to repot?', ' '],
  'care': {
    'species': 'Monstera deliciosa',
    'wateringDays': 7,
    'light': 'bright_indirect',
    'humidity': 'high',
    'temperature': '18–27 °C',
    'difficulty': 'easy',
    'health': 'healthy',
    'healthNote': 'Leaves look firm and green.',
    'toxicToPets': true,
  },
};

void main() {
  late ChatDatabase db;
  late ChatRepository repository;
  late List<Map<String, dynamic>> chatRequests;

  setUp(() async {
    AppPaths.documents = (await Directory.systemTemp.createTemp('plantsai_test')).path;
    db = ChatDatabase.forTesting(NativeDatabase.memory());
    chatRequests = [];
    final hub = AiHubClient(
      baseUrl: Uri.parse('https://example.convex.site'),
      app: 'plantsai',
      clientKey: 'pk_test',
      deviceId: 'device-12345678',
      httpClient: MockClient((request) async {
        if (request.url.path == '/v1/session') {
          return http.Response.bytes(utf8.encode(jsonEncode({'token': 't', 'account': _account})), 200);
        }
        chatRequests.add(jsonDecode(request.body) as Map<String, dynamic>);
        return http.Response.bytes(utf8.encode(jsonEncode({'reply': _reply, 'account': _account})), 200);
      }),
    );
    repository = ChatRepository(db, hub);
  });

  tearDown(() => db.close());

  test('first answer with a care profile puts the plant into the garden', () async {
    final chat = await repository.createChat(prompt: 'What plant is this?');
    final reply = await repository.ask(chat.id, language: 'Polski');

    expect(reply.quickQuestions, ['How much light?', 'When to repot?']);
    final saved = await repository.watchChat(chat.id).first;
    expect(saved!.name, 'Monstera');
    expect(saved.inGarden, isTrue);
    expect(saved.species, 'Monstera deliciosa');
    expect(saved.wateringDays, 7);
    expect(saved.daysUntilWatering(), 7);
    expect(saved.plantCare!.toxicToPets, isTrue);

    final messages = await repository.watchMessages(chat.id).first;
    expect(messages.map((m) => m.isUserMessage), [true, false]);
    expect(chatRequests.single['language'], 'Polski');
    expect(chatRequests.single['context'], isNull);
  });

  test('follow-ups keep a user-edited interval and send the plant context', () async {
    final chat = await repository.createChat(prompt: 'What plant is this?');
    await repository.ask(chat.id, language: 'English');
    await repository.setWateringDays(chat.id, 3);

    await repository.sendMessage(chat.id, 'Is it toxic?', language: 'English');

    final saved = await repository.watchChat(chat.id).first;
    expect(saved!.wateringDays, 3);
    expect(chatRequests.last['messages'], hasLength(3));
    expect(chatRequests.last['context'], {'plant': 'Monstera', 'species': 'Monstera deliciosa', 'wateringDays': 3});
  });

  test('watering resets the cycle and is logged', () async {
    final chat = await repository.createChat(prompt: 'What plant is this?');
    await repository.ask(chat.id, language: 'English');
    await db.updateChat(
      chat.id,
      ChatsCompanion(lastWateredAt: Value(DateTime.now().subtract(const Duration(days: 9)))),
    );
    expect((await repository.watchChat(chat.id).first)!.daysUntilWatering(), -2);

    await repository.markWatered(chat.id);

    final saved = await repository.watchChat(chat.id).first;
    expect(saved!.needsWater, isFalse);
    expect(await repository.watchWaterLogs(chat.id).first, hasLength(1));
  });

  test('deleting a chat removes its messages and watering log', () async {
    final chat = await repository.createChat(prompt: 'What plant is this?');
    await repository.ask(chat.id, language: 'English');
    await repository.markWatered(chat.id);

    await repository.deleteChat(chat.id);

    expect(await repository.watchChats().first, isEmpty);
    expect(await db.select(db.messages).get(), isEmpty);
    expect(await db.select(db.waterLogs).get(), isEmpty);
  });
}
