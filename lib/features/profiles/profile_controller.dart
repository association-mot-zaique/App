import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../data/models/profile.dart';
import '../../data/services/app_settings_repository.dart';
import '../../data/services/local_classeur_repository.dart';
import '../../data/services/profile_repository.dart';
import '../classeur/local_classeur_controller.dart';
import '../settings/settings_controller.dart';

/// Owns the profile list and the active profile (A-11 / US-3.03).
///
/// Switching profile re-points the classeur and settings repositories, then
/// reloads their controllers — so each profile really has **its own** classeur
/// and settings.
///
/// The historical profile ([Profile.defaultId]) keeps the legacy storage
/// locations, so an existing installation is preserved without any migration.
class ProfileController extends ChangeNotifier {
  ProfileController({
    required ProfileRepository repository,
    required LocalClasseurRepository classeurRepository,
    required AppSettingsRepository settingsRepository,
    required LocalClasseurController classeurController,
    required SettingsController settingsController,
    required Directory documentsDir,
    required String defaultProfileName,
  }) : _repository = repository,
       _classeurRepository = classeurRepository,
       _settingsRepository = settingsRepository,
       _classeurController = classeurController,
       _settingsController = settingsController,
       _documentsDir = documentsDir,
       _defaultProfileName = defaultProfileName;

  final ProfileRepository _repository;
  final LocalClasseurRepository _classeurRepository;
  final AppSettingsRepository _settingsRepository;
  final LocalClasseurController _classeurController;
  final SettingsController _settingsController;
  final Directory _documentsDir;
  final String _defaultProfileName;

  List<Profile> _profiles = const [];
  String _activeId = Profile.defaultId;

  List<Profile> get profiles => List.unmodifiable(_profiles);
  String get activeId => _activeId;

  Profile get active => _profiles.firstWhere(
    (p) => p.id == _activeId,
    orElse: () => Profile(id: Profile.defaultId, name: _defaultProfileName),
  );

  /// Reads the profiles, then points the repositories at the active one and
  /// loads its data. Call once at startup, before the controllers' own load.
  Future<void> load() async {
    _profiles = _repository.readProfiles(defaultName: _defaultProfileName);
    final storedActive = _repository.readActiveId();
    _activeId = _profiles.any((p) => p.id == storedActive)
        ? storedActive
        : _profiles.first.id;
    await _applyActive();
  }

  Directory _classeurRootFor(String profileId) {
    if (profileId == Profile.defaultId) {
      // Legacy location: keeps existing classeurs working untouched.
      return Directory('${_documentsDir.path}/classeur');
    }
    return Directory('${_documentsDir.path}/profiles/$profileId/classeur');
  }

  String _settingsSuffixFor(String profileId) =>
      profileId == Profile.defaultId ? '' : '_$profileId';

  Future<void> _applyActive() async {
    _classeurRepository.rootDir = _classeurRootFor(_activeId);
    _settingsRepository.profileSuffix = _settingsSuffixFor(_activeId);
    await _settingsController.load();
    await _classeurController.load();
    notifyListeners();
  }

  Future<void> switchTo(String profileId) async {
    if (profileId == _activeId || !_profiles.any((p) => p.id == profileId)) {
      return;
    }
    _activeId = profileId;
    await _repository.saveActiveId(_activeId);
    await _applyActive();
  }

  /// Adds a profile and switches to it. Returns false when the name is empty
  /// or already used.
  Future<bool> addProfile(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _nameExists(trimmed)) {
      return false;
    }
    final profile = Profile(id: _newId(), name: trimmed);
    _profiles = [..._profiles, profile];
    await _repository.saveProfiles(_profiles);
    await switchTo(profile.id);
    notifyListeners();
    return true;
  }

  Future<bool> renameProfile(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _nameExists(trimmed, exceptId: id)) {
      return false;
    }
    _profiles = _profiles
        .map((p) => p.id == id ? p.copyWith(name: trimmed) : p)
        .toList();
    await _repository.saveProfiles(_profiles);
    notifyListeners();
    return true;
  }

  /// Deletes a profile and its classeur. The last profile cannot be removed.
  Future<bool> deleteProfile(String id) async {
    if (_profiles.length <= 1 || !_profiles.any((p) => p.id == id)) {
      return false;
    }
    _profiles = _profiles.where((p) => p.id != id).toList();
    await _repository.saveProfiles(_profiles);

    // Drop that profile's data (non-default profiles own their directory).
    if (id != Profile.defaultId) {
      final dir = Directory('${_documentsDir.path}/profiles/$id');
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }

    if (_activeId == id) {
      _activeId = _profiles.first.id;
      await _repository.saveActiveId(_activeId);
      await _applyActive();
    } else {
      notifyListeners();
    }
    return true;
  }

  bool _nameExists(String name, {String? exceptId}) {
    final normalized = name.trim().toLowerCase();
    return _profiles.any(
      (p) => p.id != exceptId && p.name.trim().toLowerCase() == normalized,
    );
  }

  String _newId() {
    final used = _profiles.map((p) => p.id).toSet();
    var index = 1;
    while (used.contains('p$index')) {
      index++;
    }
    return 'p$index';
  }
}
