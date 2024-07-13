import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:PlantsAI/providers/chat_notifier.dart';
import 'package:PlantsAI/database/chat_database.dart';

class ChatScreen extends StatefulWidget {
  final int chatId;
  final bool isNewChat;
  final String? imagePath;

  const ChatScreen({super.key, required this.chatId, required this.isNewChat, this.imagePath});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isNewChat) {
      _getFirstMessage();
    }
  }

  Future<void> _getFirstMessage() async {
    setState(() {
      _isLoading = true;
    });
    await context.read<ChatNotifier>().getFirstMessage(widget.chatId, widget.imagePath!);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat ${widget.chatId}')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: context.read<ChatNotifier>().watchMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final message = snapshot.data![index];
                      return ListTile(
                        title: Text(message.content),
                        subtitle: Text(message.isUserMessage ? 'User' : 'Bot'),
                        leading: message.imagePath != null
                            ? Image.file(File(message.imagePath!), width: 50, height: 50)
                            : null,
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Getting first message...'),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      context.read<ChatNotifier>().sendMessage(
                        widget.chatId,
                        _messageController.text,
                      );
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}