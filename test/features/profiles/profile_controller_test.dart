import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mot_zaique/data/models/pictogram.dart';
import 'package:mot_zaique/data/models/profile.dart';
import 'package:mot_zaique/data/services/app_settings_repository.dart';
import 'package:mot_zaique/data/services/favorites_repository.dart';
import 'package:mot_zaique/data/services/local_classeur_repository.dart';
import 'package:mot_zaique/data/services/phrase_book_repository.dart';
import 'package:mot_zaique/data/services/profile_repository.dart';
import 'package:mot_zaique/features/classeur/local_classeur_controller.dart';
import 'package:mot_zaique/features/communication/phrase_book_controller.dart';
import 'package:mot_zaique/features/favorites/favorites_controller.dart';
import 'package:mot_zaique/features/profiles/profile_controller.dart';
import 'package:mot_zaique/features/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Pictogram _pictogram(int id, String label) =>
    Pictogram(id: id, label: label, language: 'fr');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late LocalClasseurController classeurController;
  late SettingsController settingsController;
  late FavoritesController favoritesController;
  late PhraseBookController phraseBookController;
  late ProfileController profiles;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    tempDir = Directory.systemTemp.createTempSync('profiles_test');

    final classeurRepository = LocalClasseurRepository(
      Directory('${tempDir.path}/placeholder'),
    );
    final settingsRepository = AppSettingsRepository(preferences);
    final favoritesRepository = FavoritesRepository(preferences);
    final phraseBookRepository = PhraseBookRepository(preferences);
    classeurController = LocalClasseurController(classeurRepository);
    settingsController = SettingsController(settingsRepository);
    favoritesController = FavoritesController(favoritesRepository);
    phraseBookController = PhraseBookController(phraseBookRepository);

    profiles = ProfileController(
      repository: ProfileRepository(preferences),
      classeurRepository: classeurRepository,
      settingsRepository: settingsRepository,
      favoritesRepository: favoritesRepository,
      phraseBookRepository: phraseBookRepository,
      classeurController: classeurController,
      settingsController: settingsController,
      favoritesController: favoritesController,
      phraseBookController: phraseBookController,
      documentsDir: tempDir,
      defaultProfileName: 'Profil 1',
    );
    await profiles.load();
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('ProfileController (US-3.03)', () {
    test('starts on a single default profile', () {
      expect(profiles.profiles, hasLength(1));
      expect(profiles.activeId, Profile.defaultId);
    });

    test('each profile owns its classeur', () async {
      await classeurController.addCategory('Maison');
      expect(classeurController.classeur.categories, hasLength(1));

      // A new profile starts from an empty classeur...
      final added = await profiles.addProfile('Leo');
      expect(added, isTrue);
      expect(profiles.profiles, hasLength(2));
      expect(classeurController.classeur.categories, isEmpty);

      await classeurController.addCategory('Ecole');
      expect(classeurController.classeur.categories.single.name, 'Ecole');

      // ...and switching back restores the first profile's classeur.
      await profiles.switchTo(Profile.defaultId);
      expect(classeurController.classeur.categories.single.name, 'Maison');
    });

    test('each profile owns its favorites', () async {
      await favoritesController.toggleFavorite(_pictogram(1, 'manger'));
      expect(favoritesController.favorites, hasLength(1));

      await profiles.addProfile('Leo');
      expect(favoritesController.favorites, isEmpty);

      await favoritesController.toggleFavorite(_pictogram(2, 'jouer'));
      expect(favoritesController.favorites.single.label, 'jouer');

      await profiles.switchTo(Profile.defaultId);
      expect(favoritesController.favorites.single.label, 'manger');
    });

    test('each profile owns its phrase band and saved phrases', () async {
      await phraseBookController.addToCurrent(_pictogram(1, 'je veux'));
      await phraseBookController.saveCurrentAsPhrase(customName: 'Demande');
      expect(phraseBookController.currentPhrase, hasLength(1));
      expect(phraseBookController.savedPhrases, hasLength(1));

      await profiles.addProfile('Leo');
      expect(phraseBookController.currentPhrase, isEmpty);
      expect(phraseBookController.savedPhrases, isEmpty);

      await phraseBookController.addToCurrent(_pictogram(2, 'dormir'));

      await profiles.switchTo(Profile.defaultId);
      expect(phraseBookController.currentPhrase.single.label, 'je veux');
      expect(phraseBookController.savedPhrases.single.name, 'Demande');
    });

    test('deleting a profile drops its favorites and phrases', () async {
      await profiles.addProfile('Leo');
      final leoId = profiles.activeId;
      await favoritesController.toggleFavorite(_pictogram(3, 'boire'));
      await phraseBookController.addToCurrent(_pictogram(3, 'boire'));

      expect(await profiles.deleteProfile(leoId), isTrue);
      expect(profiles.activeId, Profile.defaultId);

      // Recreating a profile reuses the id: its storage must come back empty.
      await profiles.addProfile('Leo');
      expect(profiles.activeId, leoId);
      expect(favoritesController.favorites, isEmpty);
      expect(phraseBookController.currentPhrase, isEmpty);
    });

    test('refuses a duplicate profile name', () async {
      expect(await profiles.addProfile('Leo'), isTrue);
      expect(await profiles.addProfile('  leo '), isFalse);
      expect(profiles.profiles, hasLength(2));
    });

    test('rename a profile', () async {
      await profiles.addProfile('Leo');
      final id = profiles.activeId;

      expect(await profiles.renameProfile(id, 'Leonie'), isTrue);
      expect(profiles.profiles.firstWhere((p) => p.id == id).name, 'Leonie');
    });

    test('deleting the active profile falls back to another one', () async {
      await profiles.addProfile('Leo');
      final leoId = profiles.activeId;

      expect(await profiles.deleteProfile(leoId), isTrue);
      expect(profiles.profiles, hasLength(1));
      expect(profiles.activeId, Profile.defaultId);
    });

    test('the last profile cannot be deleted', () async {
      expect(await profiles.deleteProfile(Profile.defaultId), isFalse);
      expect(profiles.profiles, hasLength(1));
    });
  });
}
