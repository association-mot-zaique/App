import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/pastel_theme.dart';
import '../data/services/local_backup_service.dart';
import '../data/services/pin_repository.dart';
import '../data/services/pictogram_search_service.dart';
import '../data/services/search_cache_repository.dart';
import '../data/services/speech_service.dart';
import '../features/communication/phrase_book_controller.dart';
import '../features/favorites/favorites_controller.dart';
import '../features/home/home_shell.dart';
import '../features/settings/settings_controller.dart';
import '../l10n/generated/app_localizations.dart';

class MotZaiqueApp extends StatelessWidget {
  const MotZaiqueApp({
    required this.searchService,
    required this.searchCacheRepository,
    required this.favoritesController,
    required this.phraseBookController,
    required this.settingsController,
    required this.pinRepository,
    required this.speechService,
    required this.localBackupService,
    super.key,
  });

  final PictogramSearchService searchService;
  final SearchCacheRepository searchCacheRepository;
  final FavoritesController favoritesController;
  final PhraseBookController phraseBookController;
  final SettingsController settingsController;
  final PinRepository pinRepository;
  final SpeechService speechService;
  final LocalBackupService localBackupService;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        final settings = settingsController.settings;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: settings.locale,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          supportedLocales: const [
            Locale('es'),
            Locale('fr'),
            Locale('en'),
            Locale('de'),
            Locale('it'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: PastelTheme.build(settings),
          home: HomeShell(
            searchService: searchService,
            searchCacheRepository: searchCacheRepository,
            favoritesController: favoritesController,
            phraseBookController: phraseBookController,
            settingsController: settingsController,
            pinRepository: pinRepository,
            speechService: speechService,
            localBackupService: localBackupService,
          ),
        );
      },
    );
  }
}
