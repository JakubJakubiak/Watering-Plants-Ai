import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('pl'),
    Locale('uk'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Plants AI'**
  String get appTitle;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @addCoins.
  ///
  /// In en, this message translates to:
  /// **'Add credits'**
  String get addCoins;

  /// No description provided for @unsubscribe.
  ///
  /// In en, this message translates to:
  /// **'Unsubscribe'**
  String get unsubscribe;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get chat;

  /// No description provided for @chatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistory;

  /// No description provided for @unlimitedAccess.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Access'**
  String get unlimitedAccess;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// No description provided for @identifications.
  ///
  /// In en, this message translates to:
  /// **'Unlimited plant identifications'**
  String get identifications;

  /// No description provided for @limitlessChat.
  ///
  /// In en, this message translates to:
  /// **'Limitless chat messages'**
  String get limitlessChat;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Create your own AI'**
  String get tips;

  /// No description provided for @tips2.
  ///
  /// In en, this message translates to:
  /// **'Well-spent time'**
  String get tips2;

  /// No description provided for @removeAds.
  ///
  /// In en, this message translates to:
  /// **'Remove ads'**
  String get removeAds;

  /// No description provided for @navScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// No description provided for @navGarden.
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get navGarden;

  /// No description provided for @navChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get navChats;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @scanTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s growing here?'**
  String get scanTitle;

  /// No description provided for @scanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Snap a photo — AI identifies the plant, checks its health and plans the watering.'**
  String get scanSubtitle;

  /// No description provided for @askExpert.
  ///
  /// In en, this message translates to:
  /// **'Ask the plant expert'**
  String get askExpert;

  /// No description provided for @askExpertHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Why are my monstera\'s leaves turning yellow?'**
  String get askExpertHint;

  /// No description provided for @identifyPrompt.
  ///
  /// In en, this message translates to:
  /// **'What plant is this? How is it doing and how should I care for it?'**
  String get identifyPrompt;

  /// No description provided for @needsWaterToday.
  ///
  /// In en, this message translates to:
  /// **'Needs water'**
  String get needsWaterToday;

  /// No description provided for @allWatered.
  ///
  /// In en, this message translates to:
  /// **'All your plants are watered'**
  String get allWatered;

  /// No description provided for @plantLibrary.
  ///
  /// In en, this message translates to:
  /// **'Plant library'**
  String get plantLibrary;

  /// No description provided for @plantLibrarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} species with care guides'**
  String plantLibrarySubtitle(int count);

  /// No description provided for @tipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for a great scan'**
  String get tipsTitle;

  /// No description provided for @tip1.
  ///
  /// In en, this message translates to:
  /// **'One plant in the frame'**
  String get tip1;

  /// No description provided for @tip2.
  ///
  /// In en, this message translates to:
  /// **'Daylight, no harsh shadows'**
  String get tip2;

  /// No description provided for @tip3.
  ///
  /// In en, this message translates to:
  /// **'Show the leaves up close'**
  String get tip3;

  /// No description provided for @gardenEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your garden is empty'**
  String get gardenEmpty;

  /// No description provided for @gardenEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Scan a plant and it will appear here with its own watering plan.'**
  String get gardenEmptyHint;

  /// No description provided for @scanPlant.
  ///
  /// In en, this message translates to:
  /// **'Scan a plant'**
  String get scanPlant;

  /// No description provided for @waterNow.
  ///
  /// In en, this message translates to:
  /// **'Watered'**
  String get waterNow;

  /// No description provided for @wateredToast.
  ///
  /// In en, this message translates to:
  /// **'{name} watered'**
  String wateredToast(String name);

  /// No description provided for @waterIn.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Water today} =1{Water tomorrow} other{Water in {days} days}}'**
  String waterIn(int days);

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day overdue} other{{days} days overdue}}'**
  String overdue(int days);

  /// No description provided for @everyDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Every day} other{Every {days} days}}'**
  String everyDays(int days);

  /// No description provided for @plantsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No plants} =1{1 plant} other{{count} plants}}'**
  String plantsCount(int count);

  /// No description provided for @dueCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 plant needs water} other{{count} plants need water}}'**
  String dueCount(int count);

  /// No description provided for @wateringSchedule.
  ///
  /// In en, this message translates to:
  /// **'Watering'**
  String get wateringSchedule;

  /// No description provided for @changeInterval.
  ///
  /// In en, this message translates to:
  /// **'Change interval'**
  String get changeInterval;

  /// No description provided for @waterEvery.
  ///
  /// In en, this message translates to:
  /// **'Water every'**
  String get waterEvery;

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysUnit;

  /// No description provided for @lastWatered.
  ///
  /// In en, this message translates to:
  /// **'Last watered'**
  String get lastWatered;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @wateringHistory.
  ///
  /// In en, this message translates to:
  /// **'Watering history'**
  String get wateringHistory;

  /// No description provided for @careTitle.
  ///
  /// In en, this message translates to:
  /// **'Care'**
  String get careTitle;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidity;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @toxicToPets.
  ///
  /// In en, this message translates to:
  /// **'Toxic to pets'**
  String get toxicToPets;

  /// No description provided for @safeForPets.
  ///
  /// In en, this message translates to:
  /// **'Pet-safe'**
  String get safeForPets;

  /// No description provided for @lightLow.
  ///
  /// In en, this message translates to:
  /// **'Low light'**
  String get lightLow;

  /// No description provided for @lightMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium light'**
  String get lightMedium;

  /// No description provided for @lightBrightIndirect.
  ///
  /// In en, this message translates to:
  /// **'Bright, indirect'**
  String get lightBrightIndirect;

  /// No description provided for @lightFullSun.
  ///
  /// In en, this message translates to:
  /// **'Full sun'**
  String get lightFullSun;

  /// No description provided for @levelLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get levelLow;

  /// No description provided for @levelMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get levelMedium;

  /// No description provided for @levelHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get levelHigh;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @healthHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthHealthy;

  /// No description provided for @healthNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get healthNeedsAttention;

  /// No description provided for @healthSick.
  ///
  /// In en, this message translates to:
  /// **'Sick'**
  String get healthSick;

  /// No description provided for @healthUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get healthUnknown;

  /// No description provided for @openChat.
  ///
  /// In en, this message translates to:
  /// **'Ask about this plant'**
  String get openChat;

  /// No description provided for @removeFromGarden.
  ///
  /// In en, this message translates to:
  /// **'Remove from garden'**
  String get removeFromGarden;

  /// No description provided for @addToGarden.
  ///
  /// In en, this message translates to:
  /// **'Add to garden'**
  String get addToGarden;

  /// No description provided for @addedToGarden.
  ///
  /// In en, this message translates to:
  /// **'Added to your garden'**
  String get addedToGarden;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @deleteChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this conversation?'**
  String get deleteChatConfirm;

  /// No description provided for @deleteChatBody.
  ///
  /// In en, this message translates to:
  /// **'Messages and the photo will be removed from this device.'**
  String get deleteChatBody;

  /// No description provided for @deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// No description provided for @chatsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get chatsEmpty;

  /// No description provided for @chatsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Scan a plant or ask the expert a question.'**
  String get chatsEmptyHint;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Ask about your plant…'**
  String get typeMessage;

  /// No description provided for @thinking.
  ///
  /// In en, this message translates to:
  /// **'Analyzing…'**
  String get thinking;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @aiError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get an answer. Check your connection and try again.'**
  String get aiError;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get newChat;

  /// No description provided for @outOfCreditsTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re out of credits'**
  String get outOfCreditsTitle;

  /// No description provided for @outOfCreditsBody.
  ///
  /// In en, this message translates to:
  /// **'You get {daily} free credits every day. Watch a short ad for +{reward}, or go Pro for unlimited access.'**
  String outOfCreditsBody(int daily, int reward);

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch an ad (+{reward})'**
  String watchAd(int reward);

  /// No description provided for @adNotReady.
  ///
  /// In en, this message translates to:
  /// **'The ad is still loading — try again in a moment.'**
  String get adNotReady;

  /// No description provided for @rewardLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily ad limit reached. Come back tomorrow!'**
  String get rewardLimit;

  /// No description provided for @creditsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{+1 credit added} other{+{count} credits added}}'**
  String creditsAdded(int count);

  /// No description provided for @credits.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 credit} other{{count} credits}}'**
  String credits(int count);

  /// No description provided for @creditsRenew.
  ///
  /// In en, this message translates to:
  /// **'{daily} free credits every day'**
  String creditsRenew(int daily);

  /// No description provided for @dailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily limit reached. Try again tomorrow.'**
  String get dailyLimit;

  /// No description provided for @goPro.
  ///
  /// In en, this message translates to:
  /// **'Go Pro'**
  String get goPro;

  /// No description provided for @proActive.
  ///
  /// In en, this message translates to:
  /// **'Pro is active'**
  String get proActive;

  /// No description provided for @proSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlimited scans and chats, no ads'**
  String get proSubtitle;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get manageSubscription;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @purchasesRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored'**
  String get purchasesRestored;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Terms & privacy'**
  String get privacyPolicy;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the app'**
  String get rateApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @appSection.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get appSection;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach the server'**
  String get offline;

  /// No description provided for @reconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get reconnect;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @proBenefitScans.
  ///
  /// In en, this message translates to:
  /// **'Unlimited plant scans'**
  String get proBenefitScans;

  /// No description provided for @proBenefitChat.
  ///
  /// In en, this message translates to:
  /// **'Unlimited expert chat'**
  String get proBenefitChat;

  /// No description provided for @proBenefitGarden.
  ///
  /// In en, this message translates to:
  /// **'Watering plans for your whole garden'**
  String get proBenefitGarden;

  /// No description provided for @proBenefitNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get proBenefitNoAds;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Plants AI Pro'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything your plants need, without limits.'**
  String get paywallSubtitle;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'{price} / year'**
  String perYear(String price);

  /// No description provided for @perWeek.
  ///
  /// In en, this message translates to:
  /// **'{price} / week'**
  String perWeek(String price);

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'{price} / month'**
  String perMonth(String price);

  /// No description provided for @savePercent.
  ///
  /// In en, this message translates to:
  /// **'SAVE {percent}%'**
  String savePercent(int percent);

  /// No description provided for @freeTrial.
  ///
  /// In en, this message translates to:
  /// **'Free trial'**
  String get freeTrial;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @paywallUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions are not available right now.'**
  String get paywallUnavailable;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Identify any plant'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Body.
  ///
  /// In en, this message translates to:
  /// **'Take a photo — AI tells you what it is and how it\'s doing.'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Never forget to water'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Body.
  ///
  /// In en, this message translates to:
  /// **'Every scanned plant lands in your garden with its own watering plan.'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Your plant expert'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Body.
  ///
  /// In en, this message translates to:
  /// **'Ask follow-up questions about pests, soil, light and more.'**
  String get onboarding3Body;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @cropImage.
  ///
  /// In en, this message translates to:
  /// **'Crop photo'**
  String get cropImage;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'de',
        'en',
        'es',
        'fr',
        'hi',
        'it',
        'ja',
        'pl',
        'uk',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'pl':
      return AppLocalizationsPl();
    case 'uk':
      return AppLocalizationsUk();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
