import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

class AppSettingsRepository {
  AppSettingsRepository(this._preferences);

  static const String _baseKey = 'app_settings_v1';
  final SharedPreferences _preferences;

  /// Suffix identifying the active profile (A-11). Empty for the historical
  /// profile, so its existing settings are kept untouched.
  String profileSuffix = '';

  String get _settingsKey => '$_baseKey$profileSuffix';

  /// Drops the settings of a deleted profile.
  Future<void> deleteFor(String suffix) =>
      _preferences.remove('$_baseKey$suffix');

  AppSettings read() {
    final rawJson = _preferences.getString(_settingsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return AppSettings.defaults;
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is Map<String, dynamic>) {
        return AppSettings.fromJson(decoded);
      }
      if (decoded is Map) {
        return AppSettings.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      // Use defaults if data is corrupted.
    }

    return AppSettings.defaults;
  }

  Future<void> save(AppSettings settings) {
    return _preferences.setString(_settingsKey, jsonEncode(settings.toJson()));
  }
}
