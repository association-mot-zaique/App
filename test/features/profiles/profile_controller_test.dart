import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mot_zaique/data/models/profile.dart';
import 'package:mot_zaique/data/services/app_settings_repository.dart';
import 'package:mot_zaique/data/services/local_classeur_repository.dart';
import 'package:mot_zaique/data/services/profile_repository.dart';
import 'package:mot_zaique/features/classeur/local_classeur_controller.dart';
import 'package:mot_zaique/features/profiles/profile_controller.dart';
import 'package:mot_zaique/features/settings/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late LocalClasseurController classeurController;
  late SettingsController settingsController;
  late ProfileController profiles;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    tempDir = Directory.systemTemp.createTempSync('profiles_test');

    final classeurRepository =
        LocalClasseurRepository(Directory('${tempDir.path}/placeholder'));
    final settingsRepository = AppSettingsRepository(preferences);
    classeurController = LocalClasseurController(classeurRepository);
    settingsController = SettingsController(settingsRepository);

    profiles = ProfileController(
      repository: ProfileRepository(preferences),
      classeurRepository: classeurRepository,
      settingsRepository: settingsRepository,
      classeurController: classeurController,
      settingsController: settingsController,
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

    test('refuses a duplicate profile name', () async {
      expect(await profiles.addProfile('Leo'), isTrue);
      expect(await profiles.addProfile('  leo '), isFalse);
      expect(profiles.profiles, hasLength(2));
    });

    test('rename a profile', () async {
      await profiles.addProfile('Leo');
      final id = profiles.activeId;

      expect(await profiles.renameProfile(id, 'Leonie'), isTrue);
      expect(
        profiles.profiles.firstWhere((p) => p.id == id).name,
        'Leonie',
      );
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
