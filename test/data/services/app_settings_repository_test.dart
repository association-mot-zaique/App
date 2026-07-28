import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mot_zaique/data/models/app_settings.dart';
import 'package:mot_zaique/data/services/app_settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSettingsRepository', () {
    test('returns defaults when storage is empty', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = AppSettingsRepository(preferences);

      final settings = repository.read();

      expect(settings.localeCode, AppSettings.defaults.localeCode);
      expect(settings.pictogramScale, AppSettings.defaults.pictogramScale);
      // Landscape by default: the closest to the physical classeur (retour
      // client), and a screen that never rotates on its own.
      expect(settings.orientationMode, OrientationMode.landscape);
    });

    test('save and read preserve values', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = AppSettingsRepository(preferences);

      const settings = AppSettings(
        pictogramScale: 1.4,
        highContrast: true,
        reducedMotion: true,
        offlineOnly: true,
        localeCode: 'fr',
        onlyAacPictograms: false,
        onlySchematicPictograms: true,
        minDownloads: 120,
        savedPhrasesEnabled: true,
        speechRate: 0.6,
        gridColumns: 4,
        showPictogramLabel: false,
        orientationMode: OrientationMode.portrait,
      );

      await repository.save(settings);
      final restored = repository.read();

      expect(restored.pictogramScale, 1.4);
      expect(restored.highContrast, isTrue);
      expect(restored.reducedMotion, isTrue);
      expect(restored.offlineOnly, isTrue);
      expect(restored.localeCode, 'fr');
      expect(restored.onlyAacPictograms, isFalse);
      expect(restored.onlySchematicPictograms, isTrue);
      expect(restored.minDownloads, 120);
      expect(restored.speechRate, 0.6);
      expect(restored.gridColumns, 4);
      expect(restored.showPictogramLabel, isFalse);
      expect(restored.orientationMode, OrientationMode.portrait);
    });

    test('falls back to landscape when the stored orientation is unknown', () {
      final settings = AppSettings.fromJson({'orientationMode': 'diagonal'});

      expect(settings.orientationMode, OrientationMode.landscape);
    });

    test('defaults to automatic locale (follows the system)', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final repository = AppSettingsRepository(preferences);

      final settings = repository.read();

      expect(settings.localeCode, '');
      expect(settings.isAutomaticLocale, isTrue);
      expect(settings.locale, isNull);
    });

    test('migrates legacy v1 "es" default to automatic', () async {
      // Legacy prototype data: no schemaVersion, localeCode pinned to 'es'.
      SharedPreferences.setMockInitialValues({
        'app_settings_v1': '{"localeCode":"es","pictogramScale":1.0}',
      });
      final preferences = await SharedPreferences.getInstance();
      final repository = AppSettingsRepository(preferences);

      final settings = repository.read();

      expect(settings.isAutomaticLocale, isTrue);
      expect(settings.locale, isNull);
    });

    test('keeps a deliberate v2 Spanish choice', () async {
      SharedPreferences.setMockInitialValues({
        'app_settings_v1': '{"schemaVersion":2,"localeCode":"es"}',
      });
      final preferences = await SharedPreferences.getInstance();
      final repository = AppSettingsRepository(preferences);

      final settings = repository.read();

      expect(settings.localeCode, 'es');
      expect(settings.locale, const Locale('es'));
    });

    test('migrates v2 minDownloads back to 0', () async {
      // A positive threshold discarded every ARASAAC result (the API always
      // reports 0 downloads), leaving an empty communication screen.
      SharedPreferences.setMockInitialValues({
        'app_settings_v1': '{"schemaVersion":2,"minDownloads":250}',
      });
      final preferences = await SharedPreferences.getInstance();
      final repository = AppSettingsRepository(preferences);

      expect(repository.read().minDownloads, 0);
    });

    test('keeps minDownloads once the data is on v3', () async {
      SharedPreferences.setMockInitialValues({
        'app_settings_v1': '{"schemaVersion":3,"minDownloads":250}',
      });
      final preferences = await SharedPreferences.getInstance();
      final repository = AppSettingsRepository(preferences);

      expect(repository.read().minDownloads, 250);
    });
  });
}
