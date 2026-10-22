import 'package:ai_hub_client/ai_hub_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plantsai/app.dart';
import 'package:plantsai/core/account_controller.dart';
import 'package:plantsai/core/ads.dart';
import 'package:plantsai/core/analytics.dart';
import 'package:plantsai/core/app_paths.dart';
import 'package:plantsai/core/locale_controller.dart';
import 'package:plantsai/data/chat_repository.dart';
import 'package:plantsai/database/chat_database.dart';
import 'package:plantsai/features/garden/plant_detail_page.dart';
import 'package:plantsai/widgets/credits.dart';
import 'package:plantsai/widgets/plant_image.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.chatId, this.askOnOpen = false});

  final int chatId;

  /// Nowa rozmowa: od razu wyślij pierwszą wiadomość do AI.
  final bool askOnOpen;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  late final ChatRepository _repository = context.read<ChatRepository>();
  late final Stream<Chat?> _chat = _repository.watchChat(widget.chatId);
  late final Stream<List<Message>> _messages = _repository.watchMessages(widget.chatId);

  bool _loading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (widget.askOnOpen) WidgetsBinding.instance.addPostFrameCallback((_) => _run(null));
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// [text] == null: ponów/wyślij istniejącą historię; inaczej dopisz wiadomość.
  Future<void> _run(String? text, {bool quick = false}) async {
    if (_loading) return;
    final account = context.read<AccountController>();
    if (!account.canChat) {
      await showCreditsSheet(context, source: 'chat');
      return;
    }
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final language = context.read<LocaleController>().languageName;
    final ads = context.read<AdsController>();
    final hadCare = (await _repository.watchChat(widget.chatId).first)?.care != null;

    setState(() {
      _loading = true;
      _failed = false;
    });
    _scrollToEnd();
    try {
      final reply = text == null
          ? await _repository.ask(widget.chatId, language: language)
          : await _repository.sendMessage(widget.chatId, text, language: language);
      if (text != null) Analytics.messageSent(quickQuestion: quick);
      if (!hadCare && reply.care != null) {
        Analytics.plantIdentified(name: reply.name, hasCare: true);
        messenger.showSnackBar(SnackBar(
          content: Text(l10n.addedToGarden),
          action: SnackBarAction(label: l10n.navGarden, onPressed: _openPlant),
        ));
        _maybeAskForReview();
      }
      ads.onAiRequest();
    } on AiHubException catch (e) {
      account.applyFromError(e);
      Analytics.aiError(e.code);
      if (!mounted) return;
      if (e.isOutOfCredits) {
        showCreditsSheet(context, source: 'chat_error');
      } else if (e.code == 'daily_limit') {
        messenger.showSnackBar(SnackBar(content: Text(l10n.dailyLimit)));
      } else {
        setState(() => _failed = true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
      _scrollToEnd();
    }
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    _run(text);
  }

  void _openPlant() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlantDetailPage(chatId: widget.chatId)));
  }

  Future<void> _maybeAskForReview() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt('identifiedPlants') ?? 0) + 1;
    await prefs.setInt('identifiedPlants', count);
    if (count == 3 && await InAppReview.instance.isAvailable()) {
      InAppReview.instance.requestReview();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(_scroll.position.maxScrollExtent, duration: 300.ms, curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Chat?>(
      stream: _chat,
      builder: (context, chatSnapshot) {
        final chat = chatSnapshot.data;
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: chat == null ? null : _ChatTitle(chat: chat),
            actions: [
              if (chat != null && chat.inGarden)
                IconButton(
                  tooltip: context.l10n.navGarden,
                  icon: const Icon(Icons.local_florist_rounded),
                  onPressed: _openPlant,
                ),
              const Padding(padding: EdgeInsets.only(right: 8), child: CreditsChip()),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<List<Message>>(
                  stream: _messages,
                  builder: (context, snapshot) {
                    final messages = snapshot.data ?? const <Message>[];
                    final waitingForReply = messages.isNotEmpty && messages.last.isUserMessage;
                    return ListView(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      children: [
                        for (final m in messages) _Bubble(message: m),
                        if (_loading) const _TypingIndicator(),
                        if (!_loading && (_failed || (waitingForReply && !widget.askOnOpen)))
                          _RetryCard(onRetry: () => _run(null)),
                      ],
                    );
                  },
                ),
              ),
              if (chat != null && chat.quickQuestions.isNotEmpty && !_loading)
                _QuickQuestions(questions: chat.quickQuestions, onTap: (q) => _run(q, quick: true)),
              _Composer(controller: _input, enabled: !_loading, onSend: _send),
            ],
          ),
        );
      },
    );
  }
}

class _ChatTitle extends StatelessWidget {
  const _ChatTitle({required this.chat});

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        if (chat.imagePath != null) ...[
          SizedBox.square(dimension: 40, child: PlantImage(chat.imagePath, radius: 12, iconSize: 20)),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(chat.name.isEmpty ? context.l10n.newChat : chat.name,
                  style: theme.textTheme.titleMedium, overflow: TextOverflow.ellipsis),
              if (chat.species != null)
                Text(
                  chat.species!,
                  style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: theme.colorScheme.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mine = message.isUserMessage;
    final image = AppPaths.resolve(message.imagePath);
    final maxWidth = MediaQuery.sizeOf(context).width * (mine ? 0.78 : 0.88);

    final bubble = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: mine ? scheme.primary : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(22),
          topRight: const Radius.circular(22),
          bottomLeft: Radius.circular(mine ? 22 : 6),
          bottomRight: Radius.circular(mine ? 6 : 22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(image, width: 220, height: 220, fit: BoxFit.cover, cacheWidth: 600),
            ),
            const SizedBox(height: 10),
          ],
          if (mine)
            Text(message.content, style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onPrimary))
          else
            MarkdownBody(
              data: message.content,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                listBullet: theme.textTheme.bodyLarge,
                strong: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!mine) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: scheme.primaryContainer,
              child: Icon(Icons.eco_rounded, size: 18, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: message.content));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.copied)));
              },
              child: bubble,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.08, curve: Curves.easeOut);
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: scheme.primaryContainer,
            child: Icon(Icons.eco_rounded, size: 18, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: scheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(22)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .fadeIn(delay: (150 * i).ms, duration: 300.ms)
                      .then()
                      .fadeOut(duration: 300.ms),
                const SizedBox(width: 10),
                Text(context.l10n.thinking, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RetryCard extends StatelessWidget {
  const _RetryCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.cloud_off_rounded, color: scheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(child: Text(context.l10n.aiError, style: TextStyle(color: scheme.onErrorContainer))),
            TextButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    ).animate().fadeIn().shakeX(hz: 3, amount: 3);
  }
}

class _QuickQuestions extends StatelessWidget {
  const _QuickQuestions({required this.questions, required this.onTap});

  final List<String> questions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: questions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => ActionChip(
          avatar: const Icon(Icons.auto_awesome_rounded, size: 16),
          label: Text(questions[i]),
          onPressed: () => onTap(questions[i]),
        ).animate().fadeIn(delay: (60 * i).ms).slideX(begin: 0.2),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.enabled, required this.onSend});

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => enabled ? onSend() : null,
                decoration: InputDecoration(hintText: context.l10n.typeMessage),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: enabled ? onSend : null,
              icon: const Icon(Icons.arrow_upward_rounded),
              style: IconButton.styleFrom(minimumSize: const Size(52, 52)),
            ),
          ],
        ),
      ),
    );
  }
}
