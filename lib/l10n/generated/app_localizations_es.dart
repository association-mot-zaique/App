// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MOT-ZAIQUE';

  @override
  String get communicateTitle => 'Comunicar';

  @override
  String get communicateSubtitle =>
      'Selecciona pictogramas para construir la frase y reproducirla.';

  @override
  String get searchHint => 'Buscar pictogramas en ARASAAC';

  @override
  String get searchButton => 'Buscar';

  @override
  String get offlineModeChip => 'Modo sin conexion';

  @override
  String get cacheResultsNotice => 'Mostrando resultados desde cache.';

  @override
  String get offlineNoCacheNotice =>
      'No hay resultados guardados para esta palabra.';

  @override
  String get searchEmptyTitle => 'Busca una palabra para cargar pictogramas';

  @override
  String get phraseCurrent => 'Frase actual';

  @override
  String get phraseEmpty => 'Toca pictogramas para construir una frase.';

  @override
  String get speakPhrase => 'Hablar frase';

  @override
  String get removeLast => 'Quitar ultimo';

  @override
  String get clear => 'Limpiar';

  @override
  String get savePhrase => 'Guardar frase';

  @override
  String get savedPhraseAdded => 'Frase guardada';

  @override
  String get savedPhrasesTitle => 'Frases guardadas';

  @override
  String get savedPhrasesEmpty => 'No hay frases guardadas';

  @override
  String get loadPhrase => 'Cargar';

  @override
  String get deletePhrase => 'Eliminar';

  @override
  String get savePhraseDialogTitle => 'Guardar frase';

  @override
  String get savePhraseNameLabel => 'Nombre (opcional)';

  @override
  String get savePhraseNameHint => 'Ejemplo: Necesidades basicas';

  @override
  String get favoritesTitle => 'Favoritos';

  @override
  String get favoritesSubtitle =>
      'Acceso protegido por PIN. Tus pictogramas mas usados.';

  @override
  String get noFavoritesTitle => 'No hay favoritos';

  @override
  String get noFavoritesSubtitle => 'Toca el corazon para guardar pictogramas.';

  @override
  String get removeFavorite => 'Quitar';

  @override
  String get addToPhrase => 'Agregar';

  @override
  String get saveFavorite => 'Guardar favorito';

  @override
  String get removeFavoriteTooltip => 'Quitar favorito';

  @override
  String get communicateNav => 'Comunicar';

  @override
  String get favoritesNav => 'Favoritos';

  @override
  String get settingsAction => 'Ajustes';

  @override
  String get settingsNav => 'Ajustes';

  @override
  String get pictogramSize => 'Tamano de pictogramas';

  @override
  String get highContrast => 'Alto contraste';

  @override
  String get reducedMotion => 'Reducir movimiento';

  @override
  String get offlineOnly => 'Solo sin conexion';

  @override
  String get language => 'Idioma';

  @override
  String get qualityFilters => 'Filtros de calidad';

  @override
  String get onlyAacFilter => 'Solo pictogramas AAC';

  @override
  String get onlySchematicFilter => 'Solo pictogramas esquematicos';

  @override
  String get minDownloadsFilter => 'Minimo de descargas';

  @override
  String get cacheData => 'Datos en cache';

  @override
  String cacheCount(int count) {
    return '$count busquedas guardadas';
  }

  @override
  String get clearCache => 'Limpiar cache';

  @override
  String get cacheCleared => 'Cache limpiada';

  @override
  String get backupSection => 'Respaldo local';

  @override
  String get backupPathLabel => 'Ruta de respaldo';

  @override
  String get exportBackup => 'Exportar respaldo';

  @override
  String get restoreBackup => 'Restaurar respaldo';

  @override
  String get backupExported => 'Respaldo exportado';

  @override
  String get backupMissing => 'No existe respaldo para restaurar';

  @override
  String get backupRestored => 'Respaldo restaurado';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get continueText => 'Continuar';

  @override
  String get pinCreateTitle => 'Configurar PIN';

  @override
  String get pinNew => 'Nuevo PIN';

  @override
  String get pinConfirm => 'Confirmar PIN';

  @override
  String get pinInvalidRule => 'Usa de 4 a 6 digitos numericos.';

  @override
  String get pinMismatch => 'Los codigos no coinciden.';

  @override
  String get pinSave => 'Guardar PIN';

  @override
  String get pinCreated => 'PIN creado correctamente';

  @override
  String get recoveryCodeTitle => 'Codigo de recuperacion';

  @override
  String get recoveryCodeMessage =>
      'Guarda este codigo en un lugar seguro. Lo necesitaras si olvidas el PIN.';

  @override
  String get unlockFavoritesTitle => 'Desbloquear favoritos';

  @override
  String get pinLabel => 'PIN';

  @override
  String get pinIncorrect => 'PIN incorrecto';

  @override
  String pinLockedSeconds(int seconds) {
    return 'Demasiados intentos. Intenta nuevamente en ${seconds}s.';
  }

  @override
  String remainingAttempts(int count) {
    return 'Intentos restantes: $count';
  }

  @override
  String get recoverPin => 'Recuperar PIN';

  @override
  String get recoverPinTitle => 'Recuperar PIN con codigo';

  @override
  String get recoveryCodeLabel => 'Codigo de recuperacion';

  @override
  String get newPinLabel => 'Nuevo PIN';

  @override
  String get confirmNewPinLabel => 'Confirmar nuevo PIN';

  @override
  String get recoverAction => 'Recuperar';

  @override
  String get pinResetSuccess => 'PIN restablecido';

  @override
  String get changePinAction => 'Cambiar PIN';

  @override
  String get changePinTitle => 'Cambiar PIN';

  @override
  String get pinChanged => 'PIN actualizado';

  @override
  String get lockFavorites => 'Bloquear favoritos';

  @override
  String get favoriteSaved => 'Guardado en favoritos';

  @override
  String get favoriteRemoved => 'Eliminado de favoritos';

  @override
  String get categoryNeeds => 'Necesidades';

  @override
  String get categoryEmotions => 'Emociones';

  @override
  String get categorySchool => 'Escuela';

  @override
  String get categoryHome => 'Casa';

  @override
  String get categoryHealth => 'Salud';

  @override
  String get quickWant => 'quiero';

  @override
  String get quickEat => 'comer';

  @override
  String get quickDrink => 'beber';

  @override
  String get quickBathroom => 'bano';

  @override
  String get quickPlay => 'jugar';

  @override
  String get quickSleep => 'dormir';

  @override
  String get quickHappy => 'feliz';

  @override
  String get quickSad => 'triste';

  @override
  String get quickAngry => 'enojado';

  @override
  String get quickFear => 'miedo';

  @override
  String get quickCalm => 'calma';

  @override
  String get quickSchool => 'escuela';

  @override
  String get quickTeacher => 'maestro';

  @override
  String get quickRead => 'leer';

  @override
  String get quickWrite => 'escribir';

  @override
  String get quickHome => 'casa';

  @override
  String get quickMom => 'mama';

  @override
  String get quickDad => 'papa';

  @override
  String get quickDoctor => 'doctor';

  @override
  String get quickPain => 'dolor';

  @override
  String get quickMedicine => 'medicina';

  @override
  String get quickHelp => 'ayuda';

  @override
  String get languageSpanish => 'Espanol';

  @override
  String get languageFrench => 'Frances';

  @override
  String get languageEnglish => 'Ingles';

  @override
  String get languageGerman => 'Aleman';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageAutomatic => 'Automatico (idioma del sistema)';

  @override
  String get legalSection => 'Legal';

  @override
  String get termsOfUse => 'Condiciones de uso';

  @override
  String get privacyPolicy => 'Politica de privacidad';

  @override
  String get creditsTitle => 'Creditos';

  @override
  String get creditsAppDescription =>
      'Aplicacion de Comunicacion Alternativa y Aumentativa (CAA).';

  @override
  String get creditsDevelopment => 'Desarrollo';

  @override
  String get creditsAssociation => 'Asociacion';

  @override
  String get creditsPictograms => 'Pictogramas';

  @override
  String get creditsArasaacDescription =>
      'Pictogramas creados por Sergio Palao para el Gobierno de Aragon.';

  @override
  String get showSearch => 'Buscar';

  @override
  String get serviceUnavailable =>
      'ARASAAC no esta disponible. Intenta de nuevo.';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get renameAction => 'Renombrar';

  @override
  String get classeurManageTitle => 'Gestionar el cuaderno';

  @override
  String get classeurEmpty => 'Aun no hay categorias. Anade una para empezar.';

  @override
  String get addCategory => 'Anadir categoria';

  @override
  String get categoryNameLabel => 'Nombre de la categoria';

  @override
  String get deleteCategoryConfirm =>
      'Eliminar esta categoria y todos sus pictogramas?';

  @override
  String get pictogramsWord => 'pictogramas';

  @override
  String get addPictogram => 'Anadir pictograma';

  @override
  String get pictogramLabelLabel => 'Etiqueta del pictograma';

  @override
  String get deletePictogramConfirm => 'Eliminar este pictograma?';

  @override
  String get categoryEmptyPictograms =>
      'Aun no hay pictogramas en esta categoria.';

  @override
  String get importFromArasaac => 'Anadir desde ARASAAC';

  @override
  String get pictogramAddedNotice => 'Pictograma anadido';

  @override
  String get lockAidant => 'Bloquear el modo asistente';

  @override
  String get addFromFile => 'Desde un archivo';

  @override
  String get addFromCamera => 'Tomar una foto';

  @override
  String get creditsLicense => 'Licencia';

  @override
  String get creditsLicenseDescription =>
      'MOT-ZAIQUE es software libre, publicado bajo la licencia GNU General Public License v3.0.';

  @override
  String get savedPhrasesToggle => 'Activar frases guardadas';

  @override
  String get categorySuggestionsLabel => 'Sugerencias';

  @override
  String get suggestionMeals => 'Comidas';

  @override
  String get suggestionPeople => 'Personas';

  @override
  String get suggestionActivities => 'Actividades';

  @override
  String get suggestionPlaces => 'Lugares';

  @override
  String get suggestionToys => 'Juguetes';

  @override
  String get categoryExists => 'Esta categoria ya existe';

  @override
  String get addStarterCategories => 'Anadir categorias iniciales';

  @override
  String get speechRate => 'Velocidad de voz';

  @override
  String get pictogramsPerScreen => 'Pictogramas por pantalla';

  @override
  String get showPictogramLabel => 'Mostrar el texto bajo el pictograma';

  @override
  String get automaticOption => 'Automatico';

  @override
  String get exportClasseur => 'Exportar el cuaderno';

  @override
  String get importClasseur => 'Importar un cuaderno';

  @override
  String get classeurExported => 'Cuaderno exportado';

  @override
  String get classeurImported => 'Cuaderno importado';

  @override
  String get importClasseurConfirm =>
      'Reemplazar el cuaderno actual por el importado? Se perdera el actual.';

  @override
  String get classeurImportFailed => 'Archivo de cuaderno no valido';
}
