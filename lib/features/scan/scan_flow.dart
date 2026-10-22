import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:plantsai/app.dart';
import 'package:plantsai/core/account_controller.dart';
import 'package:plantsai/core/analytics.dart';
import 'package:plantsai/core/app_paths.dart';
import 'package:plantsai/data/chat_repository.dart';
import 'package:plantsai/features/chat/chat_page.dart';
import 'package:plantsai/widgets/credits.dart';

/// Zdjęcie → przycięcie → nowa rozmowa → ekran czatu z pierwszą analizą.
Future<void> startPhotoScan(BuildContext context, ImageSource source) async {
  final account = context.read<AccountController>();
  if (!account.canChat) {
    await showCreditsSheet(context, source: 'scan');
    return;
  }
  Analytics.scanStarted(source.name);
  final navigator = Navigator.of(context);
  final repository = context.read<ChatRepository>();
  final l10n = context.l10n;
  final scheme = Theme.of(context).colorScheme;

  final picked = await ImagePicker().pickImage(source: source, maxWidth: 1600, maxHeight: 1600, imageQuality: 92);
  if (picked == null) return;

  final cropped = await ImageCropper().cropImage(
    sourcePath: picked.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    maxWidth: 768,
    maxHeight: 768,
    compressQuality: 85,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: l10n.cropImage,
        toolbarColor: scheme.surface,
        toolbarWidgetColor: scheme.onSurface,
        activeControlsWidgetColor: scheme.primary,
        lockAspectRatio: false,
      ),
      IOSUiSettings(title: l10n.cropImage),
    ],
  );
  if (cropped == null) return;

  final stored = await AppPaths.persistImage(cropped.path);
  final chat = await repository.createChat(imagePath: stored, prompt: l10n.identifyPrompt);
  await navigator.push(MaterialPageRoute(builder: (_) => ChatPage(chatId: chat.id, askOnOpen: true)));
}

/// Pytanie tekstowe bez zdjęcia.
Future<void> startTextChat(BuildContext context, String question) async {
  final account = context.read<AccountController>();
  if (!account.canChat) {
    await showCreditsSheet(context, source: 'ask');
    return;
  }
  final navigator = Navigator.of(context);
  final chat = await context.read<ChatRepository>().createChat(prompt: question);
  await navigator.push(MaterialPageRoute(builder: (_) => ChatPage(chatId: chat.id, askOnOpen: true)));
}
