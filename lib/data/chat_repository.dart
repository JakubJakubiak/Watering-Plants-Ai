import 'dart:io';

import 'package:ai_hub_client/ai_hub_client.dart';
import 'package:drift/drift.dart';
import 'package:plantsai/core/app_paths.dart';
import 'package:plantsai/database/chat_database.dart';

import 'plant_care.dart';

/// Rozmowy i ogród. Historia leży lokalnie (drift), a odpowiedzi daje ai-hub.
class ChatRepository {
  ChatRepository(this._db, this._hub);

  final ChatDatabase _db;
  final AiHubClient _hub;

  Stream<List<Chat>> watchChats() =>
      (_db.select(_db.chats)..orderBy([(c) => OrderingTerm.desc(c.createdAt)])).watch();

  Stream<List<Chat>> watchGarden() => (_db.select(_db.chats)
        ..where((c) => c.inGarden.equals(true))
        ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
      .watch();

  Stream<Chat?> watchChat(int chatId) =>
      (_db.select(_db.chats)..where((c) => c.id.equals(chatId))).watchSingleOrNull();

  Stream<List<Message>> watchMessages(int chatId) => (_db.select(_db.messages)
        ..where((m) => m.chatId.equals(chatId))
        ..orderBy([(m) => OrderingTerm.asc(m.timestamp), (m) => OrderingTerm.asc(m.id)]))
      .watch();

  Stream<List<WaterLog>> watchWaterLogs(int chatId) => (_db.select(_db.waterLogs)
        ..where((w) => w.chatId.equals(chatId))
        ..orderBy([(w) => OrderingTerm.desc(w.wateredAt)])
        ..limit(30))
      .watch();

  /// Nowa rozmowa. [imagePath] to ścieżka z [AppPaths.persistImage].
  Future<Chat> createChat({String? imagePath, required String prompt}) async {
    final now = DateTime.now();
    final chat = await _db.into(_db.chats).insertReturning(ChatsCompanion.insert(
          name: '',
          createdAt: now,
          imagePath: Value(imagePath),
          lastMessage: Value(prompt),
        ));
    await _db.into(_db.messages).insert(MessagesCompanion.insert(
          chatId: chat.id,
          content: prompt,
          imagePath: Value(imagePath),
          timestamp: now,
          isUserMessage: true,
        ));
    return chat;
  }

  Future<PlantReply> sendMessage(int chatId, String content, {required String language}) async {
    await _db.into(_db.messages).insert(MessagesCompanion.insert(
          chatId: chatId,
          content: content,
          timestamp: DateTime.now(),
          isUserMessage: true,
        ));
    await _db.updateChat(chatId, ChatsCompanion(lastMessage: Value(content)));
    return ask(chatId, language: language);
  }

  /// Wysyła historię rozmowy do AI i zapisuje odpowiedź. Rzuca [AiHubException].
  Future<PlantReply> ask(int chatId, {required String language}) async {
    final chat = await (_db.select(_db.chats)..where((c) => c.id.equals(chatId))).getSingle();
    final history = await (_db.select(_db.messages)
          ..where((m) => m.chatId.equals(chatId))
          ..orderBy([(m) => OrderingTerm.asc(m.timestamp), (m) => OrderingTerm.asc(m.id)]))
        .get();

    // Zdjęcie idzie z każdym zapytaniem (detail: low, ~85 tokenów), żeby model
    // przy pytaniach uzupełniających wciąż widział roślinę.
    final imageFile = AppPaths.resolve(chat.imagePath);
    final result = await _hub.chat(
      messages: [
        for (final m in history) m.isUserMessage ? AiHubMessage.user(m.content) : AiHubMessage.assistant(m.content),
      ],
      image: imageFile == null ? null : await imageFile.readAsBytes(),
      imageMime: _mimeOf(imageFile),
      language: language,
      context: chat.species == null
          ? null
          : {'plant': chat.name, 'species': chat.species, 'wateringDays': chat.wateringDays},
    );

    final reply = PlantReply.fromMap(result.reply);
    final care = reply.care;
    final firstCare = care != null && chat.care == null;

    await _db.transaction(() async {
      await _db.updateChat(
        chatId,
        ChatsCompanion(
          name: chat.name.isEmpty && reply.name.isNotEmpty ? Value(reply.name) : const Value.absent(),
          quickQuestions: Value(reply.quickQuestions),
          lastMessage: Value(reply.response),
          care: care != null ? Value(reply.careMap) : const Value.absent(),
          species: care != null && care.species.isNotEmpty ? Value(care.species) : const Value.absent(),
          // Częstotliwość z AI tylko za pierwszym razem — potem decyduje użytkownik.
          wateringDays: firstCare && chat.wateringDays == null ? Value(care.wateringDays) : const Value.absent(),
          lastWateredAt: firstCare && chat.lastWateredAt == null ? Value(DateTime.now()) : const Value.absent(),
          inGarden: firstCare ? const Value(true) : const Value.absent(),
        ),
      );
      await _db.into(_db.messages).insert(MessagesCompanion.insert(
            chatId: chatId,
            content: reply.response,
            timestamp: DateTime.now(),
            isUserMessage: false,
          ));
    });
    return reply;
  }

  Future<void> markWatered(int chatId) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      await _db.updateChat(chatId, ChatsCompanion(lastWateredAt: Value(now)));
      await _db.into(_db.waterLogs).insert(WaterLogsCompanion.insert(chatId: chatId, wateredAt: now));
    });
  }

  Future<void> setWateringDays(int chatId, int days) =>
      _db.updateChat(chatId, ChatsCompanion(wateringDays: Value(days.clamp(1, 60))));

  Future<void> setInGarden(int chatId, bool inGarden) async {
    final chat = await (_db.select(_db.chats)..where((c) => c.id.equals(chatId))).getSingle();
    await _db.updateChat(
      chatId,
      ChatsCompanion(
        inGarden: Value(inGarden),
        wateringDays: inGarden && chat.wateringDays == null ? const Value(7) : const Value.absent(),
        lastWateredAt: inGarden && chat.lastWateredAt == null ? Value(DateTime.now()) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteChat(int chatId) async {
    final chat = await (_db.select(_db.chats)..where((c) => c.id.equals(chatId))).getSingleOrNull();
    if (chat == null) return;
    await _db.transaction(() async {
      await (_db.delete(_db.waterLogs)..where((w) => w.chatId.equals(chatId))).go();
      await (_db.delete(_db.messages)..where((m) => m.chatId.equals(chatId))).go();
      await (_db.delete(_db.chats)..where((c) => c.id.equals(chatId))).go();
    });
    final file = AppPaths.resolve(chat.imagePath);
    if (file != null) {
      try {
        await file.delete();
      } catch (_) {}
    }
  }

  static String _mimeOf(File? file) {
    final path = file?.path.toLowerCase() ?? '';
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
