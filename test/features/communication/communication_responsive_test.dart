import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mot_zaique/core/theme/pastel_theme.dart';
import 'package:mot_zaique/data/models/pictogram.dart';
import 'package:mot_zaique/data/models/pictogram_search_result.dart';
import 'package:mot_zaique/data/services/app_settings_repository.dart';
import 'package:mot_zaique/data/services/favorites_repository.dart';
import 'package:mot_zaique/data/services/phrase_book_repository.dart';
import 'package:mot_zaique/data/services/pictogram_search_service.dart';
import 'package:mot_zaique/data/services/speech_service.dart';
import 'package:mot_zaique/features/communication/communication_screen.dart';
import 'package:mot_zaique/features/communication/phrase_book_controller.dart';
import 'package:mot_zaique/features/favorites/favorites_controller.dart';
import 'package:mot_zaique/features/settings/settings_controller.dart';
import 'package:mot_zaique/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeSearchService implements PictogramSearchService {
  @override
  Future<PictogramSearchResult> search(
    String query, {
    required String language,
    required bool offlineOnly,
    required bool onlyAacPictograms,
    required bool onlySchematicPictograms,
    required int minDownloads,
  }) async {
    final results = List.generate(
      12,
      (index) => Pictogram(
        id: index + 1,
        label: '$query-$index',
        tags: const [],
        language: language,
      ),
    );

    return PictogramSearchResult(
      pictograms: results,
      source: SearchResultSource.network,
      offlineOnly: offlineOnly,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<Widget> buildScreen() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();

    final favoritesController = FavoritesController(
      FavoritesRepository(preferences),
    );
    final phraseController = PhraseBookController(
      PhraseBookRepository(preferences),
    );
    final settingsController = SettingsController(
      AppSettingsRepository(preferences),
    );

    await favoritesController.load();
    await phraseController.load();
    await settingsController.load();

    return MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('fr'),
        Locale('en'),
        Locale('de'),
        Locale('it'),
      ],
      theme: PastelTheme.build(settingsController.settings),
      home: Scaffold(
        body: CommunicationScreen(
          searchService: _FakeSearchService(),
          favoritesController: favoritesController,
          phraseBookController: phraseController,
          settingsController: settingsController,
          speechService: NoopSpeechService(),
        ),
      ),
    );
  }

  testWidgets('uses 2 columns on mobile width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(await buildScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    final gridView = tester.widget<GridView>(find.byType(GridView).first);
    final delegate =
        gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

    expect(delegate.crossAxisCount, 2);
  });

  testWidgets('uses 5 columns on tablet width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1024, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(await buildScreen());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    final gridView = tester.widget<GridView>(find.byType(GridView).first);
    final delegate =
        gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

    expect(delegate.crossAxisCount, 5);
  });
}
