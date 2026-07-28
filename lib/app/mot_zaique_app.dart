import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/pastel_theme.dart';
import '../data/models/app_settings.dart';
import '../data/services/local_backup_service.dart';
import '../data/services/pin_repository.dart';
import '../data/services/pictogram_search_service.dart';
import '../data/services/search_cache_repository.dart';
import '../data/services/speech_service.dart';
import '../features/classeur/local_classeur_controller.dart';
import '../features/communication/phrase_book_controller.dart';
import '../features/profiles/profile_controller.dart';
import '../features/favorites/favorites_controller.dart';
import '../features/home/home_shell.dart';
import '../features/settings/settings_controller.dart';
import '../l10n/generated/app_localizations.dart';

class MotZaiqueApp extends StatefulWidget {
  const MotZaiqueApp({
    required this.searchService,
    required this.searchCacheRepository,
    required this.favoritesController,
    required this.phraseBookController,
    required this.settingsController,
    required this.classeurController,
    required this.profileController,
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
  final LocalClasseurController classeurController;
  final ProfileController profileController;
  final PinRepository pinRepository;
  final SpeechService speechService;
  final LocalBackupService localBackupService;

  @override
  State<MotZaiqueApp> createState() => _MotZaiqueAppState();
}

class _MotZaiqueAppState extends State<MotZaiqueApp> {
  OrientationMode? _appliedOrientationMode;

  @override
  void initState() {
    super.initState();
    _applyOrientationMode();
    widget.settingsController.addListener(_applyOrientationMode);
  }

  @override
  void dispose() {
    widget.settingsController.removeListener(_applyOrientationMode);
    super.dispose();
  }

  /// A rotating screen is deeply disorienting for an autistic user (retour
  /// client), so the app is locked in landscape by default — the closest to
  /// the physical classeur — and the aidant can pick portrait or automatic.
  void _applyOrientationMode() {
    final mode = widget.settingsController.settings.orientationMode;
    if (mode == _appliedOrientationMode) {
      return;
    }
    _appliedOrientationMode = mode;

    switch (mode) {
      case OrientationMode.landscape:
        SystemChrome.setPreferredOrientations(const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      case OrientationMode.portrait:
        SystemChrome.setPreferredOrientations(const [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      case OrientationMode.automatic:
        // An empty list restores the device's own rotation behaviour.
        SystemChrome.setPreferredOrientations(const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.settingsController,
      builder: (context, _) {
        final settings = widget.settingsController.settings;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // Null when the user leaves the language on "automatic": Flutter then
          // resolves the locale from the device's ordered language list.
          locale: settings.locale,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          // French is first so it is the ultimate fallback when none of the
          // device languages are supported.
          supportedLocales: const [
            Locale('fr'),
            Locale('es'),
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
            searchService: widget.searchService,
            searchCacheRepository: widget.searchCacheRepository,
            favoritesController: widget.favoritesController,
            phraseBookController: widget.phraseBookController,
            settingsController: widget.settingsController,
            classeurController: widget.classeurController,
            profileController: widget.profileController,
            pinRepository: widget.pinRepository,
            speechService: widget.speechService,
            localBackupService: widget.localBackupService,
          ),
        );
      },
    );
  }
}
