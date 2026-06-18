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
    });
  });
}
