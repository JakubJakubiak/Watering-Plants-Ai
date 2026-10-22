import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plantsai/app.dart';
import 'package:plantsai/core/analytics.dart';
import 'package:plantsai/core/theme.dart';
import 'package:plantsai/data/chat_repository.dart';
import 'package:plantsai/data/plant_care.dart';
import 'package:plantsai/database/chat_database.dart';
import 'package:plantsai/features/scan/scan_flow.dart';
import 'package:plantsai/widgets/common.dart';
import 'package:plantsai/widgets/plant_image.dart';

import 'care_labels.dart';
import 'plant_detail_page.dart';

class GardenPage extends StatelessWidget {
  const GardenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: StreamBuilder<List<Chat>>(
        stream: context.read<ChatRepository>().watchGarden(),
        builder: (context, snapshot) {
          final plants = snapshot.data ?? const <Chat>[];
          final due = plants.where((p) => p.needsWater).toList()
            ..sort((a, b) => (a.daysUntilWatering() ?? 0).compareTo(b.daysUntilWatering() ?? 0));

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(l10n.navGarden),
                actions: [
                  if (plants.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Center(child: Text(l10n.plantsCount(plants.length))),
                    ),
                ],
              ),
              if (snapshot.hasData && plants.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.yard_rounded,
                    title: l10n.gardenEmpty,
                    message: l10n.gardenEmptyHint,
                    action: FilledButton.icon(
                      onPressed: () => startPhotoScan(context, ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_rounded),
                      label: Text(l10n.scanPlant),
                    ),
                  ),
                ),
              if (plants.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: _DueBanner(due: due),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverGrid.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 240,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: plants.length,
                    itemBuilder: (context, i) => _PlantCard(plant: plants[i])
                        .animate()
                        .fadeIn(delay: (40 * i).ms)
                        .scaleXY(begin: 0.95, curve: Curves.easeOut),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DueBanner extends StatelessWidget {
  const _DueBanner({required this.due});

  final List<Chat> due;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final allGood = due.isEmpty;
    final color = allGood ? PlantColors.leaf : PlantColors.water;

    return Card(
      color: color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(allGood ? Icons.check_circle_rounded : Icons.water_drop_rounded, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    allGood ? l10n.allWatered : l10n.dueCount(due.length),
                    style: theme.textTheme.titleMedium?.copyWith(color: color),
                  ),
                ),
              ],
            ),
            if (!allGood) ...[
              const SizedBox(height: 12),
              for (final plant in due.take(5)) _DueRow(plant: plant),
            ],
          ],
        ),
      ),
    );
  }
}

class _DueRow extends StatelessWidget {
  const _DueRow({required this.plant});

  final Chat plant;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final days = plant.daysUntilWatering() ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox.square(dimension: 40, child: PlantImage(plant.imagePath, radius: 12, iconSize: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plant.displayName, style: Theme.of(context).textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                Text(
                  l10n.wateringStatus(days),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: days < 0 ? PlantColors.danger : null),
                ),
              ],
            ),
          ),
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: () => waterPlant(context, plant),
            icon: const Icon(Icons.water_drop_rounded, size: 18),
            label: Text(l10n.waterNow),
          ),
        ],
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  const _PlantCard({required this.plant});

  final Chat plant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final days = plant.daysUntilWatering();
    final care = plant.plantCare;

    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PlantDetailPage(chatId: plant.id))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(tag: 'plant-${plant.id}', child: PlantImage(plant.imagePath, radius: 0, iconSize: 48)),
                  if (care != null)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: healthColor(care.health),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plant.displayName, style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(
                          days == null ? '' : l10n.wateringStatus(days),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: (days ?? 1) < 0 ? PlantColors.danger : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  WaterRing(progress: plant.waterProgress, size: 36, overdue: (days ?? 1) < 0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Zapisuje podlanie i pokazuje potwierdzenie.
Future<void> waterPlant(BuildContext context, Chat plant) async {
  final messenger = ScaffoldMessenger.of(context);
  final text = context.l10n.wateredToast(plant.displayName);
  HapticFeedback.lightImpact();
  await context.read<ChatRepository>().markWatered(plant.id);
  Analytics.plantWatered();
  messenger.showSnackBar(SnackBar(content: Text('💧 $text')));
}
