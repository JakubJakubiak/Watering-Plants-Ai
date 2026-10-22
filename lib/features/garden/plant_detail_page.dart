import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:plantsai/app.dart';
import 'package:plantsai/core/analytics.dart';
import 'package:plantsai/core/theme.dart';
import 'package:plantsai/data/chat_repository.dart';
import 'package:plantsai/data/plant_care.dart';
import 'package:plantsai/database/chat_database.dart';
import 'package:plantsai/features/chat/chat_page.dart';
import 'package:plantsai/widgets/common.dart';
import 'package:plantsai/widgets/plant_image.dart';

import 'care_labels.dart';
import 'garden_page.dart';

class PlantDetailPage extends StatelessWidget {
  const PlantDetailPage({super.key, required this.chatId});

  final int chatId;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<ChatRepository>();
    return StreamBuilder<Chat?>(
      stream: repository.watchChat(chatId),
      builder: (context, snapshot) {
        final plant = snapshot.data;
        if (plant == null) {
          return Scaffold(
            appBar: AppBar(),
            body: snapshot.connectionState == ConnectionState.waiting ? const Center(child: CircularProgressIndicator()) : null,
          );
        }
        return _PlantView(plant: plant);
      },
    );
  }
}

class _PlantView extends StatelessWidget {
  const _PlantView({required this.plant});

  final Chat plant;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final care = plant.plantCare;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            stretch: true,
            actions: [
              IconButton(
                tooltip: l10n.share,
                icon: const Icon(Icons.ios_share_rounded),
                onPressed: () => _share(context),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _onMenu(context, value),
                itemBuilder: (_) => [
                  if (plant.inGarden)
                    PopupMenuItem(value: 'remove', child: Text(l10n.removeFromGarden))
                  else
                    PopupMenuItem(value: 'add', child: Text(l10n.addToGarden)),
                  PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(tag: 'plant-${plant.id}', child: PlantImage(plant.imagePath, radius: 0, iconSize: 72)),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black38, Colors.transparent, Colors.black54],
                        stops: [0, 0.4, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plant.displayName,
                            style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white)),
                        if (plant.species != null)
                          Text(plant.species!,
                              style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList.list(
              children: [
                if (care != null && care.healthNote.isNotEmpty) ...[
                  _HealthCard(care: care),
                  const SizedBox(height: 12),
                ],
                if (plant.inGarden) ...[
                  _WateringCard(plant: plant),
                  const SizedBox(height: 12),
                ],
                FilledButton.icon(
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => ChatPage(chatId: plant.id))),
                  icon: const Icon(Icons.forum_rounded),
                  label: Text(l10n.openChat),
                ),
                if (care != null) ...[
                  const SizedBox(height: 12),
                  SectionHeader(l10n.careTitle),
                  _CareGrid(care: care),
                ],
                if (plant.inGarden) _WateringHistory(chatId: plant.id),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _share(BuildContext context) {
    final l10n = context.l10n;
    final care = plant.plantCare;
    final lines = [
      '🌿 ${plant.displayName}${plant.species == null ? '' : ' (${plant.species})'}',
      if (care != null) ...[
        '💧 ${l10n.everyDays(plant.wateringDays ?? care.wateringDays)}',
        '☀️ ${l10n.lightLabel(care.light)}',
        '🌡️ ${care.temperature}',
      ],
      '',
      'Plants AI',
    ];
    Analytics.plantShared();
    SharePlus.instance.share(ShareParams(text: lines.join('\n')));
  }

  Future<void> _onMenu(BuildContext context, String value) async {
    final repository = context.read<ChatRepository>();
    final navigator = Navigator.of(context);
    final l10n = context.l10n;
    switch (value) {
      case 'add':
        await repository.setInGarden(plant.id, true);
      case 'remove':
        await repository.setInGarden(plant.id, false);
        Analytics.plantRemoved();
      case 'delete':
        final confirmed = await confirmDelete(context);
        if (!confirmed) return;
        navigator.pop();
        await repository.deleteChat(plant.id);
        Analytics.plantRemoved();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.deleted)));
        }
    }
  }
}

Future<bool> confirmDelete(BuildContext context) async {
  final l10n = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.delete_outline_rounded),
      title: Text(l10n.deleteChatConfirm),
      content: Text(l10n.deleteChatBody),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, minimumSize: const Size(0, 40)),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.care});

  final PlantCare care;

  @override
  Widget build(BuildContext context) {
    final color = healthColor(care.health);
    final theme = Theme.of(context);
    return Card(
      color: color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(care.health == 'healthy' ? Icons.favorite_rounded : Icons.healing_rounded, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.healthLabel(care.health), style: theme.textTheme.titleMedium?.copyWith(color: color)),
                  const SizedBox(height: 4),
                  Text(care.healthNote, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WateringCard extends StatelessWidget {
  const _WateringCard({required this.plant});

  final Chat plant;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final days = plant.daysUntilWatering();
    final interval = plant.wateringDays ?? 7;
    final last = plant.lastWateredAt;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                WaterRing(progress: plant.waterProgress, size: 64, overdue: (days ?? 1) < 0),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.wateringSchedule, style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      Text(
                        days == null ? l10n.everyDays(interval) : l10n.wateringStatus(days),
                        style: theme.textTheme.titleLarge?.copyWith(color: (days ?? 1) < 0 ? PlantColors.danger : null),
                      ),
                      Text(
                        '${l10n.everyDays(interval)} · ${l10n.lastWatered}: ${last == null ? l10n.never : _relativeDay(context, last)}',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editInterval(context, interval),
                    icon: const Icon(Icons.tune_rounded),
                    label: Text(l10n.changeInterval, overflow: TextOverflow.ellipsis),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: PlantColors.water, foregroundColor: Colors.white),
                    onPressed: () => waterPlant(context, plant),
                    icon: const Icon(Icons.water_drop_rounded),
                    label: Text(l10n.waterNow),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editInterval(BuildContext context, int current) async {
    final repository = context.read<ChatRepository>();
    final days = await showModalBottomSheet<int>(
      context: context,
      builder: (_) => _IntervalSheet(initial: current),
    );
    if (days != null) await repository.setWateringDays(plant.id, days);
  }
}

class _IntervalSheet extends StatefulWidget {
  const _IntervalSheet({required this.initial});

  final int initial;

  @override
  State<_IntervalSheet> createState() => _IntervalSheetState();
}

class _IntervalSheetState extends State<_IntervalSheet> {
  late double _days = widget.initial.clamp(1, 30).toDouble();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.waterEvery, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('${_days.round()} ${l10n.daysUnit}', style: theme.textTheme.displaySmall?.copyWith(color: PlantColors.water)),
            Slider(
              value: _days,
              min: 1,
              max: 30,
              divisions: 29,
              activeColor: PlantColors.water,
              label: '${_days.round()}',
              onChanged: (v) => setState(() => _days = v),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_days.round()),
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareGrid extends StatelessWidget {
  const _CareGrid({required this.care});

  final PlantCare care;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tiles = [
      (lightIcon(care.light), l10n.light, l10n.lightLabel(care.light), PlantColors.sun),
      (Icons.water_rounded, l10n.humidity, l10n.levelLabel(care.humidity), PlantColors.water),
      (Icons.thermostat_rounded, l10n.temperature, care.temperature, PlantColors.danger),
      (Icons.spa_rounded, l10n.difficulty, l10n.difficultyLabel(care.difficulty), PlantColors.leaf),
    ];
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: [
            for (final (icon, label, value, color) in tiles)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(icon, color: color),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  )),
                          Text(value, style: Theme.of(context).textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: InfoPill(
            icon: care.toxicToPets ? Icons.warning_amber_rounded : Icons.pets_rounded,
            label: care.toxicToPets ? l10n.toxicToPets : l10n.safeForPets,
            color: care.toxicToPets ? PlantColors.danger : PlantColors.leaf,
          ),
        ),
      ],
    );
  }
}

class _WateringHistory extends StatelessWidget {
  const _WateringHistory({required this.chatId});

  final int chatId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WaterLog>>(
      stream: context.read<ChatRepository>().watchWaterLogs(chatId),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? const <WaterLog>[];
        if (logs.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            SectionHeader(context.l10n.wateringHistory),
            Card(
              child: Column(
                children: [
                  for (final log in logs.take(10))
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.water_drop_outlined, color: PlantColors.water),
                      title: Text(_relativeDay(context, log.wateredAt)),
                      trailing: Text(DateFormat.Hm(Localizations.localeOf(context).toString()).format(log.wateredAt)),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

String _relativeDay(BuildContext context, DateTime date) {
  final l10n = context.l10n;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return l10n.today;
  if (diff == 1) return l10n.yesterday;
  return DateFormat.MMMd(Localizations.localeOf(context).toString()).format(date);
}
