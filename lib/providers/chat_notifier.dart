import 'package:PlantsAI/database/chat_database.dart';
import 'package:PlantsAI/repositories/chat_repository.dart';
import 'package:flutter/widgets.dart';

class ChatNotifier extends ChangeNotifier {
  final ChatRepository _repository;

  ChatNotifier(this._repository);

  List<Chat> _chats = [];
  List<Chat> get chats => _chats;

  Future<void> loadChats() async {
    _chats = await _repository.getAllChats();
    notifyListeners();
  }

  Future<Chat> createChat(String imagePath, String initialMessage) async {
    final chat = await _repository.createChat(imagePath, initialMessage);
    await loadChats(); // Reload chats to include the new one
    return chat;
  }

  Future<void> getFirstMessage(int chatId, String imagePath) async {
    await _repository.getFirstMessage(chatId, imagePath);
  }

  Future<void> sendMessage(int chatId, String content) async {
    await _repository.sendMessage(chatId, content);
  }

  Stream<List<Message>> watchMessages(int chatId) {
    return _repository.watchMessages(chatId);
  }

  Stream<Chat> watchChat(int chatId) {
    return _repository.watchChat(chatId);
  }
}
