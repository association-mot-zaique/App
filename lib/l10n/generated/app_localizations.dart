import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MOT-ZAIQUE'**
  String get appTitle;

  /// No description provided for @communicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Communicate'**
  String get communicateTitle;

  /// No description provided for @communicateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select pictograms to build the sentence and speak it.'**
  String get communicateSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search pictograms in ARASAAC'**
  String get searchHint;

  /// No description provided for @searchButton.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchButton;

  /// No description provided for @offlineModeChip.
  ///
  /// In en, this message translates to:
  /// **'Offline mode'**
  String get offlineModeChip;

  /// No description provided for @cacheResultsNotice.
  ///
  /// In en, this message translates to:
  /// **'Showing cached results.'**
  String get cacheResultsNotice;

  /// No description provided for @offlineNoCacheNotice.
  ///
  /// In en, this message translates to:
  /// **'No cached results for this word.'**
  String get offlineNoCacheNotice;

  /// No description provided for @searchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Search a word to load pictograms'**
  String get searchEmptyTitle;

  /// No description provided for @phraseCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current sentence'**
  String get phraseCurrent;

  /// No description provided for @phraseEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tap pictograms to build a sentence.'**
  String get phraseEmpty;

  /// No description provided for @speakPhrase.
  ///
  /// In en, this message translates to:
  /// **'Speak sentence'**
  String get speakPhrase;

  /// No description provided for @removeLast.
  ///
  /// In en, this message translates to:
  /// **'Remove last'**
  String get removeLast;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @savePhrase.
  ///
  /// In en, this message translates to:
  /// **'Save sentence'**
  String get savePhrase;

  /// No description provided for @savedPhraseAdded.
  ///
  /// In en, this message translates to:
  /// **'Sentence saved'**
  String get savedPhraseAdded;

  /// No description provided for @savedPhrasesTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved sentences'**
  String get savedPhrasesTitle;

  /// No description provided for @savedPhrasesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved sentences yet'**
  String get savedPhrasesEmpty;

  /// No description provided for @loadPhrase.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get loadPhrase;

  /// No description provided for @deletePhrase.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deletePhrase;

  /// No description provided for @savePhraseDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save sentence'**
  String get savePhraseDialogTitle;

  /// No description provided for @savePhraseNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get savePhraseNameLabel;

  /// No description provided for @savePhraseNameHint.
  ///
  /// In en, this message translates to:
  /// **'Example: Basic needs'**
  String get savePhraseNameHint;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PIN-protected access. Your most-used pictograms.'**
  String get favoritesSubtitle;

  /// No description provided for @noFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavoritesTitle;

  /// No description provided for @noFavoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon to save pictograms.'**
  String get noFavoritesSubtitle;

  /// No description provided for @removeFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeFavorite;

  /// No description provided for @addToPhrase.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addToPhrase;

  /// No description provided for @saveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Save favorite'**
  String get saveFavorite;

  /// No description provided for @removeFavoriteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get removeFavoriteTooltip;

  /// No description provided for @communicateNav.
  ///
  /// In en, this message translates to:
  /// **'Communicate'**
  String get communicateNav;

  /// No description provided for @favoritesNav.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesNav;

  /// No description provided for @settingsAction.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsAction;

  /// No description provided for @settingsNav.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsNav;

  /// No description provided for @pictogramSize.
  ///
  /// In en, this message translates to:
  /// **'Pictogram size'**
  String get pictogramSize;

  /// No description provided for @highContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get highContrast;

  /// No description provided for @reducedMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduced motion'**
  String get reducedMotion;

  /// No description provided for @offlineOnly.
  ///
  /// In en, this message translates to:
  /// **'Offline only'**
  String get offlineOnly;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @qualityFilters.
  ///
  /// In en, this message translates to:
  /// **'Quality filters'**
  String get qualityFilters;

  /// No description provided for @onlyAacFilter.
  ///
  /// In en, this message translates to:
  /// **'AAC pictograms only'**
  String get onlyAacFilter;

  /// No description provided for @onlySchematicFilter.
  ///
  /// In en, this message translates to:
  /// **'Schematic pictograms only'**
  String get onlySchematicFilter;

  /// No description provided for @minDownloadsFilter.
  ///
  /// In en, this message translates to:
  /// **'Minimum downloads'**
  String get minDownloadsFilter;

  /// No description provided for @cacheData.
  ///
  /// In en, this message translates to:
  /// **'Cached data'**
  String get cacheData;

  /// No description provided for @cacheCount.
  ///
  /// In en, this message translates to:
  /// **'{count} saved queries'**
  String cacheCount(int count);

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get cacheCleared;

  /// No description provided for @backupSection.
  ///
  /// In en, this message translates to:
  /// **'Local backup'**
  String get backupSection;

  /// No description provided for @backupPathLabel.
  ///
  /// In en, this message translates to:
  /// **'Backup path'**
  String get backupPathLabel;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportBackup;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup'**
  String get restoreBackup;

  /// No description provided for @backupExported.
  ///
  /// In en, this message translates to:
  /// **'Backup exported'**
  String get backupExported;

  /// No description provided for @backupMissing.
  ///
  /// In en, this message translates to:
  /// **'No backup file found'**
  String get backupMissing;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get backupRestored;

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

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @pinCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get pinCreateTitle;

  /// No description provided for @pinNew.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get pinNew;

  /// No description provided for @pinConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get pinConfirm;

  /// No description provided for @pinInvalidRule.
  ///
  /// In en, this message translates to:
  /// **'Use 4 to 6 numeric digits.'**
  String get pinInvalidRule;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'Codes do not match.'**
  String get pinMismatch;

  /// No description provided for @pinSave.
  ///
  /// In en, this message translates to:
  /// **'Save PIN'**
  String get pinSave;

  /// No description provided for @pinCreated.
  ///
  /// In en, this message translates to:
  /// **'PIN created successfully'**
  String get pinCreated;

  /// No description provided for @recoveryCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get recoveryCodeTitle;

  /// No description provided for @recoveryCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'Store this code in a safe place. It is required if you forget your PIN.'**
  String get recoveryCodeMessage;

  /// No description provided for @unlockFavoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock favorites'**
  String get unlockFavoritesTitle;

  /// No description provided for @pinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pinLabel;

  /// No description provided for @pinIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get pinIncorrect;

  /// No description provided for @pinLockedSeconds.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds}s.'**
  String pinLockedSeconds(int seconds);

  /// No description provided for @remainingAttempts.
  ///
  /// In en, this message translates to:
  /// **'Remaining attempts: {count}'**
  String remainingAttempts(int count);

  /// No description provided for @recoverPin.
  ///
  /// In en, this message translates to:
  /// **'Recover PIN'**
  String get recoverPin;

  /// No description provided for @recoverPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Recover PIN with code'**
  String get recoverPinTitle;

  /// No description provided for @recoveryCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get recoveryCodeLabel;

  /// No description provided for @newPinLabel.
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get newPinLabel;

  /// No description provided for @confirmNewPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new PIN'**
  String get confirmNewPinLabel;

  /// No description provided for @recoverAction.
  ///
  /// In en, this message translates to:
  /// **'Recover'**
  String get recoverAction;

  /// No description provided for @pinResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'PIN reset successfully'**
  String get pinResetSuccess;

  /// No description provided for @changePinAction.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePinAction;

  /// No description provided for @changePinTitle.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePinTitle;

  /// No description provided for @pinChanged.
  ///
  /// In en, this message translates to:
  /// **'PIN updated'**
  String get pinChanged;

  /// No description provided for @lockFavorites.
  ///
  /// In en, this message translates to:
  /// **'Lock favorites'**
  String get lockFavorites;

  /// No description provided for @favoriteSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to favorites'**
  String get favoriteSaved;

  /// No description provided for @favoriteRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get favoriteRemoved;

  /// No description provided for @categoryNeeds.
  ///
  /// In en, this message translates to:
  /// **'Needs'**
  String get categoryNeeds;

  /// No description provided for @categoryEmotions.
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get categoryEmotions;

  /// No description provided for @categorySchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get categorySchool;

  /// No description provided for @categoryHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get categoryHome;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @quickWant.
  ///
  /// In en, this message translates to:
  /// **'want'**
  String get quickWant;

  /// No description provided for @quickEat.
  ///
  /// In en, this message translates to:
  /// **'eat'**
  String get quickEat;

  /// No description provided for @quickDrink.
  ///
  /// In en, this message translates to:
  /// **'drink'**
  String get quickDrink;

  /// No description provided for @quickBathroom.
  ///
  /// In en, this message translates to:
  /// **'bathroom'**
  String get quickBathroom;

  /// No description provided for @quickPlay.
  ///
  /// In en, this message translates to:
  /// **'play'**
  String get quickPlay;

  /// No description provided for @quickSleep.
  ///
  /// In en, this message translates to:
  /// **'sleep'**
  String get quickSleep;

  /// No description provided for @quickHappy.
  ///
  /// In en, this message translates to:
  /// **'happy'**
  String get quickHappy;

  /// No description provided for @quickSad.
  ///
  /// In en, this message translates to:
  /// **'sad'**
  String get quickSad;

  /// No description provided for @quickAngry.
  ///
  /// In en, this message translates to:
  /// **'angry'**
  String get quickAngry;

  /// No description provided for @quickFear.
  ///
  /// In en, this message translates to:
  /// **'afraid'**
  String get quickFear;

  /// No description provided for @quickCalm.
  ///
  /// In en, this message translates to:
  /// **'calm'**
  String get quickCalm;

  /// No description provided for @quickSchool.
  ///
  /// In en, this message translates to:
  /// **'school'**
  String get quickSchool;

  /// No description provided for @quickTeacher.
  ///
  /// In en, this message translates to:
  /// **'teacher'**
  String get quickTeacher;

  /// No description provided for @quickRead.
  ///
  /// In en, this message translates to:
  /// **'read'**
  String get quickRead;

  /// No description provided for @quickWrite.
  ///
  /// In en, this message translates to:
  /// **'write'**
  String get quickWrite;

  /// No description provided for @quickHome.
  ///
  /// In en, this message translates to:
  /// **'home'**
  String get quickHome;

  /// No description provided for @quickMom.
  ///
  /// In en, this message translates to:
  /// **'mom'**
  String get quickMom;

  /// No description provided for @quickDad.
  ///
  /// In en, this message translates to:
  /// **'dad'**
  String get quickDad;

  /// No description provided for @quickDoctor.
  ///
  /// In en, this message translates to:
  /// **'doctor'**
  String get quickDoctor;

  /// No description provided for @quickPain.
  ///
  /// In en, this message translates to:
  /// **'pain'**
  String get quickPain;

  /// No description provided for @quickMedicine.
  ///
  /// In en, this message translates to:
  /// **'medicine'**
  String get quickMedicine;

  /// No description provided for @quickHelp.
  ///
  /// In en, this message translates to:
  /// **'help'**
  String get quickHelp;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// No description provided for @legalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legalSection;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get creditsTitle;

  /// No description provided for @creditsAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Alternative and Augmentative Communication (AAC) application.'**
  String get creditsAppDescription;

  /// No description provided for @creditsDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get creditsDevelopment;

  /// No description provided for @creditsAssociation.
  ///
  /// In en, this message translates to:
  /// **'Association'**
  String get creditsAssociation;

  /// No description provided for @creditsPictograms.
  ///
  /// In en, this message translates to:
  /// **'Pictograms'**
  String get creditsPictograms;

  /// No description provided for @creditsArasaacDescription.
  ///
  /// In en, this message translates to:
  /// **'Pictograms created by Sergio Palao for the Government of Aragon.'**
  String get creditsArasaacDescription;

  /// No description provided for @showSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get showSearch;

  /// No description provided for @serviceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'ARASAAC is not available. Please try again.'**
  String get serviceUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
