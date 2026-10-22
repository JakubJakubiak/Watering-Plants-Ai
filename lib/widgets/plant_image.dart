import 'package:flutter/material.dart';
import 'package:plantsai/core/app_paths.dart';

/// Zdjęcie rośliny z bazy albo zastępczy gradient z liściem.
class PlantImage extends StatelessWidget {
  const PlantImage(this.storedPath, {super.key, this.radius = 20, this.iconSize = 32});

  final String? storedPath;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final file = AppPaths.resolve(storedPath);
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: file != null
          ? Image.file(file, fit: BoxFit.cover, cacheWidth: 600, gaplessPlayback: true)
          : DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [scheme.primaryContainer, scheme.tertiaryContainer],
                ),
              ),
              child: Center(child: Icon(Icons.eco_rounded, size: iconSize, color: scheme.onPrimaryContainer)),
            ),
    );
  }
}
