import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pictogram.dart';
import '../models/saved_phrase.dart';

class PhraseBookRepository {
  PhraseBookRepository(this._preferences);

  static const String _currentPhraseBaseKey = 'current_phrase_v1';
  static const String _savedPhrasesBaseKey = 'saved_phrases_v1';
  static const int _maxSavedPhrases = 80;

  final SharedPreferences _preferences;

  /// Suffix identifying the active profile (A-11). Empty for the historical
  /// profile, so its existing phrases are kept untouched.
  String profileSuffix = '';

  String get _currentPhraseKey => '$_currentPhraseBaseKey$profileSuffix';
  String get _savedPhrasesKey => '$_savedPhrasesBaseKey$profileSuffix';

  /// Drops the phrases of a deleted profile.
  Future<void> deleteFor(String suffix) async {
    await _preferences.remove('$_currentPhraseBaseKey$suffix');
    await _preferences.remove('$_savedPhrasesBaseKey$suffix');
  }

  List<Pictogram> readCurrentPhrase() {
    final raw = _preferences.getStringList(_currentPhraseKey) ?? const [];
    final result = <Pictogram>[];

    for (final encoded in raw) {
      try {
        final decoded = jsonDecode(encoded);
        if (decoded is Map<String, dynamic>) {
          result.add(Pictogram.fromJson(decoded));
        } else if (decoded is Map) {
          result.add(Pictogram.fromJson(Map<String, dynamic>.from(decoded)));
        }
      } catch (_) {
        // Ignore invalid entries.
      }
    }

    return result;
  }

  Future<void> saveCurrentPhrase(List<Pictogram> currentPhrase) {
    final encoded = currentPhrase
        .map((item) => jsonEncode(item.toJson()))
        .toList();
    return _preferences.setStringList(_currentPhraseKey, encoded);
  }

  List<SavedPhrase> readSavedPhrases() {
    final raw = _preferences.getStringList(_savedPhrasesKey) ?? const [];
    final phrases = <SavedPhrase>[];

    for (final encoded in raw) {
      try {
        final decoded = jsonDecode(encoded);
        if (decoded is Map<String, dynamic>) {
          phrases.add(SavedPhrase.fromJson(decoded));
        } else if (decoded is Map) {
          phrases.add(SavedPhrase.fromJson(Map<String, dynamic>.from(decoded)));
        }
      } catch (_) {
        // Ignore invalid phrase.
      }
    }

    phrases.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return phrases;
  }

  Future<void> saveSavedPhrases(List<SavedPhrase> phrases) {
    final trimmed = phrases.take(_maxSavedPhrases).toList();
    final encoded = trimmed.map((item) => jsonEncode(item.toJson())).toList();
    return _preferences.setStringList(_savedPhrasesKey, encoded);
  }
}
