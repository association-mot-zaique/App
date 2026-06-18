import 'package:flutter/foundation.dart';

import '../../data/models/app_settings.dart';
import '../../data/services/app_settings_repository.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._repository);

  final AppSettingsRepository _repository;
  AppSettings _settings = AppSettings.defaults;

  AppSettings get settings => _settings;

  Future<void> load() async {
    _settings = _repository.read();
    notifyListeners();
  }

  Future<void> updateScale(double value) {
    return _update(_settings.copyWith(pictogramScale: value));
  }

  Future<void> updateHighContrast(bool value) {
    return _update(_settings.copyWith(highContrast: value));
  }

  Future<void> updateReducedMotion(bool value) {
    return _update(_settings.copyWith(reducedMotion: value));
  }

  Future<void> updateOfflineOnly(bool value) {
    return _update(_settings.copyWith(offlineOnly: value));
  }

  Future<void> updateOnlyAacPictograms(bool value) {
    return _update(_settings.copyWith(onlyAacPictograms: value));
  }

  Future<void> updateOnlySchematicPictograms(bool value) {
    return _update(_settings.copyWith(onlySchematicPictograms: value));
  }

  Future<void> updateMinDownloads(int value) {
    return _update(_settings.copyWith(minDownloads: value));
  }

  Future<void> updateLocaleCode(String localeCode) {
    return _update(_settings.copyWith(localeCode: localeCode));
  }

  Future<void> _update(AppSettings newSettings) async {
    _settings = newSettings;
    await _repository.save(newSettings);
    notifyListeners();
  }
}
