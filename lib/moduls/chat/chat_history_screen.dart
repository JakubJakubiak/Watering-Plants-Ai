import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plantsai/moduls/chat/chat_screen.dart';
import 'package:plantsai/moduls/chat/new_chat_screen.dart';
import 'package:plantsai/providers/chat_notifier.dart';

class ChatHistoryScreen extends StatefulWidget {
  final void Function(BuildContext dialogContext) onContinuePlaying;
  const ChatHistoryScreen({super.key, required this.onContinuePlaying});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  get onContinuePlaying => widget.onContinuePlaying;
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      // Provider.of<ChatNotifier>(context, listen: false).loadChats();
      final chatNotifier = Provider.of<ChatNotifier>(context, listen: false);
      await chatNotifier.loadChats();
      // await chatNotifier.deleteUnknownChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        backgroundColor: const Color(0xFF16213e),
      ),
      body: Consumer<ChatNotifier>(builder: (context, chatNotifier, child) {
        if (chatNotifier.chats.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Chats Yet',
                ),
                SizedBox(height: 8),
                Text(
                  'Start a new conversation to begin chatting.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: chatNotifier.chats.length,
          itemBuilder: (context, index) {
            final chat = chatNotifier.chats[index];
            final chatName = chatNotifier.chats[index].name;
            final chatTitle = chatName.isNotEmpty ? chatName : 'Chat ${chat.id}';
            final chatAvatarPath = chatNotifier.chats[index].imagePath;
            final lastMessage = chatNotifier.chats[index].lastMessage;

            // if (chatTitle == "Unknown" || chatTitle == "Chat ${chat.id}") {
            //   Future.microtask(() => chatNotifier.deleteChat(chat.id));
            //   return Text("data");
            // }

            return Dismissible(
              key: Key('$chatName${chat.id}'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirm"),
                      content: const Text("Are you sure you want to delete this chat?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("CANCEL"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("DELETE"),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (direction) {
                chatNotifier.deleteChat(chat.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$chatTitle deleted')),
                );
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: ListTile(
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
                      onContinuePlaying: onContinuePlaying,
                    ),
                  ));
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NewChatScreen(onContinuePlaying: (dialogContext) => {}),
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
