import 'dart:io';
import 'package:PlantsAI/database/chat_database.dart';
import 'package:PlantsAI/repositories/chat_repository.dart';
import 'package:flutter/widgets.dart';

class ChatNotifier extends ChangeNotifier {
  final ChatRepository _repository;

  ChatNotifier(this._repository);

  List<Chat> _chats = [];
  List<Chat> get chats => _chats.reversed.toList();

  Future<void> loadChats() async {
    _chats = await _repository.getAllChats();
    notifyListeners();
  }

  Future<Chat> createChat(String imagePath, String initialMessage) async {
    final chat = await _repository.createChat(imagePath, initialMessage);
    await loadChats(); // Reload chats to include the new one
    return chat;
  }

  Future<void> getFirstMessage(int chatId, String imagePath, String languageName) async {
    await _repository.getFirstMessage(chatId, imagePath, languageName);
  }

  Future<void> sendMessage(int chatId, String content, String languageName) async {
    await _repository.sendMessage(chatId, content, languageName);
  }

  Stream<List<Message>> watchMessages(int chatId) {
    return _repository.watchMessages(chatId);
  }

  Stream<Chat> watchChat(int chatId) {
    return _repository.watchChat(chatId);
  }

  Future<void> deleteChat(int id) async {
    try {
      final chat = await _repository.getChatById(id);
      if (chat != null) {
        await _repository.deleteChat(id);
        if (chat.imagePath != null && chat.imagePath!.isNotEmpty) {
          final file = File('${chat.imagePath}');
          if (await file.exists()) {
            await file.delete();
          }
        }
        _chats.removeWhere((c) => c.id == id);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting chat: $e');
    }
  }

  // Future<void> deleteUnknownChats() async {
  //   try {
  //     List<Chat> chatsToDelete = _chats.where((chat) => chat.name == "Unknown" || chat.name == "Chat ${chat.id}").toList();

  //     for (var chat in chatsToDelete) {
  //       await deleteChat(chat.id);
  //     }
  //   } catch (e) {
  //     print('Error deleting unknown chats: $e');
  //   }
  // }
}
