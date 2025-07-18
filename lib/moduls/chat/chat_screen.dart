import 'dart:io';
import 'dart:math';
import 'package:plantsai/main.dart';
import 'package:plantsai/moduls/payment/paymentrevenuecat.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:plantsai/providers/chat_notifier.dart';
import 'package:plantsai/database/chat_database.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';

class ChatScreen extends StatefulWidget {
  final int chatId;
  final bool isNewChat;
  final String? imagePath;
  final void Function(BuildContext dialogContext) onContinuePlaying;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.isNewChat,
    this.imagePath,
    required this.onContinuePlaying,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final InAppReview inAppReview = InAppReview.instance;
  bool _isLoading = false;
  bool isPro = false;
  get onContinuePlaying => widget.onContinuePlaying;

  void _showContinuePlayingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        Future.microtask(() {
          Navigator.of(dialogContext).pop();
          widget.onContinuePlaying(dialogContext);
        });
        return const SizedBox();
      },
    );
  }

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

  Future<void> _showPaywallIfNeeded() async {
    final navigator = Navigator.of(context);
    Offerings offerings = await Purchases.getOfferings();
    final offering = offerings.current;

    if (offering == null) return;

    navigator.push(
      MaterialPageRoute(builder: (context) => PaywallView(offering: offering)),
    );
  }

  Future<void> _getFirstMessage() async {
    final currentLanguage = Provider.of<LocaleProvider>(context, listen: false).selectedLanguage;

    setState(() {
      _isLoading = true;
    });
    if (!isPro) _showContinuePlayingDialog(context);
    await context.read<ChatNotifier>().getFirstMessage(widget.chatId, widget.imagePath!, currentLanguage);
    setState(() {
      _isLoading = false;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // _evaluationAPK(int tokens) async {
  //   final int randomToken = Random().nextInt(tokens) + 1;

  //   if (tokens == randomToken) {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     int lastPromptTimestamp = prefs.getInt('lastPromptTimestamp') ?? 0;
  //     int currentTime = DateTime.now().millisecondsSinceEpoch;
  //     const int oneMonthMillis = 30 * 24 * 60 * 60 * 1000;

  //     if (currentTime - lastPromptTimestamp > oneMonthMillis && await InAppReview.instance.isAvailable()) {
  //       await InAppReview.instance.requestReview();
  //       prefs.setInt('lastPromptTimestamp', currentTime);
  //     }
  //   } else {
  //     return;
  //   }
  // }

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
                      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final message = snapshot.data![index];
                          return _buildMessageItem(message);
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
              if (_isLoading) _buildLoadingIndicator(),
              if (quickQuestions.isNotEmpty && (tokens > 0 || isPro)) _buildQuickQuestionsBar(quickQuestions),
              _buildInputArea(tokens),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(Message message) {
    final int tokens = Provider.of<int>(context);
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
                  color: message.isUserMessage ? Colors.blue.shade700 : Colors.green[700],
                ),
              ),
              const SizedBox(height: 4),
              Card(
                color: message.isUserMessage ? Colors.blue.shade700 : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.imagePath != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(message.imagePath!),
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      Text(
                        message.content,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: message.isUserMessage ? Colors.white : null,
                        ),
                      )

                      // MarkdownBody(
                      //   data: message.content,
                      //   styleSheet: MarkdownStyleSheet(
                      //     p: TextStyle(
                      //       fontSize: 16,
                      //       color: message.isUserMessage ? Colors.white : null,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (tokens <= 0 && !isPro)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUserMessage ? const Color.fromARGB(255, 44, 75, 106) : Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "You have reached your daily  limit. Upgrade to premium for  unlimited access",
                      ),
                      TextButton(
                        onPressed: () {
                          _showPaywallIfNeeded();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: message.isUserMessage ? Colors.blue[900] : Colors.green[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.lock_open,
                              color: Color.fromARGB(255, 209, 214, 217),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Unlock Premium',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: LoadingIndicator(
              indicatorType: Indicator.ballPulse,
              colors: [Colors.blue, Colors.red, Colors.green],
              strokeWidth: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestionsBar(List<String> quickQuestions) {
    return SizedBox(
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
              onPressed: () {
                _sendMessage(question, isPro);
              },
              child: Text(question),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputArea(int tokens) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: (tokens <= 0 && !isPro)
            ? const Column(children: [
                Text(
                  "You have 0 usage, watch an ad or subscribe",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0),
                )
              ])
            : Row(
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
                        _sendMessage(_messageController.text, isPro);
                        _messageController.clear();
                      }
                    },
                  ),
                ],
              ));
  }

  void _sendMessage(String message, bool isPro) {
    // Random random = Random();
    final language = Provider.of<LocaleProvider>(context, listen: false).selectedLanguage;
    // final int tokens = Provider.of<int>(context);
    // int randomNumber = random.nextInt(tokens);
    if (!isPro) _showContinuePlayingDialog(context);
    setState(() {
      _isLoading = true;
    });

    context.read<ChatNotifier>().sendMessage(widget.chatId, message, language).then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }
}
