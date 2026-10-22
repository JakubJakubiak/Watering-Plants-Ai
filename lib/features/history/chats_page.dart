import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:plantsai/app.dart';
import 'package:plantsai/data/chat_repository.dart';
import 'package:plantsai/data/plant_care.dart';
import 'package:plantsai/database/chat_database.dart';
import 'package:plantsai/features/chat/chat_page.dart';
import 'package:plantsai/features/garden/plant_detail_page.dart';
import 'package:plantsai/widgets/common.dart';
import 'package:plantsai/widgets/plant_image.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repository = context.read<ChatRepository>();
    return Scaffold(
      body: StreamBuilder<List<Chat>>(
        stream: repository.watchChats(),
        builder: (context, snapshot) {
          final all = snapshot.data ?? const <Chat>[];
          final chats = _query.isEmpty
              ? all
              : all
                  .where((c) =>
                      c.name.toLowerCase().contains(_query) || (c.lastMessage ?? '').toLowerCase().contains(_query))
                  .toList();
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(title: Text(l10n.navChats)),
              if (all.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: SearchBar(
                      hintText: l10n.search,
                      leading: const Icon(Icons.search_rounded),
                      elevation: const WidgetStatePropertyAll(0),
                      onChanged: (q) => setState(() => _query = q.trim().toLowerCase()),
                    ),
                  ),
                ),
              if (snapshot.hasData && all.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: l10n.chatsEmpty,
                    message: l10n.chatsEmptyHint,
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                sliver: SliverList.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, i) => _ChatTile(chat: chats[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({required this.chat});

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final sameDay = chat.createdAt.year == now.year && chat.createdAt.month == now.month && chat.createdAt.day == now.day;
    final date = sameDay ? DateFormat.Hm(locale).format(chat.createdAt) : DateFormat.MMMd(locale).format(chat.createdAt);

    return Dismissible(
      key: ValueKey('chat-${chat.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(context),
      onDismissed: (_) {
        context.read<ChatRepository>().deleteChat(chat.id);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.deleted)));
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(Icons.delete_rounded, color: theme.colorScheme.onErrorContainer),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: SizedBox.square(
          dimension: 52,
          child: chat.imagePath != null
              ? PlantImage(chat.imagePath, radius: 16, iconSize: 22)
              : CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Icon(Icons.forum_rounded, color: theme.colorScheme.onSecondaryContainer),
                ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(chat.name.isEmpty ? l10n.newChat : chat.displayName,
                  style: theme.textTheme.titleMedium, overflow: TextOverflow.ellipsis),
            ),
            if (chat.inGarden) Icon(Icons.local_florist_rounded, size: 16, color: theme.colorScheme.primary),
          ],
        ),
        subtitle: Text(plainPreview(chat.lastMessage), maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Text(date, style: theme.textTheme.labelSmall),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatPage(chatId: chat.id))),
      ),
    );
  }
}
