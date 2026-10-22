# Plant care: Identifier AI (Plants AI)

Flutter: rozpoznawanie roślin ze zdjęcia, porady AI i plan podlewania. Google Play: `com.inu.plantsai`.

## Architektura

- **Backend:** wspólny projekt Convex [`~/Git/ai-hub`](../ai-hub) (OpenAI, kredyty, Pro przez RevenueCat). Aplikacja łączy się przez pakiet `ai_hub_client` (`path: ../ai-hub/clients/dart`), więc oba repo muszą leżeć obok siebie.
- **Firebase:** tylko Analytics (`lib/core/analytics.dart`). Bez `google-services.json` / `GoogleService-Info.plist` aplikacja działa dalej, tylko bez statystyk.
- **Dane lokalne:** drift (`lib/database`): rozmowy, wiadomości, ogród (profil opieki, harmonogram podlewania) i historia podlewania.
- **UI:** Material 3, `lib/features/*` (scan, garden, chat, history, library, settings, paywall, onboarding).

```
lib/
  core/       konfiguracja, motyw, konto (ai-hub + RevenueCat), reklamy, analityka
  data/       ChatRepository, PlantCare/PlantReply
  database/   drift (schemat v4)
  features/   ekrany
  widgets/    wspólne komponenty
```

## Uruchomienie

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # po zmianach w lib/models
flutter run
```

Adres backendu i klucz klienta są w `lib/core/config.dart`. Można je nadpisać przy buildzie:

```bash
flutter run --dart-define=AI_HUB_URL=https://<deployment>.convex.site --dart-define=AI_HUB_CLIENT_KEY=pk_plantsai_...
```

Testy: `flutter test`.

## Sklep

Grafiki do Google Play generuje `python3 store/make_store_graphics.py` ze zrzutów w `store/source/` (zdjęcia roślin z Pexels). Wynik trafia do `store/google-play/`.

## Uwagi

- Stary kod (przed wersją 2.0) leży w `_legacy/` tylko do wglądu; analizator go pomija.
- iOS nie jest skonfigurowany (brak klucza RevenueCat, ID AdMob i pliku Firebase); aplikacja się uruchomi, ale bez zakupów i analityki.
