import 'dart:convert';
import 'dart:io';

import 'package:plantsai/database/chat_database.dart';
import 'package:plantsai/models/response_message.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRepository {
  final ChatDatabase _db;
  final FirebaseFunctions _firebaseFunctions;

  ChatRepository(this._db, this._firebaseFunctions);

  Future<List<Chat>> getAllChats() {
    return _db.select(_db.chats).get();
  }

  Stream<Chat> watchChat(int chatId) {
    return (_db.select(_db.chats)..where((c) => c.id.equals(chatId))).watchSingle();
  }

  Stream<List<Message>> watchMessages(int chatId) {
    return (_db.select(_db.messages)..where((m) => m.chatId.equals(chatId))).watch();
  }

  Future<Chat> createChat(String imagePath, String initialMessage) async {
    // Create a new chat
    final chat = await _db.into(_db.chats).insertReturning(ChatsCompanion.insert(
          name: '',
          quickQuestions: const Value([]),
          createdAt: DateTime.now(),
          imagePath: Value(imagePath),
        ));

    // Create the first user message
    final userMessage = MessagesCompanion.insert(
      chatId: chat.id,
      content: initialMessage,
      imagePath: Value(imagePath),
      timestamp: DateTime.now(),
      isUserMessage: true,
    );
    await _db.into(_db.messages).insert(userMessage);

    return chat;
  }

  Future<void> getFirstMessage(int chatId, String imagePath, String languageName) async {
    final File imageFile = File(imagePath);
    final List<int> imageBytes = await imageFile.readAsBytes();
    final String base64Image = base64Encode(imageBytes);
    final systemLocale = languageName;
    final revenuecatkeyUser = await loadUserIDRevenuecat();

    final botResponse = await _firebaseFunctions.httpsCallable('createChat').call({
      'image': base64Image,
      "language": systemLocale,
      "revenuecatToken": revenuecatkeyUser,
    });

    final responseMessage = ResponseMessage.fromJson(botResponse.data['message'] as String);

    await _db.updateQuickQuestions(chatId, responseMessage.quickQuestions);
    await _db.updateName(chatId, responseMessage.name);
    await _db.updateLastMessage(chatId, responseMessage.response);

    await _db.into(_db.messages).insert(MessagesCompanion.insert(
          chatId: chatId,
          content: responseMessage.response,
          timestamp: DateTime.now(),
          isUserMessage: false,
        ));
  }

  Future<String> loadUserIDRevenuecat() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('saveUserIDRevenuecat');
    return userId ?? "";
  }

  Future<void> sendMessage(int chatId, String content, String languageName) async {
    // Create new user message
    final userMessage = MessagesCompanion.insert(
      chatId: chatId,
      content: content,
      timestamp: DateTime.now(),
      isUserMessage: true,
    );
    await _db.into(_db.messages).insert(userMessage);
    await _db.updateLastMessage(chatId, content);

    final chatHistory = await (_db.select(_db.messages)..where((m) => m.chatId.equals(chatId))).get();
    // final Locale systemLocale = PlatformDispatcher.instance.locale;
    final systemLocale = languageName;
    final revenuecatkeyUser = await loadUserIDRevenuecat();

    final botResponse = await _firebaseFunctions.httpsCallable('sendMessage').call({
      'chatHistory': chatHistory
          .map((m) => {
                'content': m.content,
                'role': m.isUserMessage ? 'user' : 'assistant',
              })
          .toList(),
      "language": systemLocale,
      "revenuecatToken": revenuecatkeyUser,
    });

    final responseMessage = ResponseMessage.fromJson(botResponse.data['message'] as String);

    await _db.updateQuickQuestions(chatId, responseMessage.quickQuestions);
    await _db.updateName(chatId, responseMessage.name);
    await _db.updateLastMessage(chatId, responseMessage.response);

    await _db.into(_db.messages).insert(MessagesCompanion.insert(
          chatId: chatId,
          content: responseMessage.response,
          timestamp: DateTime.now(),
          isUserMessage: false,
        ));
  }

  // getChatById(int id) {}

  // deleteChat(int id) {}

  Future<Chat?> getChatById(int id) async {
    return await (_db.select(_db.chats)..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  Future<void> deleteChat(int id) async {
    await (_db.delete(_db.messages)..where((m) => m.chatId.equals(id))).go();
    await (_db.delete(_db.chats)..where((c) => c.id.equals(id))).go();
  }
}
