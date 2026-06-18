import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/mot_zaique_app.dart';
import 'data/services/app_settings_repository.dart';
import 'data/services/arasaac_api.dart';
import 'data/services/favorites_repository.dart';
import 'data/services/local_backup_service.dart';
import 'data/services/phrase_book_repository.dart';
import 'data/services/pictogram_search_service.dart';
import 'data/services/pin_repository.dart';
import 'data/services/search_cache_repository.dart';
import 'data/services/speech_service.dart';
import 'features/communication/phrase_book_controller.dart';
import 'features/favorites/favorites_controller.dart';
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
  final settingsController = SettingsController(
    AppSettingsRepository(preferences),
  );
  final localBackupService = LocalBackupService(preferences);

  await Future.wait([
    favoritesController.load(),
    phraseBookController.load(),
    settingsController.load(),
  ]);

  runApp(
    MotZaiqueApp(
      searchService: searchService,
      searchCacheRepository: searchCacheRepository,
      favoritesController: favoritesController,
      phraseBookController: phraseBookController,
      settingsController: settingsController,
      pinRepository: PinRepository(preferences),
      speechService: FlutterSpeechService(),
      localBackupService: localBackupService,
    ),
  );
}
