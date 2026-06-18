import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalBackupService {
  LocalBackupService(this._preferences);

  final SharedPreferences _preferences;

  static const String _fileName = 'mot-zaique-backup.json';

  static const List<String> _stringListKeys = [
    'favorite_pictograms_v1',
    'current_phrase_v1',
    'saved_phrases_v1',
  ];

  static const List<String> _stringKeys = [
    'app_settings_v1',
    'favorites_pin_hash_v3',
    'favorites_pin_salt_v3',
    'favorites_recovery_hash_v3',
    'favorites_recovery_salt_v3',
    'favorites_pin_hash_v2',
    'favorites_recovery_hash_v1',
    'search_cache_v2',
    'search_cache_v1',
  ];

  static const List<String> _intKeys = [
    'favorites_pin_failed_attempts_v1',
    'favorites_pin_blocked_until_v1',
  ];

  Future<String> backupPath() async {
    final file = await _backupFile();
    return file.path;
  }

  Future<String> exportBackup() async {
    final file = await _backupFile();

    final payload = <String, dynamic>{
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'data': _collectData(),
    };

    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(payload));
    return file.path;
  }

  Future<bool> restoreBackup() async {
    final file = await _backupFile();
    if (!await file.exists()) {
      return false;
    }

    final content = await file.readAsString();
    final decoded = jsonDecode(content);
    if (decoded is! Map) {
      return false;
    }

    final data = decoded['data'];
    if (data is! Map) {
      return false;
    }

    await _applyData(Map<String, dynamic>.from(data));
    return true;
  }

  Map<String, dynamic> _collectData() {
    final data = <String, dynamic>{};

    for (final key in _stringListKeys) {
      data[key] = _preferences.getStringList(key);
    }
    for (final key in _stringKeys) {
      data[key] = _preferences.getString(key);
    }
    for (final key in _intKeys) {
      data[key] = _preferences.getInt(key);
    }

    return data;
  }

  Future<void> _applyData(Map<String, dynamic> data) async {
    for (final key in _stringListKeys) {
      final value = data[key];
      if (value is List) {
        await _preferences.setStringList(
          key,
          value.map((e) => e.toString()).toList(),
        );
      } else {
        await _preferences.remove(key);
      }
    }

    for (final key in _stringKeys) {
      final value = data[key];
      if (value is String) {
        await _preferences.setString(key, value);
      } else {
        await _preferences.remove(key);
      }
    }

    for (final key in _intKeys) {
      final value = data[key];
      if (value is int) {
        await _preferences.setInt(key, value);
      } else if (value is num) {
        await _preferences.setInt(key, value.toInt());
      } else {
        await _preferences.remove(key);
      }
    }
  }

  Future<File> _backupFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
}
