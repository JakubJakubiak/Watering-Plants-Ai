// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Plants AI';

  @override
  String get camera => 'カメラ';

  @override
  String get gallery => 'ギャラリー';

  @override
  String get addCoins => 'コインを追加';

  @override
  String get unsubscribe => '登録解除';

  @override
  String get subscribe => '購読';

  @override
  String get chat => '新しいチャット';

  @override
  String get chatHistory => 'チャット履歴';

  @override
  String get unlimitedAccess => '無制限アクセス';

  @override
  String get upgradeNow => '今すぐアップグレード';

  @override
  String get identifications => '植物の無制限識別';

  @override
  String get limitlessChat => '無制限チャットメッセージ';

  @override
  String get tips => '自分のAIを作成する';

  @override
  String get tips2 => 'よく過ごした時間';

  @override
  String get removeAds => '迷惑なペイウォールを削除';

  @override
  String get navScan => 'Scan';

  @override
  String get navGarden => 'Garden';

  @override
  String get navChats => 'Chats';

  @override
  String get navSettings => 'Settings';

  @override
  String get scanTitle => 'What\'s growing here?';

  @override
  String get scanSubtitle =>
      'Snap a photo — AI identifies the plant, checks its health and plans the watering.';

  @override
  String get askExpert => 'Ask the plant expert';

  @override
  String get askExpertHint =>
      'e.g. Why are my monstera\'s leaves turning yellow?';

  @override
  String get identifyPrompt =>
      'What plant is this? How is it doing and how should I care for it?';

  @override
  String get needsWaterToday => 'Needs water';

  @override
  String get allWatered => 'All your plants are watered';

  @override
  String get plantLibrary => 'Plant library';

  @override
  String plantLibrarySubtitle(int count) {
    return '$count species with care guides';
  }

  @override
  String get tipsTitle => 'Tips for a great scan';

  @override
  String get tip1 => 'One plant in the frame';

  @override
  String get tip2 => 'Daylight, no harsh shadows';

  @override
  String get tip3 => 'Show the leaves up close';

  @override
  String get gardenEmpty => 'Your garden is empty';

  @override
  String get gardenEmptyHint =>
      'Scan a plant and it will appear here with its own watering plan.';

  @override
  String get scanPlant => 'Scan a plant';

  @override
  String get waterNow => 'Watered';

  @override
  String wateredToast(String name) {
    return '$name watered';
  }

  @override
  String waterIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Water in $days days',
      one: 'Water tomorrow',
      zero: 'Water today',
    );
    return '$_temp0';
  }

  @override
  String overdue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days overdue',
      one: '1 day overdue',
    );
    return '$_temp0';
  }

  @override
  String everyDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Every $days days',
      one: 'Every day',
    );
    return '$_temp0';
  }

  @override
  String plantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plants',
      one: '1 plant',
      zero: 'No plants',
    );
    return '$_temp0';
  }

  @override
  String dueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plants need water',
      one: '1 plant needs water',
    );
    return '$_temp0';
  }

  @override
  String get wateringSchedule => 'Watering';

  @override
  String get changeInterval => 'Change interval';

  @override
  String get waterEvery => 'Water every';

  @override
  String get daysUnit => 'days';

  @override
  String get lastWatered => 'Last watered';

  @override
  String get never => 'Never';

  @override
  String get wateringHistory => 'Watering history';

  @override
  String get careTitle => 'Care';

  @override
  String get light => 'Light';

  @override
  String get humidity => 'Humidity';

  @override
  String get temperature => 'Temperature';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get health => 'Health';

  @override
  String get toxicToPets => 'Toxic to pets';

  @override
  String get safeForPets => 'Pet-safe';

  @override
  String get lightLow => 'Low light';

  @override
  String get lightMedium => 'Medium light';

  @override
  String get lightBrightIndirect => 'Bright, indirect';

  @override
  String get lightFullSun => 'Full sun';

  @override
  String get levelLow => 'Low';

  @override
  String get levelMedium => 'Medium';

  @override
  String get levelHigh => 'High';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get healthHealthy => 'Healthy';

  @override
  String get healthNeedsAttention => 'Needs attention';

  @override
  String get healthSick => 'Sick';

  @override
  String get healthUnknown => 'Unknown';

  @override
  String get openChat => 'Ask about this plant';

  @override
  String get removeFromGarden => 'Remove from garden';

  @override
  String get addToGarden => 'Add to garden';

  @override
  String get addedToGarden => 'Added to your garden';

  @override
  String get share => 'Share';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get deleteChatConfirm => 'Delete this conversation?';

  @override
  String get deleteChatBody =>
      'Messages and the photo will be removed from this device.';

  @override
  String get deleted => 'Deleted';

  @override
  String get chatsEmpty => 'No conversations yet';

  @override
  String get chatsEmptyHint => 'Scan a plant or ask the expert a question.';

  @override
  String get search => 'Search';

  @override
  String get typeMessage => 'Ask about your plant…';

  @override
  String get thinking => 'Analyzing…';

  @override
  String get retry => 'Try again';

  @override
  String get aiError =>
      'Couldn\'t get an answer. Check your connection and try again.';

  @override
  String get copied => 'Copied';

  @override
  String get newChat => 'New conversation';

  @override
  String get outOfCreditsTitle => 'You\'re out of credits';

  @override
  String outOfCreditsBody(int daily, int reward) {
    return 'You get $daily free credits every day. Watch a short ad for +$reward, or go Pro for unlimited access.';
  }

  @override
  String watchAd(int reward) {
    return 'Watch an ad (+$reward)';
  }

  @override
  String get adNotReady => 'The ad is still loading — try again in a moment.';

  @override
  String get rewardLimit => 'Daily ad limit reached. Come back tomorrow!';

  @override
  String creditsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count credits added',
      one: '+1 credit added',
    );
    return '$_temp0';
  }

  @override
  String credits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count credits',
      one: '1 credit',
    );
    return '$_temp0';
  }

  @override
  String creditsRenew(int daily) {
    return '$daily free credits every day';
  }

  @override
  String get dailyLimit => 'Daily limit reached. Try again tomorrow.';

  @override
  String get goPro => 'Go Pro';

  @override
  String get proActive => 'Pro is active';

  @override
  String get proSubtitle => 'Unlimited scans and chats, no ads';

  @override
  String get manageSubscription => 'Manage subscription';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get purchasesRestored => 'Purchases restored';

  @override
  String get language => 'Language';

  @override
  String get privacyPolicy => 'Terms & privacy';

  @override
  String get rateApp => 'Rate the app';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get account => 'Account';

  @override
  String get appSection => 'App';

  @override
  String get offline => 'Can\'t reach the server';

  @override
  String get reconnect => 'Reconnect';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get proBenefitScans => 'Unlimited plant scans';

  @override
  String get proBenefitChat => 'Unlimited expert chat';

  @override
  String get proBenefitGarden => 'Watering plans for your whole garden';

  @override
  String get proBenefitNoAds => 'No ads';

  @override
  String get paywallTitle => 'Plants AI Pro';

  @override
  String get paywallSubtitle => 'Everything your plants need, without limits.';

  @override
  String get yearly => 'Yearly';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String perYear(String price) {
    return '$price / year';
  }

  @override
  String perWeek(String price) {
    return '$price / week';
  }

  @override
  String perMonth(String price) {
    return '$price / month';
  }

  @override
  String savePercent(int percent) {
    return 'SAVE $percent%';
  }

  @override
  String get freeTrial => 'Free trial';

  @override
  String get continueLabel => 'Continue';

  @override
  String get paywallUnavailable => 'Subscriptions are not available right now.';

  @override
  String get onboarding1Title => 'Identify any plant';

  @override
  String get onboarding1Body =>
      'Take a photo — AI tells you what it is and how it\'s doing.';

  @override
  String get onboarding2Title => 'Never forget to water';

  @override
  String get onboarding2Body =>
      'Every scanned plant lands in your garden with its own watering plan.';

  @override
  String get onboarding3Title => 'Your plant expert';

  @override
  String get onboarding3Body =>
      'Ask follow-up questions about pests, soil, light and more.';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get started';

  @override
  String get skip => 'Skip';

  @override
  String get cropImage => 'Crop photo';

  @override
  String get noResults => 'No results';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';
}
