import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:plantsai/app.dart';
import 'package:plantsai/core/analytics.dart';
import 'package:plantsai/features/scan/scan_flow.dart';
import 'package:plantsai/widgets/common.dart';

/// Wpis lokalnej encyklopedii (assets/data/plants_library.json).
class LibraryPlant {
  const LibraryPlant({required this.name, required this.image, required this.details});

  final String name;
  final String image;
  final Map<String, String> details;

  String get subtitle => details['Family'] ?? details['The family'] ?? details['Life form'] ?? '';

  factory LibraryPlant.fromJson(Map<String, dynamic> json) => LibraryPlant(
        name: (json['name'] as String? ?? '').trim(),
        image: json['image'] as String? ?? '',
        details: {
          for (final e in (json['details'] as Map? ?? const {}).entries)
            if ('${e.key}'.trim().length > 1 && '${e.value}'.trim().isNotEmpty) '${e.key}'.trim(): '${e.value}'.trim(),
        },
      );
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  static Future<List<LibraryPlant>>? _cache;

  static Future<List<LibraryPlant>> load(BuildContext context) {
    final bundle = DefaultAssetBundle.of(context);
    return _cache ??= bundle.loadString('assets/data/plants_library.json').then((raw) {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>().map(LibraryPlant.fromJson).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  static Future<int> count(BuildContext context) => load(context).then((l) => l.length);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late final Future<List<LibraryPlant>> _plants = LibraryPage.load(context);
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.plantLibrary)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SearchBar(
              hintText: l10n.search,
              leading: const Icon(Icons.search_rounded),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (q) => setState(() => _query = q.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<LibraryPlant>>(
              future: _plants,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final plants = _query.isEmpty
                    ? snapshot.data!
                    : snapshot.data!.where((p) => p.name.toLowerCase().contains(_query)).toList();
                if (plants.isEmpty) {
                  return EmptyState(icon: Icons.search_off_rounded, title: l10n.noResults, message: '');
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: plants.length,
                  itemBuilder: (context, i) => _LibraryTile(plant: plants[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryTile extends StatelessWidget {
  const _LibraryTile({required this.plant});

  final LibraryPlant plant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: () {
          Analytics.libraryOpened(plant.name);
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => LibraryDetailPage(plant: plant)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'lib-${plant.name}',
                child: _NetworkPlantImage(url: plant.image),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plant.name, style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (plant.subtitle.isNotEmpty)
                    Text(
                      plant.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkPlantImage extends StatelessWidget {
  const _NetworkPlantImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(child: Icon(Icons.local_florist_rounded, color: scheme.outline, size: 36)),
    );
    if (url.isEmpty) return placeholder;
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      memCacheWidth: 500,
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => placeholder,
    );
  }
}

class LibraryDetailPage extends StatelessWidget {
  const LibraryDetailPage({super.key, required this.plant});

  final LibraryPlant plant;

  static const _icons = {
    'Watering': Icons.water_drop_rounded,
    'Lighting': Icons.wb_sunny_rounded,
    'Temperature': Icons.thermostat_rounded,
    'Humidity': Icons.water_rounded,
    'Moisture': Icons.water_rounded,
    'The soil': Icons.grass_rounded,
    'Soil': Icons.grass_rounded,
    'Toxicity': Icons.warning_amber_rounded,
    'Bloom': Icons.local_florist_rounded,
    'Flowering': Icons.local_florist_rounded,
    'Family': Icons.account_tree_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(plant.name),
              background: Hero(tag: 'lib-${plant.name}', child: _NetworkPlantImage(url: plant.image)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList.list(
              children: [
                FilledButton.icon(
                  onPressed: () => startTextChat(context, '${plant.name}: ${l10n.identifyPrompt}'),
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: Text(l10n.askExpert),
                ),
                const SizedBox(height: 16),
                for (final entry in plant.details.entries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(_icons[entry.key] ?? Icons.info_outline_rounded, color: theme.colorScheme.primary, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.key, style: theme.textTheme.titleSmall),
                                  const SizedBox(height: 4),
                                  Text(entry.value, style: theme.textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
