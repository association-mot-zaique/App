// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'MOT-ZAIQUE';

  @override
  String get communicateTitle => 'Comunicare';

  @override
  String get communicateSubtitle =>
      'Seleziona i pittogrammi per costruire e leggere la frase.';

  @override
  String get searchHint => 'Cerca pittogrammi in ARASAAC';

  @override
  String get searchButton => 'Cerca';

  @override
  String get offlineModeChip => 'Modalita offline';

  @override
  String get cacheResultsNotice => 'Risultati mostrati dalla cache.';

  @override
  String get offlineNoCacheNotice =>
      'Nessun risultato in cache per questa parola.';

  @override
  String get searchEmptyTitle => 'Cerca una parola per caricare i pittogrammi';

  @override
  String get phraseCurrent => 'Frase attuale';

  @override
  String get phraseEmpty => 'Tocca i pittogrammi per costruire una frase.';

  @override
  String get speakPhrase => 'Pronuncia frase';

  @override
  String get removeLast => 'Rimuovi ultimo';

  @override
  String get clear => 'Pulisci';

  @override
  String get savePhrase => 'Salva frase';

  @override
  String get savedPhraseAdded => 'Frase salvata';

  @override
  String get savedPhrasesTitle => 'Frasi salvate';

  @override
  String get savedPhrasesEmpty => 'Nessuna frase salvata';

  @override
  String get loadPhrase => 'Carica';

  @override
  String get deletePhrase => 'Elimina';

  @override
  String get savePhraseDialogTitle => 'Salva frase';

  @override
  String get savePhraseNameLabel => 'Nome (opzionale)';

  @override
  String get savePhraseNameHint => 'Esempio: Bisogni di base';

  @override
  String get favoritesTitle => 'Preferiti';

  @override
  String get favoritesSubtitle =>
      'Accesso protetto da PIN. I pittogrammi piu usati.';

  @override
  String get noFavoritesTitle => 'Nessun preferito';

  @override
  String get noFavoritesSubtitle => 'Tocca il cuore per salvare i pittogrammi.';

  @override
  String get removeFavorite => 'Rimuovi';

  @override
  String get addToPhrase => 'Aggiungi';

  @override
  String get saveFavorite => 'Salva preferito';

  @override
  String get removeFavoriteTooltip => 'Rimuovi preferito';

  @override
  String get communicateNav => 'Comunicare';

  @override
  String get favoritesNav => 'Preferiti';

  @override
  String get settingsAction => 'Impostazioni';

  @override
  String get settingsNav => 'Impostazioni';

  @override
  String get pictogramSize => 'Dimensione pittogrammi';

  @override
  String get highContrast => 'Alto contrasto';

  @override
  String get reducedMotion => 'Riduci movimento';

  @override
  String get offlineOnly => 'Solo offline';

  @override
  String get language => 'Lingua';

  @override
  String get qualityFilters => 'Filtri di qualita';

  @override
  String get onlyAacFilter => 'Solo pittogrammi AAC';

  @override
  String get onlySchematicFilter => 'Solo pittogrammi schematici';

  @override
  String get minDownloadsFilter => 'Download minimi';

  @override
  String get cacheData => 'Dati in cache';

  @override
  String cacheCount(int count) {
    return '$count ricerche salvate';
  }

  @override
  String get clearCache => 'Pulisci cache';

  @override
  String get cacheCleared => 'Cache pulita';

  @override
  String get backupSection => 'Backup locale';

  @override
  String get backupPathLabel => 'Percorso backup';

  @override
  String get exportBackup => 'Esporta backup';

  @override
  String get restoreBackup => 'Ripristina backup';

  @override
  String get backupExported => 'Backup esportato';

  @override
  String get backupMissing => 'Nessun file di backup trovato';

  @override
  String get backupRestored => 'Backup ripristinato';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get continueText => 'Continua';

  @override
  String get pinCreateTitle => 'Configura PIN';

  @override
  String get pinNew => 'Nuovo PIN';

  @override
  String get pinConfirm => 'Conferma PIN';

  @override
  String get pinInvalidRule => 'Usa da 4 a 6 cifre numeriche.';

  @override
  String get pinMismatch => 'I codici non coincidono.';

  @override
  String get pinSave => 'Salva PIN';

  @override
  String get pinCreated => 'PIN creato correttamente';

  @override
  String get recoveryCodeTitle => 'Codice di recupero';

  @override
  String get recoveryCodeMessage =>
      'Conserva questo codice in un luogo sicuro. Serve se dimentichi il PIN.';

  @override
  String get unlockFavoritesTitle => 'Sblocca preferiti';

  @override
  String get pinLabel => 'PIN';

  @override
  String get pinIncorrect => 'PIN errato';

  @override
  String pinLockedSeconds(int seconds) {
    return 'Troppi tentativi. Riprova tra ${seconds}s.';
  }

  @override
  String remainingAttempts(int count) {
    return 'Tentativi rimanenti: $count';
  }

  @override
  String get recoverPin => 'Recupera PIN';

  @override
  String get recoverPinTitle => 'Recupera PIN con codice';

  @override
  String get recoveryCodeLabel => 'Codice di recupero';

  @override
  String get newPinLabel => 'Nuovo PIN';

  @override
  String get confirmNewPinLabel => 'Conferma nuovo PIN';

  @override
  String get recoverAction => 'Recupera';

  @override
  String get pinResetSuccess => 'PIN reimpostato';

  @override
  String get changePinAction => 'Cambia PIN';

  @override
  String get changePinTitle => 'Cambia PIN';

  @override
  String get pinChanged => 'PIN aggiornato';

  @override
  String get lockFavorites => 'Blocca preferiti';

  @override
  String get favoriteSaved => 'Salvato nei preferiti';

  @override
  String get favoriteRemoved => 'Rimosso dai preferiti';

  @override
  String get categoryNeeds => 'Bisogni';

  @override
  String get categoryEmotions => 'Emozioni';

  @override
  String get categorySchool => 'Scuola';

  @override
  String get categoryHome => 'Casa';

  @override
  String get categoryHealth => 'Salute';

  @override
  String get quickWant => 'voglio';

  @override
  String get quickEat => 'mangiare';

  @override
  String get quickDrink => 'bere';

  @override
  String get quickBathroom => 'bagno';

  @override
  String get quickPlay => 'giocare';

  @override
  String get quickSleep => 'dormire';

  @override
  String get quickHappy => 'felice';

  @override
  String get quickSad => 'triste';

  @override
  String get quickAngry => 'arrabbiato';

  @override
  String get quickFear => 'paura';

  @override
  String get quickCalm => 'calmo';

  @override
  String get quickSchool => 'scuola';

  @override
  String get quickTeacher => 'insegnante';

  @override
  String get quickRead => 'leggere';

  @override
  String get quickWrite => 'scrivere';

  @override
  String get quickHome => 'casa';

  @override
  String get quickMom => 'mamma';

  @override
  String get quickDad => 'papa';

  @override
  String get quickDoctor => 'dottore';

  @override
  String get quickPain => 'dolore';

  @override
  String get quickMedicine => 'medicina';

  @override
  String get quickHelp => 'aiuto';

  @override
  String get languageSpanish => 'Spagnolo';

  @override
  String get languageFrench => 'Francese';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageGerman => 'Tedesco';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get legalSection => 'Legale';

  @override
  String get termsOfUse => 'Condizioni d\'uso';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get creditsTitle => 'Crediti';

  @override
  String get creditsAppDescription =>
      'Applicazione di Comunicazione Aumentativa e Alternativa (CAA).';

  @override
  String get creditsDevelopment => 'Sviluppo';

  @override
  String get creditsAssociation => 'Associazione';

  @override
  String get creditsPictograms => 'Pittogrammi';

  @override
  String get creditsArasaacDescription =>
      'Pittogrammi creati da Sergio Palao per il Governo d\'Aragona.';

  @override
  String get showSearch => 'Cerca';

  @override
  String get serviceUnavailable => 'ARASAAC non e disponibile. Riprova.';
}
