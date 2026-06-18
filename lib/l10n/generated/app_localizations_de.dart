// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'MOT-ZAIQUE';

  @override
  String get communicateTitle => 'Kommunizieren';

  @override
  String get communicateSubtitle =>
      'Waehlen Sie Piktogramme, um den Satz zu bilden und vorzulesen.';

  @override
  String get searchHint => 'Piktogramme in ARASAAC suchen';

  @override
  String get searchButton => 'Suchen';

  @override
  String get offlineModeChip => 'Offline-Modus';

  @override
  String get cacheResultsNotice => 'Ergebnisse aus dem Cache werden angezeigt.';

  @override
  String get offlineNoCacheNotice =>
      'Keine zwischengespeicherten Ergebnisse fuer dieses Wort.';

  @override
  String get searchEmptyTitle => 'Suchen Sie ein Wort, um Piktogramme zu laden';

  @override
  String get phraseCurrent => 'Aktueller Satz';

  @override
  String get phraseEmpty =>
      'Tippen Sie auf Piktogramme, um einen Satz zu erstellen.';

  @override
  String get speakPhrase => 'Satz sprechen';

  @override
  String get removeLast => 'Letztes entfernen';

  @override
  String get clear => 'Leeren';

  @override
  String get savePhrase => 'Satz speichern';

  @override
  String get savedPhraseAdded => 'Satz gespeichert';

  @override
  String get savedPhrasesTitle => 'Gespeicherte Saetze';

  @override
  String get savedPhrasesEmpty => 'Noch keine gespeicherten Saetze';

  @override
  String get loadPhrase => 'Laden';

  @override
  String get deletePhrase => 'Loeschen';

  @override
  String get savePhraseDialogTitle => 'Satz speichern';

  @override
  String get savePhraseNameLabel => 'Name (optional)';

  @override
  String get savePhraseNameHint => 'Beispiel: Grundbeduerfnisse';

  @override
  String get favoritesTitle => 'Favoriten';

  @override
  String get favoritesSubtitle =>
      'PIN-geschuetzter Zugriff. Ihre am meisten genutzten Piktogramme.';

  @override
  String get noFavoritesTitle => 'Noch keine Favoriten';

  @override
  String get noFavoritesSubtitle =>
      'Tippen Sie auf das Herz, um Piktogramme zu speichern.';

  @override
  String get removeFavorite => 'Entfernen';

  @override
  String get addToPhrase => 'Hinzufuegen';

  @override
  String get saveFavorite => 'Favorit speichern';

  @override
  String get removeFavoriteTooltip => 'Favorit entfernen';

  @override
  String get communicateNav => 'Kommunizieren';

  @override
  String get favoritesNav => 'Favoriten';

  @override
  String get settingsAction => 'Einstellungen';

  @override
  String get settingsNav => 'Einstellungen';

  @override
  String get pictogramSize => 'Piktogrammgroesse';

  @override
  String get highContrast => 'Hoher Kontrast';

  @override
  String get reducedMotion => 'Weniger Bewegung';

  @override
  String get offlineOnly => 'Nur offline';

  @override
  String get language => 'Sprache';

  @override
  String get qualityFilters => 'Qualitaetsfilter';

  @override
  String get onlyAacFilter => 'Nur AAC-Piktogramme';

  @override
  String get onlySchematicFilter => 'Nur schematische Piktogramme';

  @override
  String get minDownloadsFilter => 'Mindestanzahl Downloads';

  @override
  String get cacheData => 'Cache-Daten';

  @override
  String cacheCount(int count) {
    return '$count gespeicherte Suchanfragen';
  }

  @override
  String get clearCache => 'Cache leeren';

  @override
  String get cacheCleared => 'Cache geleert';

  @override
  String get backupSection => 'Lokales Backup';

  @override
  String get backupPathLabel => 'Backup-Pfad';

  @override
  String get exportBackup => 'Backup exportieren';

  @override
  String get restoreBackup => 'Backup wiederherstellen';

  @override
  String get backupExported => 'Backup exportiert';

  @override
  String get backupMissing => 'Keine Backup-Datei gefunden';

  @override
  String get backupRestored => 'Backup wiederhergestellt';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get continueText => 'Weiter';

  @override
  String get pinCreateTitle => 'PIN festlegen';

  @override
  String get pinNew => 'Neuer PIN';

  @override
  String get pinConfirm => 'PIN bestaetigen';

  @override
  String get pinInvalidRule => 'Verwenden Sie 4 bis 6 Ziffern.';

  @override
  String get pinMismatch => 'Codes stimmen nicht ueberein.';

  @override
  String get pinSave => 'PIN speichern';

  @override
  String get pinCreated => 'PIN erfolgreich erstellt';

  @override
  String get recoveryCodeTitle => 'Wiederherstellungscode';

  @override
  String get recoveryCodeMessage =>
      'Bewahren Sie diesen Code sicher auf. Er wird benoetigt, wenn Sie den PIN vergessen.';

  @override
  String get unlockFavoritesTitle => 'Favoriten entsperren';

  @override
  String get pinLabel => 'PIN';

  @override
  String get pinIncorrect => 'Falscher PIN';

  @override
  String pinLockedSeconds(int seconds) {
    return 'Zu viele Versuche. Bitte in ${seconds}s erneut versuchen.';
  }

  @override
  String remainingAttempts(int count) {
    return 'Verbleibende Versuche: $count';
  }

  @override
  String get recoverPin => 'PIN wiederherstellen';

  @override
  String get recoverPinTitle => 'PIN mit Code wiederherstellen';

  @override
  String get recoveryCodeLabel => 'Wiederherstellungscode';

  @override
  String get newPinLabel => 'Neuer PIN';

  @override
  String get confirmNewPinLabel => 'Neuen PIN bestaetigen';

  @override
  String get recoverAction => 'Wiederherstellen';

  @override
  String get pinResetSuccess => 'PIN zurueckgesetzt';

  @override
  String get changePinAction => 'PIN aendern';

  @override
  String get changePinTitle => 'PIN aendern';

  @override
  String get pinChanged => 'PIN aktualisiert';

  @override
  String get lockFavorites => 'Favoriten sperren';

  @override
  String get favoriteSaved => 'Zu Favoriten hinzugefuegt';

  @override
  String get favoriteRemoved => 'Aus Favoriten entfernt';

  @override
  String get categoryNeeds => 'Beduerfnisse';

  @override
  String get categoryEmotions => 'Emotionen';

  @override
  String get categorySchool => 'Schule';

  @override
  String get categoryHome => 'Zuhause';

  @override
  String get categoryHealth => 'Gesundheit';

  @override
  String get quickWant => 'ich will';

  @override
  String get quickEat => 'essen';

  @override
  String get quickDrink => 'trinken';

  @override
  String get quickBathroom => 'toilette';

  @override
  String get quickPlay => 'spielen';

  @override
  String get quickSleep => 'schlafen';

  @override
  String get quickHappy => 'gluecklich';

  @override
  String get quickSad => 'traurig';

  @override
  String get quickAngry => 'wuetend';

  @override
  String get quickFear => 'angst';

  @override
  String get quickCalm => 'ruhig';

  @override
  String get quickSchool => 'schule';

  @override
  String get quickTeacher => 'lehrer';

  @override
  String get quickRead => 'lesen';

  @override
  String get quickWrite => 'schreiben';

  @override
  String get quickHome => 'haus';

  @override
  String get quickMom => 'mama';

  @override
  String get quickDad => 'papa';

  @override
  String get quickDoctor => 'arzt';

  @override
  String get quickPain => 'schmerz';

  @override
  String get quickMedicine => 'medizin';

  @override
  String get quickHelp => 'hilfe';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get languageFrench => 'Franzoesisch';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageItalian => 'Italienisch';

  @override
  String get legalSection => 'Rechtliches';

  @override
  String get termsOfUse => 'Nutzungsbedingungen';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get creditsTitle => 'Credits';

  @override
  String get creditsAppDescription =>
      'Anwendung fuer Unterstuetzte Kommunikation (UK).';

  @override
  String get creditsDevelopment => 'Entwicklung';

  @override
  String get creditsAssociation => 'Verein';

  @override
  String get creditsPictograms => 'Piktogramme';

  @override
  String get creditsArasaacDescription =>
      'Piktogramme erstellt von Sergio Palao fuer die Regierung von Aragonien.';

  @override
  String get showSearch => 'Suche';

  @override
  String get serviceUnavailable =>
      'ARASAAC ist nicht verfuegbar. Bitte erneut versuchen.';
}
