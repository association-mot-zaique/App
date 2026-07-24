import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mot_zaique/data/services/local_backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDirectory;

  setUp(() {
    tempDirectory = Directory.systemTemp.createTempSync('mot-zaique-test-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
          if (methodCall.method == 'getApplicationDocumentsDirectory') {
            return tempDirectory.path;
          }
          return null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    if (tempDirectory.existsSync()) {
      await tempDirectory.delete(recursive: true);
    }
  });

  test('exports and restores local backup data', () async {
    SharedPreferences.setMockInitialValues({
      'favorite_pictograms_v1': [
        '{"id":1,"label":"hola","tags":[],"categories":[],"language":"es","aac":true,"schematic":false,"downloads":120}',
      ],
      'app_settings_v1': '{"localeCode":"fr"}',
      'favorites_pin_hash_v2': 'hashed-pin',
      'favorites_pin_failed_attempts_v1': 3,
    });

    final prefs = await SharedPreferences.getInstance();
    final backupService = LocalBackupService(prefs);

    final backupPath = await backupService.exportBackup();
    expect(File(backupPath).existsSync(), isTrue);

    await prefs.remove('favorite_pictograms_v1');
    await prefs.setString('app_settings_v1', '{"localeCode":"de"}');
    await prefs.setInt('favorites_pin_failed_attempts_v1', 0);

    final restored = await backupService.restoreBackup();
    expect(restored, isTrue);
    expect(prefs.getStringList('favorite_pictograms_v1'), isNotEmpty);
    expect(prefs.getString('app_settings_v1'), contains('"localeCode":"fr"'));
    expect(prefs.getInt('favorites_pin_failed_attempts_v1'), 3);
  });

  test('covers every profile, not only the active one', () async {
    SharedPreferences.setMockInitialValues({
      'profiles_v1': [
        '{"id":"default","name":"Profil 1"}',
        '{"id":"p1","name":"Leo"}',
      ],
      'active_profile_v1': 'p1',
      'app_settings_v1': '{"localeCode":"fr"}',
      'app_settings_v1_p1': '{"localeCode":"it"}',
      'favorite_pictograms_v1_p1': [
        '{"id":7,"label":"jouer","tags":[],"categories":[],"language":"fr","aac":true,"schematic":false,"downloads":0}',
      ],
    });

    final prefs = await SharedPreferences.getInstance();
    final backupService = LocalBackupService(prefs);
    await backupService.exportBackup();

    // Simulate a device wipe plus a profile created after the backup.
    await prefs.remove('app_settings_v1_p1');
    await prefs.remove('favorite_pictograms_v1_p1');
    await prefs.setString('app_settings_v1_p2', '{"localeCode":"de"}');

    expect(await backupService.restoreBackup(), isTrue);
    expect(
      prefs.getString('app_settings_v1_p1'),
      contains('"localeCode":"it"'),
    );
    expect(prefs.getStringList('favorite_pictograms_v1_p1'), isNotEmpty);
    expect(prefs.getString('active_profile_v1'), 'p1');
    expect(prefs.getStringList('profiles_v1'), hasLength(2));
    // The profile absent from the backup does not survive the restore.
    expect(prefs.getString('app_settings_v1_p2'), isNull);
  });

  test('returns false when no backup file exists', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final backupService = LocalBackupService(prefs);

    final restored = await backupService.restoreBackup();
    expect(restored, isFalse);
  });
}
