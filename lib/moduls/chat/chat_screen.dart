import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:PlantsAI/providers/chat_notifier.dart';
import 'package:PlantsAI/database/chat_database.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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
  bool isPro = false;

  @override
  void initState() {
    super.initState();
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      EntitlementInfo? entitlement = customerInfo.entitlements.all['Pro'];
      bool isProActive = (entitlement?.isActive ?? false);
      setState(() {
        isPro = isProActive;
      });
    });
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
    final int tokens = Provider.of<int>(context);
    return StreamBuilder<Chat>(
        stream: context.read<ChatNotifier>().watchChat(widget.chatId),
        builder: (context, snapshot) {
          final chat = snapshot.data;

          if (chat == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final quickQuestions = chat.quickQuestions;
          final chatName = chat.name.isEmpty ? 'Chat ${widget.chatId}' : chat.name;

          return Scaffold(
            appBar: AppBar(title: Text(chatName)),
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

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              child: Align(
                                alignment: message.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                                  child: Column(
                                    crossAxisAlignment: message.isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message.isUserMessage ? 'You' : 'Bot',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: message.isUserMessage ? Colors.blue[700] : Colors.green[700],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: message.isUserMessage ? Colors.blue[700] : Colors.grey[900],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (message.imagePath != null)
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.file(
                                                  File(message.imagePath!),
                                                  width: 200,
                                                  height: 200,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            if (message.imagePath != null) const SizedBox(height: 8),
                                            MarkdownBody(
                                              data: message.content,
                                              styleSheet: MarkdownStyleSheet(
                                                p: const TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                if (quickQuestions.isNotEmpty && (tokens > 0 || isPro))
                  SizedBox(
                    height: 48,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: quickQuestions.length,
                      itemBuilder: (context, index) {
                        final question = quickQuestions[index];
                        return Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: FilledButton.tonal(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.grey[900],
                              ),
                              onPressed: () {
                                context.read<ChatNotifier>().sendMessage(widget.chatId, question);
                              },
                              child: Text(question),
                            ));
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: tokens > 0 || isPro
                      ? Row(
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
                        )
                      : const Column(children: [
                          Text(
                            "You have 0 usage, watch an ad or subscribe",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16.0),
                          )
                        ]),
                ),
              ],
            ),
          );
        });
  }
}
