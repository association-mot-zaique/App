import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.dart';

/// Stores the profile list and which one is active (A-11).
class ProfileRepository {
  ProfileRepository(this._preferences);

  static const String _profilesKey = 'profiles_v1';
  static const String _activeKey = 'active_profile_v1';

  final SharedPreferences _preferences;

  /// Always returns at least the default profile, so the app is never without
  /// one.
  List<Profile> readProfiles({required String defaultName}) {
    final raw = _preferences.getStringList(_profilesKey) ?? const [];
    final profiles = <Profile>[];
    for (final entry in raw) {
      try {
        final decoded = jsonDecode(entry);
        if (decoded is Map) {
          profiles.add(Profile.fromJson(Map<String, dynamic>.from(decoded)));
        }
      } catch (_) {
        // Skip a corrupted entry rather than losing every profile.
      }
    }
    if (profiles.isEmpty) {
      return [Profile(id: Profile.defaultId, name: defaultName)];
    }
    return profiles;
  }

  Future<void> saveProfiles(List<Profile> profiles) {
    return _preferences.setStringList(
      _profilesKey,
      profiles.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }

  String readActiveId() =>
      _preferences.getString(_activeKey) ?? Profile.defaultId;

  Future<void> saveActiveId(String id) =>
      _preferences.setString(_activeKey, id);
}
