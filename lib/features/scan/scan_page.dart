import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:plantsai/app.dart';
import 'package:plantsai/core/account_controller.dart';
import 'package:plantsai/core/theme.dart';
import 'package:plantsai/data/chat_repository.dart';
import 'package:plantsai/data/plant_care.dart';
import 'package:plantsai/database/chat_database.dart';
import 'package:plantsai/features/garden/care_labels.dart';
import 'package:plantsai/features/garden/garden_page.dart';
import 'package:plantsai/features/garden/plant_detail_page.dart';
import 'package:plantsai/features/library/library_page.dart';
import 'package:plantsai/widgets/common.dart';
import 'package:plantsai/widgets/credits.dart';
import 'package:plantsai/widgets/plant_image.dart';

import 'scan_flow.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final account = context.watch<AccountController>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.eco_rounded, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(l10n.appTitle),
          ],
        ),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: CreditsChip())],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (account.error != null && !account.connecting) ...[
            _OfflineBanner(onRetry: account.connect),
            const SizedBox(height: 12),
          ],
          const _HeroScanCard(),
          const SizedBox(height: 20),
          const _DueToday(),
          const _AskExpertCard(),
          const SizedBox(height: 20),
          const _LibraryCard(),
          const SizedBox(height: 20),
          SectionHeader(l10n.tipsTitle),
          Row(
            children: [
              Expanded(child: _TipTile(icon: Icons.filter_center_focus_rounded, text: l10n.tip1)),
              const SizedBox(width: 10),
              Expanded(child: _TipTile(icon: Icons.wb_sunny_rounded, text: l10n.tip2)),
              const SizedBox(width: 10),
              Expanded(child: _TipTile(icon: Icons.zoom_in_rounded, text: l10n.tip3)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroScanCard extends StatelessWidget {
  const _HeroScanCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onHero = Colors.white;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F6B45), Color(0xFF3E9B63), Color(0xFF7CC08A)],
        ),
        boxShadow: [BoxShadow(color: PlantColors.leaf.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -20,
            child: Icon(Icons.eco_rounded, size: 190, color: Colors.white.withValues(alpha: 0.12))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .rotate(begin: -0.02, end: 0.02, duration: 3.seconds, curve: Curves.easeInOut),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.scanTitle, style: theme.textTheme.headlineMedium?.copyWith(color: onHero)),
                const SizedBox(height: 8),
                Text(l10n.scanSubtitle, style: theme.textTheme.bodyLarge?.copyWith(color: onHero.withValues(alpha: 0.9))),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: scheme.primary),
                        onPressed: () => startPhotoScan(context, ImageSource.camera),
                        icon: const Icon(Icons.photo_camera_rounded),
                        label: Text(l10n.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white70, width: 1.5),
                        ),
                        onPressed: () => startPhotoScan(context, ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_rounded),
                        label: Text(l10n.gallery),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }
}

class _DueToday extends StatelessWidget {
  const _DueToday();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StreamBuilder<List<Chat>>(
      stream: context.read<ChatRepository>().watchGarden(),
      builder: (context, snapshot) {
        final due = (snapshot.data ?? const <Chat>[]).where((p) => p.needsWater).toList();
        if (due.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(l10n.needsWaterToday, trailing: Text(l10n.dueCount(due.length))),
              SizedBox(
                height: 172,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: due.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => _DueCard(plant: due[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DueCard extends StatelessWidget {
  const _DueCard({required this.plant});

  final Chat plant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = plant.daysUntilWatering() ?? 0;
    return SizedBox(
      width: 140,
      child: Card(
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlantDetailPage(chatId: plant.id))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: SizedBox(width: double.infinity, child: PlantImage(plant.imagePath, radius: 0))),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 4, 4),
                child: Text(plant.displayName, style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 4, 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.wateringStatus(days),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(color: days < 0 ? PlantColors.danger : PlantColors.water),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      color: PlantColors.water,
                      icon: const Icon(Icons.water_drop_rounded),
                      onPressed: () => waterPlant(context, plant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AskExpertCard extends StatefulWidget {
  const _AskExpertCard();

  @override
  State<_AskExpertCard> createState() => _AskExpertCardState();
}

class _AskExpertCardState extends State<_AskExpertCard> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final question = _controller.text.trim();
    if (question.isEmpty) return;
    _controller.clear();
    FocusScope.of(context).unfocus();
    startTextChat(context, question);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Icon(Icons.forum_rounded, color: theme.colorScheme.onSecondaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.askExpert, style: theme.textTheme.titleMedium)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 3,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: l10n.askExpertHint,
                fillColor: theme.colorScheme.surface,
                suffixIcon: IconButton(icon: const Icon(Icons.arrow_upward_rounded), onPressed: _submit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LibraryPage())),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: theme.colorScheme.tertiaryContainer, borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.menu_book_rounded, color: theme.colorScheme.onTertiaryContainer),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.plantLibrary, style: theme.textTheme.titleMedium),
                    FutureBuilder<int>(
                      future: LibraryPage.count(context),
                      builder: (context, snapshot) => Text(
                        snapshot.hasData ? l10n.plantLibrarySubtitle(snapshot.data!) : '',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipTile extends StatelessWidget {
  const _TipTile({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(text, style: theme.textTheme.bodySmall, maxLines: 3),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer,
      child: ListTile(
        leading: Icon(Icons.wifi_off_rounded, color: scheme.onErrorContainer),
        title: Text(context.l10n.offline, style: TextStyle(color: scheme.onErrorContainer)),
        trailing: TextButton(onPressed: onRetry, child: Text(context.l10n.reconnect)),
      ),
    );
  }
}
