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

  final favoritesController = FavoritesController(
    FavoritesRepository(preferences),
  );
  final phraseBookController = PhraseBookController(
    PhraseBookRepository(preferences),
  );
  final settingsRepository = AppSettingsRepository(preferences);
  final settingsController = SettingsController(settingsRepository);
  final localBackupService = LocalBackupService(preferences);

  final classeurRepository = await LocalClasseurRepository.create();
  final classeurController = LocalClasseurController(classeurRepository);

  // Profiles (A-11) : points the classeur/settings repositories at the active
  // profile, then loads its data. Must run before using those controllers.
  final documentsDir = await getApplicationDocumentsDirectory();
  final profileController = ProfileController(
    repository: ProfileRepository(preferences),
    classeurRepository: classeurRepository,
    settingsRepository: settingsRepository,
    classeurController: classeurController,
    settingsController: settingsController,
    documentsDir: documentsDir,
    defaultProfileName: 'Profil 1',
  );

  await Future.wait([
    favoritesController.load(),
    phraseBookController.load(),
    profileController.load(),
  ]);

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
