import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalBackupService {
  LocalBackupService(this._preferences);

  final SharedPreferences _preferences;

  static const String _fileName = 'mot-zaique-backup.json';

  // Base keys, without the per-profile suffix (A-11). A key is managed when it
  // equals a base key (historical profile) or starts with `<base>_` (any other
  // profile), so a backup covers every profile, not just the active one.
  static const List<String> _stringListBaseKeys = [
    'favorite_pictograms_v1',
    'current_phrase_v1',
    'saved_phrases_v1',
    'profiles_v1',
  ];

  static const List<String> _stringBaseKeys = [
    'app_settings_v1',
    'active_profile_v1',
    'favorites_pin_hash_v3',
    'favorites_pin_salt_v3',
    'favorites_recovery_hash_v3',
    'favorites_recovery_salt_v3',
    'favorites_pin_hash_v2',
    'favorites_recovery_hash_v1',
    'search_cache_v2',
    'search_cache_v1',
  ];

  static const List<String> _intBaseKeys = [
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

  bool _matches(String key, String baseKey) =>
      key == baseKey || key.startsWith('${baseKey}_');

  bool _matchesAny(String key, List<String> baseKeys) =>
      baseKeys.any((baseKey) => _matches(key, baseKey));

  /// Every stored key derived from one of [baseKeys], across all profiles.
  Iterable<String> _storedKeysFor(List<String> baseKeys) =>
      _preferences.getKeys().where((key) => _matchesAny(key, baseKeys));

  Map<String, dynamic> _collectData() {
    final data = <String, dynamic>{};

    for (final key in _storedKeysFor(_stringListBaseKeys)) {
      data[key] = _preferences.getStringList(key);
    }
    for (final key in _storedKeysFor(_stringBaseKeys)) {
      data[key] = _preferences.getString(key);
    }
    for (final key in _storedKeysFor(_intBaseKeys)) {
      data[key] = _preferences.getInt(key);
    }

    return data;
  }

  Future<void> _applyData(Map<String, dynamic> data) async {
    // A restore replaces the managed state: drop every managed key first, so a
    // profile created after the backup does not survive it.
    final managed = _storedKeysFor([
      ..._stringListBaseKeys,
      ..._stringBaseKeys,
      ..._intBaseKeys,
    ]).toList();
    for (final key in managed) {
      await _preferences.remove(key);
    }

    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value is List && _matchesAny(key, _stringListBaseKeys)) {
        await _preferences.setStringList(
          key,
          value.map((e) => e.toString()).toList(),
        );
      } else if (value is String && _matchesAny(key, _stringBaseKeys)) {
        await _preferences.setString(key, value);
      } else if (value is num && _matchesAny(key, _intBaseKeys)) {
        await _preferences.setInt(key, value.toInt());
      }
      // Anything else (null placeholders from older backups, unknown keys) is
      // ignored: the key stays removed.
    }
  }

  Future<File> _backupFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
}
