import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../data/models/profile.dart';
import '../../data/services/app_settings_repository.dart';
import '../../data/services/favorites_repository.dart';
import '../../data/services/local_classeur_repository.dart';
import '../../data/services/phrase_book_repository.dart';
import '../../data/services/profile_repository.dart';
import '../classeur/local_classeur_controller.dart';
import '../communication/phrase_book_controller.dart';
import '../favorites/favorites_controller.dart';
import '../settings/settings_controller.dart';

/// Owns the profile list and the active profile (A-11 / US-3.03).
///
/// Switching profile re-points every per-user repository — classeur, settings,
/// favoris and bande-phrase — then reloads their controllers, so a shared
/// tablet never shows one user's content to another.
///
/// The historical profile ([Profile.defaultId]) keeps the legacy storage
/// locations, so an existing installation is preserved without any migration.
class ProfileController extends ChangeNotifier {
  ProfileController({
    required ProfileRepository repository,
    required LocalClasseurRepository classeurRepository,
    required AppSettingsRepository settingsRepository,
    required FavoritesRepository favoritesRepository,
    required PhraseBookRepository phraseBookRepository,
    required LocalClasseurController classeurController,
    required SettingsController settingsController,
    required FavoritesController favoritesController,
    required PhraseBookController phraseBookController,
    required Directory documentsDir,
    required String defaultProfileName,
  }) : _repository = repository,
       _classeurRepository = classeurRepository,
       _settingsRepository = settingsRepository,
       _favoritesRepository = favoritesRepository,
       _phraseBookRepository = phraseBookRepository,
       _classeurController = classeurController,
       _settingsController = settingsController,
       _favoritesController = favoritesController,
       _phraseBookController = phraseBookController,
       _documentsDir = documentsDir,
       _defaultProfileName = defaultProfileName;

  final ProfileRepository _repository;
  final LocalClasseurRepository _classeurRepository;
  final AppSettingsRepository _settingsRepository;
  final FavoritesRepository _favoritesRepository;
  final PhraseBookRepository _phraseBookRepository;
  final LocalClasseurController _classeurController;
  final SettingsController _settingsController;
  final FavoritesController _favoritesController;
  final PhraseBookController _phraseBookController;
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
  /// loads its data — including favoris and bande-phrase, so those controllers
  /// must not be loaded separately at startup. Call once, at startup.
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

  /// Suffix appended to every per-profile preferences key. Empty for the
  /// historical profile so its existing keys stay valid (no migration).
  String _storageSuffixFor(String profileId) =>
      profileId == Profile.defaultId ? '' : '_$profileId';

  Future<void> _applyActive() async {
    final suffix = _storageSuffixFor(_activeId);
    _classeurRepository.rootDir = _classeurRootFor(_activeId);
    _settingsRepository.profileSuffix = suffix;
    _favoritesRepository.profileSuffix = suffix;
    _phraseBookRepository.profileSuffix = suffix;

    await _settingsController.load();
    await _classeurController.load();
    await _favoritesController.load();
    await _phraseBookController.load();
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

  /// Deletes a profile and all of its data — classeur, réglages, favoris et
  /// phrases. The last profile cannot be removed.
  Future<bool> deleteProfile(String id) async {
    if (_profiles.length <= 1 || !_profiles.any((p) => p.id == id)) {
      return false;
    }
    _profiles = _profiles.where((p) => p.id != id).toList();
    await _repository.saveProfiles(_profiles);

    // Drop that profile's data. The historical profile is never deleted from
    // its legacy locations, so only non-default profiles are cleaned up.
    if (id != Profile.defaultId) {
      final suffix = _storageSuffixFor(id);
      await _settingsRepository.deleteFor(suffix);
      await _favoritesRepository.deleteFor(suffix);
      await _phraseBookRepository.deleteFor(suffix);

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
