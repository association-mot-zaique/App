// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'mot-zaique';

  @override
  String get communicateTitle => 'Communicate';

  @override
  String get communicateSubtitle =>
      'Select pictograms to build the sentence and speak it.';

  @override
  String get searchHint => 'Search pictograms in ARASAAC';

  @override
  String get searchButton => 'Search';

  @override
  String get offlineModeChip => 'Offline mode';

  @override
  String get cacheResultsNotice => 'Showing cached results.';

  @override
  String get offlineNoCacheNotice => 'No cached results for this word.';

  @override
  String get searchEmptyTitle => 'Search a word to load pictograms';

  @override
  String get phraseCurrent => 'Current sentence';

  @override
  String get phraseEmpty => 'Tap pictograms to build a sentence.';

  @override
  String get speakPhrase => 'Speak sentence';

  @override
  String get removeLast => 'Remove last';

  @override
  String get clear => 'Clear';

  @override
  String get savePhrase => 'Save sentence';

  @override
  String get savedPhraseAdded => 'Sentence saved';

  @override
  String get savedPhrasesTitle => 'Saved sentences';

  @override
  String get savedPhrasesEmpty => 'No saved sentences yet';

  @override
  String get loadPhrase => 'Load';

  @override
  String get deletePhrase => 'Delete';

  @override
  String get savePhraseDialogTitle => 'Save sentence';

  @override
  String get savePhraseNameLabel => 'Name (optional)';

  @override
  String get savePhraseNameHint => 'Example: Basic needs';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesSubtitle =>
      'PIN-protected access. Your most-used pictograms.';

  @override
  String get noFavoritesTitle => 'No favorites yet';

  @override
  String get noFavoritesSubtitle => 'Tap the heart icon to save pictograms.';

  @override
  String get removeFavorite => 'Remove';

  @override
  String get addToPhrase => 'Add';

  @override
  String get saveFavorite => 'Save favorite';

  @override
  String get removeFavoriteTooltip => 'Remove favorite';

  @override
  String get communicateNav => 'Communicate';

  @override
  String get favoritesNav => 'Favorites';

  @override
  String get settingsAction => 'Settings';

  @override
  String get settingsNav => 'Settings';

  @override
  String get pictogramSize => 'Pictogram size';

  @override
  String get highContrast => 'High contrast';

  @override
  String get reducedMotion => 'Reduced motion';

  @override
  String get offlineOnly => 'Offline only';

  @override
  String get language => 'Language';

  @override
  String get qualityFilters => 'Quality filters';

  @override
  String get onlyAacFilter => 'AAC pictograms only';

  @override
  String get onlySchematicFilter => 'Schematic pictograms only';

  @override
  String get minDownloadsFilter => 'Minimum downloads';

  @override
  String get cacheData => 'Cached data';

  @override
  String cacheCount(int count) {
    return '$count saved queries';
  }

  @override
  String get clearCache => 'Clear cache';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get backupSection => 'Local backup';

  @override
  String get backupPathLabel => 'Backup path';

  @override
  String get exportBackup => 'Export backup';

  @override
  String get restoreBackup => 'Restore backup';

  @override
  String get backupExported => 'Backup exported';

  @override
  String get backupMissing => 'No backup file found';

  @override
  String get backupRestored => 'Backup restored';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get continueText => 'Continue';

  @override
  String get pinCreateTitle => 'Set PIN';

  @override
  String get pinNew => 'New PIN';

  @override
  String get pinConfirm => 'Confirm PIN';

  @override
  String get pinInvalidRule => 'Use 4 to 6 numeric digits.';

  @override
  String get pinMismatch => 'Codes do not match.';

  @override
  String get pinSave => 'Save PIN';

  @override
  String get pinCreated => 'PIN created successfully';

  @override
  String get recoveryCodeTitle => 'Recovery code';

  @override
  String get recoveryCodeMessage =>
      'Store this code in a safe place. It is required if you forget your PIN.';

  @override
  String get unlockFavoritesTitle => 'Unlock favorites';

  @override
  String get pinLabel => 'PIN';

  @override
  String get pinIncorrect => 'Incorrect PIN';

  @override
  String pinLockedSeconds(int seconds) {
    return 'Too many attempts. Try again in ${seconds}s.';
  }

  @override
  String remainingAttempts(int count) {
    return 'Remaining attempts: $count';
  }

  @override
  String get recoverPin => 'Recover PIN';

  @override
  String get recoverPinTitle => 'Recover PIN with code';

  @override
  String get recoveryCodeLabel => 'Recovery code';

  @override
  String get newPinLabel => 'New PIN';

  @override
  String get confirmNewPinLabel => 'Confirm new PIN';

  @override
  String get recoverAction => 'Recover';

  @override
  String get pinResetSuccess => 'PIN reset successfully';

  @override
  String get changePinAction => 'Change PIN';

  @override
  String get changePinTitle => 'Change PIN';

  @override
  String get pinChanged => 'PIN updated';

  @override
  String get lockFavorites => 'Lock favorites';

  @override
  String get favoriteSaved => 'Saved to favorites';

  @override
  String get favoriteRemoved => 'Removed from favorites';

  @override
  String get categoryNeeds => 'Needs';

  @override
  String get categoryEmotions => 'Emotions';

  @override
  String get categorySchool => 'School';

  @override
  String get categoryHome => 'Home';

  @override
  String get categoryHealth => 'Health';

  @override
  String get quickWant => 'want';

  @override
  String get quickEat => 'eat';

  @override
  String get quickDrink => 'drink';

  @override
  String get quickBathroom => 'bathroom';

  @override
  String get quickPlay => 'play';

  @override
  String get quickSleep => 'sleep';

  @override
  String get quickHappy => 'happy';

  @override
  String get quickSad => 'sad';

  @override
  String get quickAngry => 'angry';

  @override
  String get quickFear => 'afraid';

  @override
  String get quickCalm => 'calm';

  @override
  String get quickSchool => 'school';

  @override
  String get quickTeacher => 'teacher';

  @override
  String get quickRead => 'read';

  @override
  String get quickWrite => 'write';

  @override
  String get quickHome => 'home';

  @override
  String get quickMom => 'mom';

  @override
  String get quickDad => 'dad';

  @override
  String get quickDoctor => 'doctor';

  @override
  String get quickPain => 'pain';

  @override
  String get quickMedicine => 'medicine';

  @override
  String get quickHelp => 'help';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageFrench => 'French';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'German';

  @override
  String get languageItalian => 'Italian';

  @override
  String get legalSection => 'Legal';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get creditsTitle => 'Credits';

  @override
  String get creditsAppDescription =>
      'Alternative and Augmentative Communication (AAC) application.';

  @override
  String get creditsDevelopment => 'Development';

  @override
  String get creditsAssociation => 'Association';

  @override
  String get creditsPictograms => 'Pictograms';

  @override
  String get creditsArasaacDescription =>
      'Pictograms created by Sergio Palao for the Government of Aragon.';

  @override
  String get showSearch => 'Search';

  @override
  String get serviceUnavailable =>
      'ARASAAC is not available. Please try again.';
}
