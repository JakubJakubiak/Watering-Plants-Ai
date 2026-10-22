// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Plants AI';

  @override
  String get camera => 'Aparat';

  @override
  String get gallery => 'Galeria';

  @override
  String get addCoins => 'Dodaj kredyty';

  @override
  String get unsubscribe => 'Anuluj subskrypcję';

  @override
  String get subscribe => 'Subskrybuj';

  @override
  String get chat => 'Nowy czat';

  @override
  String get chatHistory => 'Historia czatu';

  @override
  String get unlimitedAccess => 'Nieograniczony dostęp';

  @override
  String get upgradeNow => 'Ulepsz teraz';

  @override
  String get identifications => 'Nieograniczona identyfikacja roślin';

  @override
  String get limitlessChat => 'Nieograniczone wiadomości na czacie';

  @override
  String get tips => 'Stwórz własne AI';

  @override
  String get tips2 => 'Dobrze spędzony czas';

  @override
  String get removeAds => 'Bez reklam';

  @override
  String get navScan => 'Skanuj';

  @override
  String get navGarden => 'Ogród';

  @override
  String get navChats => 'Rozmowy';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get scanTitle => 'Co tu rośnie?';

  @override
  String get scanSubtitle =>
      'Zrób zdjęcie — AI rozpozna roślinę, oceni jej kondycję i zaplanuje podlewanie.';

  @override
  String get askExpert => 'Zapytaj eksperta od roślin';

  @override
  String get askExpertHint => 'np. Dlaczego liście monstery żółkną?';

  @override
  String get identifyPrompt =>
      'Co to za roślina? Jak się miewa i jak o nią dbać?';

  @override
  String get needsWaterToday => 'Do podlania';

  @override
  String get allWatered => 'Wszystkie rośliny są podlane';

  @override
  String get plantLibrary => 'Encyklopedia roślin';

  @override
  String plantLibrarySubtitle(int count) {
    return '$count gatunków z poradami';
  }

  @override
  String get tipsTitle => 'Jak zrobić dobre zdjęcie';

  @override
  String get tip1 => 'Jedna roślina w kadrze';

  @override
  String get tip2 => 'Światło dzienne, bez ostrych cieni';

  @override
  String get tip3 => 'Pokaż liście z bliska';

  @override
  String get gardenEmpty => 'Twój ogród jest pusty';

  @override
  String get gardenEmptyHint =>
      'Zeskanuj roślinę — pojawi się tu razem z planem podlewania.';

  @override
  String get scanPlant => 'Zeskanuj roślinę';

  @override
  String get waterNow => 'Podlane';

  @override
  String wateredToast(String name) {
    return '$name — podlane';
  }

  @override
  String waterIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Podlej za $days dni',
      one: 'Podlej jutro',
      zero: 'Podlej dziś',
    );
    return '$_temp0';
  }

  @override
  String overdue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Spóźnione o $days dni',
      one: 'Spóźnione o 1 dzień',
    );
    return '$_temp0';
  }

  @override
  String everyDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Co $days dni',
      one: 'Codziennie',
    );
    return '$_temp0';
  }

  @override
  String plantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rośliny',
      many: '$count roślin',
      few: '$count rośliny',
      one: '1 roślina',
      zero: 'Brak roślin',
    );
    return '$_temp0';
  }

  @override
  String dueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rośliny do podlania',
      many: '$count roślin do podlania',
      few: '$count rośliny do podlania',
      one: '1 roślina do podlania',
    );
    return '$_temp0';
  }

  @override
  String get wateringSchedule => 'Podlewanie';

  @override
  String get changeInterval => 'Zmień częstotliwość';

  @override
  String get waterEvery => 'Podlewaj co';

  @override
  String get daysUnit => 'dni';

  @override
  String get lastWatered => 'Ostatnio podlana';

  @override
  String get never => 'Nigdy';

  @override
  String get wateringHistory => 'Historia podlewania';

  @override
  String get careTitle => 'Pielęgnacja';

  @override
  String get light => 'Światło';

  @override
  String get humidity => 'Wilgotność';

  @override
  String get temperature => 'Temperatura';

  @override
  String get difficulty => 'Trudność';

  @override
  String get health => 'Kondycja';

  @override
  String get toxicToPets => 'Trująca dla zwierząt';

  @override
  String get safeForPets => 'Bezpieczna dla zwierząt';

  @override
  String get lightLow => 'Półcień';

  @override
  String get lightMedium => 'Umiarkowane światło';

  @override
  String get lightBrightIndirect => 'Jasne, rozproszone';

  @override
  String get lightFullSun => 'Pełne słońce';

  @override
  String get levelLow => 'Niska';

  @override
  String get levelMedium => 'Średnia';

  @override
  String get levelHigh => 'Wysoka';

  @override
  String get difficultyEasy => 'Łatwa';

  @override
  String get difficultyMedium => 'Średnia';

  @override
  String get difficultyHard => 'Trudna';

  @override
  String get healthHealthy => 'Zdrowa';

  @override
  String get healthNeedsAttention => 'Wymaga uwagi';

  @override
  String get healthSick => 'Chora';

  @override
  String get healthUnknown => 'Nieznana';

  @override
  String get openChat => 'Zapytaj o tę roślinę';

  @override
  String get removeFromGarden => 'Usuń z ogrodu';

  @override
  String get addToGarden => 'Dodaj do ogrodu';

  @override
  String get addedToGarden => 'Dodano do ogrodu';

  @override
  String get share => 'Udostępnij';

  @override
  String get delete => 'Usuń';

  @override
  String get cancel => 'Anuluj';

  @override
  String get save => 'Zapisz';

  @override
  String get deleteChatConfirm => 'Usunąć tę rozmowę?';

  @override
  String get deleteChatBody =>
      'Wiadomości i zdjęcie zostaną usunięte z tego urządzenia.';

  @override
  String get deleted => 'Usunięto';

  @override
  String get chatsEmpty => 'Brak rozmów';

  @override
  String get chatsEmptyHint =>
      'Zeskanuj roślinę albo zadaj pytanie ekspertowi.';

  @override
  String get search => 'Szukaj';

  @override
  String get typeMessage => 'Zapytaj o swoją roślinę…';

  @override
  String get thinking => 'Analizuję…';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get aiError =>
      'Nie udało się uzyskać odpowiedzi. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get copied => 'Skopiowano';

  @override
  String get newChat => 'Nowa rozmowa';

  @override
  String get outOfCreditsTitle => 'Skończyły się kredyty';

  @override
  String outOfCreditsBody(int daily, int reward) {
    return 'Codziennie dostajesz $daily darmowe kredyty. Obejrzyj krótką reklamę (+$reward) albo przejdź na Pro bez limitów.';
  }

  @override
  String watchAd(int reward) {
    return 'Obejrzyj reklamę (+$reward)';
  }

  @override
  String get adNotReady => 'Reklama jeszcze się ładuje — spróbuj za chwilę.';

  @override
  String get rewardLimit => 'Osiągnięto dzienny limit reklam. Wróć jutro!';

  @override
  String creditsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dodano $count kredytu',
      many: 'Dodano $count kredytów',
      few: 'Dodano $count kredyty',
      one: 'Dodano 1 kredyt',
    );
    return '$_temp0';
  }

  @override
  String credits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kredytu',
      many: '$count kredytów',
      few: '$count kredyty',
      one: '1 kredyt',
    );
    return '$_temp0';
  }

  @override
  String creditsRenew(int daily) {
    return '$daily darmowe kredyty każdego dnia';
  }

  @override
  String get dailyLimit => 'Osiągnięto dzienny limit. Spróbuj jutro.';

  @override
  String get goPro => 'Przejdź na Pro';

  @override
  String get proActive => 'Pro jest aktywne';

  @override
  String get proSubtitle => 'Bez limitu skanów i rozmów, bez reklam';

  @override
  String get manageSubscription => 'Zarządzaj subskrypcją';

  @override
  String get restorePurchases => 'Przywróć zakupy';

  @override
  String get purchasesRestored => 'Przywrócono zakupy';

  @override
  String get language => 'Język';

  @override
  String get privacyPolicy => 'Regulamin i prywatność';

  @override
  String get rateApp => 'Oceń aplikację';

  @override
  String version(String version) {
    return 'Wersja $version';
  }

  @override
  String get account => 'Konto';

  @override
  String get appSection => 'Aplikacja';

  @override
  String get offline => 'Brak połączenia z serwerem';

  @override
  String get reconnect => 'Połącz ponownie';

  @override
  String get theme => 'Motyw';

  @override
  String get themeSystem => 'Systemowy';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get proBenefitScans => 'Nielimitowane skanowanie roślin';

  @override
  String get proBenefitChat => 'Nielimitowane rozmowy z ekspertem';

  @override
  String get proBenefitGarden => 'Plany podlewania dla całego ogrodu';

  @override
  String get proBenefitNoAds => 'Bez reklam';

  @override
  String get paywallTitle => 'Plants AI Pro';

  @override
  String get paywallSubtitle =>
      'Wszystko, czego potrzebują Twoje rośliny — bez limitów.';

  @override
  String get yearly => 'Rocznie';

  @override
  String get weekly => 'Tygodniowo';

  @override
  String get monthly => 'Miesięcznie';

  @override
  String perYear(String price) {
    return '$price / rok';
  }

  @override
  String perWeek(String price) {
    return '$price / tydzień';
  }

  @override
  String perMonth(String price) {
    return '$price / miesiąc';
  }

  @override
  String savePercent(int percent) {
    return 'OSZCZĘDZASZ $percent%';
  }

  @override
  String get freeTrial => 'Darmowy okres próbny';

  @override
  String get continueLabel => 'Kontynuuj';

  @override
  String get paywallUnavailable => 'Subskrypcje są teraz niedostępne.';

  @override
  String get onboarding1Title => 'Rozpoznaj każdą roślinę';

  @override
  String get onboarding1Body =>
      'Zrób zdjęcie — AI powie, co to za roślina i jak się miewa.';

  @override
  String get onboarding2Title => 'Nie zapomnij o podlewaniu';

  @override
  String get onboarding2Body =>
      'Każda zeskanowana roślina trafia do ogrodu z własnym planem podlewania.';

  @override
  String get onboarding3Title => 'Twój ekspert od roślin';

  @override
  String get onboarding3Body =>
      'Pytaj o szkodniki, ziemię, światło i wszystko inne.';

  @override
  String get next => 'Dalej';

  @override
  String get getStarted => 'Zaczynamy';

  @override
  String get skip => 'Pomiń';

  @override
  String get cropImage => 'Przytnij zdjęcie';

  @override
  String get noResults => 'Brak wyników';

  @override
  String get today => 'Dziś';

  @override
  String get yesterday => 'Wczoraj';
}
