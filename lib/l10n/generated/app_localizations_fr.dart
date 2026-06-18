// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'mot-zaique';

  @override
  String get communicateTitle => 'Communiquer';

  @override
  String get communicateSubtitle =>
      'Selectionnez des pictogrammes pour construire et lire la phrase.';

  @override
  String get searchHint => 'Rechercher des pictogrammes dans ARASAAC';

  @override
  String get searchButton => 'Rechercher';

  @override
  String get offlineModeChip => 'Mode hors ligne';

  @override
  String get cacheResultsNotice => 'Resultats affiches depuis le cache.';

  @override
  String get offlineNoCacheNotice => 'Aucun resultat en cache pour ce mot.';

  @override
  String get searchEmptyTitle =>
      'Recherchez un mot pour charger des pictogrammes';

  @override
  String get phraseCurrent => 'Phrase actuelle';

  @override
  String get phraseEmpty => 'Touchez des pictogrammes pour creer une phrase.';

  @override
  String get speakPhrase => 'Lire la phrase';

  @override
  String get removeLast => 'Supprimer le dernier';

  @override
  String get clear => 'Effacer';

  @override
  String get savePhrase => 'Enregistrer la phrase';

  @override
  String get savedPhraseAdded => 'Phrase enregistree';

  @override
  String get savedPhrasesTitle => 'Phrases enregistrees';

  @override
  String get savedPhrasesEmpty => 'Aucune phrase enregistree';

  @override
  String get loadPhrase => 'Charger';

  @override
  String get deletePhrase => 'Supprimer';

  @override
  String get savePhraseDialogTitle => 'Enregistrer la phrase';

  @override
  String get savePhraseNameLabel => 'Nom (optionnel)';

  @override
  String get savePhraseNameHint => 'Exemple : Besoins de base';

  @override
  String get favoritesTitle => 'Favoris';

  @override
  String get favoritesSubtitle =>
      'Acces protege par PIN. Vos pictogrammes les plus utilises.';

  @override
  String get noFavoritesTitle => 'Pas encore de favoris';

  @override
  String get noFavoritesSubtitle =>
      'Touchez le coeur pour enregistrer des pictogrammes.';

  @override
  String get removeFavorite => 'Retirer';

  @override
  String get addToPhrase => 'Ajouter';

  @override
  String get saveFavorite => 'Enregistrer favori';

  @override
  String get removeFavoriteTooltip => 'Retirer favori';

  @override
  String get communicateNav => 'Communiquer';

  @override
  String get favoritesNav => 'Favoris';

  @override
  String get settingsAction => 'Parametres';

  @override
  String get settingsNav => 'Parametres';

  @override
  String get pictogramSize => 'Taille des pictogrammes';

  @override
  String get highContrast => 'Contraste eleve';

  @override
  String get reducedMotion => 'Reduire les animations';

  @override
  String get offlineOnly => 'Hors ligne uniquement';

  @override
  String get language => 'Langue';

  @override
  String get qualityFilters => 'Filtres de qualite';

  @override
  String get onlyAacFilter => 'Pictogrammes AAC uniquement';

  @override
  String get onlySchematicFilter => 'Pictogrammes schematiques uniquement';

  @override
  String get minDownloadsFilter => 'Telechargements minimum';

  @override
  String get cacheData => 'Donnees en cache';

  @override
  String cacheCount(int count) {
    return '$count recherches enregistrees';
  }

  @override
  String get clearCache => 'Vider le cache';

  @override
  String get cacheCleared => 'Cache vide';

  @override
  String get backupSection => 'Sauvegarde locale';

  @override
  String get backupPathLabel => 'Chemin de sauvegarde';

  @override
  String get exportBackup => 'Exporter la sauvegarde';

  @override
  String get restoreBackup => 'Restaurer la sauvegarde';

  @override
  String get backupExported => 'Sauvegarde exportee';

  @override
  String get backupMissing => 'Aucune sauvegarde trouvee';

  @override
  String get backupRestored => 'Sauvegarde restauree';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get continueText => 'Continuer';

  @override
  String get pinCreateTitle => 'Configurer le PIN';

  @override
  String get pinNew => 'Nouveau PIN';

  @override
  String get pinConfirm => 'Confirmer le PIN';

  @override
  String get pinInvalidRule => 'Utilisez 4 a 6 chiffres.';

  @override
  String get pinMismatch => 'Les codes ne correspondent pas.';

  @override
  String get pinSave => 'Enregistrer le PIN';

  @override
  String get pinCreated => 'PIN cree avec succes';

  @override
  String get recoveryCodeTitle => 'Code de recuperation';

  @override
  String get recoveryCodeMessage =>
      'Conservez ce code en lieu sur. Il est requis si vous oubliez le PIN.';

  @override
  String get unlockFavoritesTitle => 'Debloquer les favoris';

  @override
  String get pinLabel => 'PIN';

  @override
  String get pinIncorrect => 'PIN incorrect';

  @override
  String pinLockedSeconds(int seconds) {
    return 'Trop de tentatives. Reessayez dans ${seconds}s.';
  }

  @override
  String remainingAttempts(int count) {
    return 'Tentatives restantes : $count';
  }

  @override
  String get recoverPin => 'Recuperer le PIN';

  @override
  String get recoverPinTitle => 'Recuperer le PIN avec le code';

  @override
  String get recoveryCodeLabel => 'Code de recuperation';

  @override
  String get newPinLabel => 'Nouveau PIN';

  @override
  String get confirmNewPinLabel => 'Confirmer le nouveau PIN';

  @override
  String get recoverAction => 'Recuperer';

  @override
  String get pinResetSuccess => 'PIN reinitialise';

  @override
  String get changePinAction => 'Changer le PIN';

  @override
  String get changePinTitle => 'Changer le PIN';

  @override
  String get pinChanged => 'PIN mis a jour';

  @override
  String get lockFavorites => 'Verrouiller les favoris';

  @override
  String get favoriteSaved => 'Ajoute aux favoris';

  @override
  String get favoriteRemoved => 'Supprime des favoris';

  @override
  String get categoryNeeds => 'Besoins';

  @override
  String get categoryEmotions => 'Emotions';

  @override
  String get categorySchool => 'Ecole';

  @override
  String get categoryHome => 'Maison';

  @override
  String get categoryHealth => 'Sante';

  @override
  String get quickWant => 'je veux';

  @override
  String get quickEat => 'manger';

  @override
  String get quickDrink => 'boire';

  @override
  String get quickBathroom => 'toilettes';

  @override
  String get quickPlay => 'jouer';

  @override
  String get quickSleep => 'dormir';

  @override
  String get quickHappy => 'heureux';

  @override
  String get quickSad => 'triste';

  @override
  String get quickAngry => 'en colere';

  @override
  String get quickFear => 'peur';

  @override
  String get quickCalm => 'calme';

  @override
  String get quickSchool => 'ecole';

  @override
  String get quickTeacher => 'professeur';

  @override
  String get quickRead => 'lire';

  @override
  String get quickWrite => 'ecrire';

  @override
  String get quickHome => 'maison';

  @override
  String get quickMom => 'maman';

  @override
  String get quickDad => 'papa';

  @override
  String get quickDoctor => 'docteur';

  @override
  String get quickPain => 'douleur';

  @override
  String get quickMedicine => 'medicament';

  @override
  String get quickHelp => 'aide';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languageFrench => 'Francais';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get languageItalian => 'Italien';

  @override
  String get legalSection => 'Informations legales';

  @override
  String get termsOfUse => 'Conditions d\'utilisation';

  @override
  String get privacyPolicy => 'Politique de confidentialite';

  @override
  String get creditsTitle => 'Credits';

  @override
  String get creditsAppDescription =>
      'Application de Communication Alternative et Amelioree (CAA).';

  @override
  String get creditsDevelopment => 'Developpement';

  @override
  String get creditsAssociation => 'Association';

  @override
  String get creditsPictograms => 'Pictogrammes';

  @override
  String get creditsArasaacDescription =>
      'Pictogrammes crees par Sergio Palao pour le Gouvernement d\'Aragon.';

  @override
  String get showSearch => 'Recherche';

  @override
  String get serviceUnavailable => 'ARASAAC n\'est pas disponible. Reessayez.';
}
