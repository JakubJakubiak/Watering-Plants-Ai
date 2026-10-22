import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Zdjęcia roślin trzymamy w katalogu dokumentów aplikacji, a w bazie zapisujemy
/// ścieżkę względną — na iOS ścieżka kontenera zmienia się po aktualizacji.
class AppPaths {
  static late String documents;

  static Future<void> init() async {
    documents = (await getApplicationDocumentsDirectory()).path;
  }

  /// Kopiuje zdjęcie (np. z cache croppera) do katalogu aplikacji.
  static Future<String> persistImage(String sourcePath) async {
    final dir = Directory(p.join(documents, 'plants'));
    await dir.create(recursive: true);
    final name = 'plant_${DateTime.now().millisecondsSinceEpoch}${p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath)}';
    await File(sourcePath).copy(p.join(dir.path, name));
    return p.join('plants', name);
  }

  /// Plik zdjęcia dla ścieżki z bazy (względnej albo starej, bezwzględnej).
  static File? resolve(String? stored) {
    if (stored == null || stored.isEmpty) return null;
    if (p.isAbsolute(stored)) {
      final file = File(stored);
      if (file.existsSync()) return file;
      // Stara ścieżka bezwzględna z innego kontenera — spróbuj po nazwie pliku.
      final moved = File(p.join(documents, p.basename(stored)));
      return moved.existsSync() ? moved : null;
    }
    final file = File(p.join(documents, stored));
    return file.existsSync() ? file : null;
  }
}
