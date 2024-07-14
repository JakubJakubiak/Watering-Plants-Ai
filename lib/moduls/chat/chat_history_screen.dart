import 'dart:io';

import 'package:PlantsAI/moduls/chat/chat_screen.dart';
import 'package:PlantsAI/moduls/chat/new_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:PlantsAI/providers/chat_notifier.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ChatNotifier>(context, listen: false).loadChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat History')),
      body: Consumer<ChatNotifier>(
        builder: (context, chatNotifier, child) {
          return ListView.builder(
            itemCount: chatNotifier.chats.length,
            itemBuilder: (context, index) {
              final chat = chatNotifier.chats[index];
              final chatName = chatNotifier.chats[index].name;
              final chatTitle = chatName.isNotEmpty ? chatName : 'Chat $index';

              final chatAvatarPath = chatNotifier.chats[index].imagePath;
              final lastMessage = chatNotifier.chats[index].lastMessage;

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: chatAvatarPath != null ? FileImage(File(chatAvatarPath)) : null,
                  child: chatAvatarPath == null ? const Icon(Icons.person) : null,
                ),
                title: Text(chatTitle),
                subtitle: Text(
                  lastMessage ?? 'No messages yet',
                  maxLines: 1,
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      chatId: chat.id,
                      isNewChat: false,
                    ),
                  ));
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const NewChatScreen(),
          ));
        },
      ),
    );
  }

  Future<File?> getFile(String fileName) async {
    final file = File('${(await getApplicationDocumentsDirectory()).path}/$fileName');
    return await file.exists() ? file : null;
  }
}
