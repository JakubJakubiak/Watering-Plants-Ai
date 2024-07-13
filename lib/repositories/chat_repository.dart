import 'dart:convert';
import 'dart:io';

import 'package:PlantsAI/database/chat_database.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:drift/drift.dart';

class ChatRepository {
  final ChatDatabase _db;
  final FirebaseFunctions _firebaseFunctions;

  ChatRepository(this._db, this._firebaseFunctions);

  Future<List<Chat>> getAllChats() {
    return _db.select(_db.chats).get();
  }

  Stream<List<Message>> watchMessages(int chatId) {
    return (_db.select(_db.messages)..where((m) => m.chatId.equals(chatId))).watch();
  }

  Future<Chat> createChat(String imagePath, String initialMessage) async {
    // Create a new chat
    final chat = await _db.into(_db.chats).insertReturning(ChatsCompanion.insert(
          name: 'Plant Identification Chat',
          createdAt: DateTime.now(),
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

  Future<void> getFirstMessage(int chatId, String imagePath) async {
    final File imageFile = File(imagePath);
    final List<int> imageBytes = await imageFile.readAsBytes();
    final String base64Image = base64Encode(imageBytes);

    print("///////botResponse//////////start");

    final botResponse = await _firebaseFunctions.httpsCallable('createChat2').call({
      'image': base64Image,
    });

    print("///////botResponse//////////////$botResponse");

    // Save bot response
    await _db.into(_db.messages).insert(MessagesCompanion.insert(
          chatId: chatId,
          content: botResponse.data['message'],
          timestamp: DateTime.now(),
          isUserMessage: false,
        ));
    print("///////botResponse//////////////$botResponse");
  }

  Future<void> sendMessage(int chatId, String content) async {
    // Create new user message
    final userMessage = MessagesCompanion.insert(
      chatId: chatId,
      content: content,
      timestamp: DateTime.now(),
      isUserMessage: true,
    );
    await _db.into(_db.messages).insert(userMessage);

    // Get all chat history
    final chatHistory = await (_db.select(_db.messages)..where((m) => m.chatId.equals(chatId))).get();

    // Get bot response
    final botResponse = await _firebaseFunctions.httpsCallable('sendMessage').call({
      'chatHistory': chatHistory
          .map((m) => {
                'content': m.content,
                'role': m.isUserMessage ? 'user' : 'assistant',
              })
          .toList(),
    });

    // Save bot response
    await _db.into(_db.messages).insert(MessagesCompanion.insert(
          chatId: chatId,
          content: botResponse.data['message'],
          timestamp: DateTime.now(),
          isUserMessage: false,
        ));
  }
}
