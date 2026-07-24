import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/mot_zaique_app.dart';
import 'data/services/app_settings_repository.dart';
import 'data/services/arasaac_api.dart';
import 'data/services/favorites_repository.dart';
import 'data/services/local_backup_service.dart';
import 'data/services/local_classeur_repository.dart';
import 'data/services/phrase_book_repository.dart';
import 'data/services/pictogram_search_service.dart';
import 'data/services/pin_repository.dart';
import 'data/services/profile_repository.dart';
import 'data/services/search_cache_repository.dart';
import 'data/services/speech_service.dart';
import 'features/classeur/local_classeur_controller.dart';
import 'features/communication/phrase_book_controller.dart';
import 'features/favorites/favorites_controller.dart';
import 'features/profiles/profile_controller.dart';
import 'features/settings/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();

  final arasaacApi = ArasaacApi();
  final searchCacheRepository = SearchCacheRepository(preferences);
  final searchService = ArasaacSearchService(
    api: arasaacApi,
    cache: searchCacheRepository,
  );

  final favoritesRepository = FavoritesRepository(preferences);
  final phraseBookRepository = PhraseBookRepository(preferences);
  final favoritesController = FavoritesController(favoritesRepository);
  final phraseBookController = PhraseBookController(phraseBookRepository);
  final settingsRepository = AppSettingsRepository(preferences);
  final settingsController = SettingsController(settingsRepository);
  final localBackupService = LocalBackupService(preferences);

  final classeurRepository = await LocalClasseurRepository.create();
  final classeurController = LocalClasseurController(classeurRepository);

  // Profiles (A-11) : points every per-user repository at the active profile,
  // then loads its data. It also loads the favoris and phrase controllers, so
  // they must not be loaded separately — their storage key depends on the
  // profile resolved here.
  final documentsDir = await getApplicationDocumentsDirectory();
  final profileController = ProfileController(
    repository: ProfileRepository(preferences),
    classeurRepository: classeurRepository,
    settingsRepository: settingsRepository,
    favoritesRepository: favoritesRepository,
    phraseBookRepository: phraseBookRepository,
    classeurController: classeurController,
    settingsController: settingsController,
    favoritesController: favoritesController,
    phraseBookController: phraseBookController,
    documentsDir: documentsDir,
    defaultProfileName: 'Profil 1',
  );

  await profileController.load();

  runApp(
    MotZaiqueApp(
      searchService: searchService,
      searchCacheRepository: searchCacheRepository,
      favoritesController: favoritesController,
      phraseBookController: phraseBookController,
      settingsController: settingsController,
      classeurController: classeurController,
      profileController: profileController,
      pinRepository: PinRepository(preferences),
      speechService: FlutterSpeechService(),
      localBackupService: localBackupService,
    ),
  );
}
