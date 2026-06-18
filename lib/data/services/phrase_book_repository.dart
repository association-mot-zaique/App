import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pictogram.dart';
import '../models/saved_phrase.dart';

class PhraseBookRepository {
  PhraseBookRepository(this._preferences);

  static const String _currentPhraseKey = 'current_phrase_v1';
  static const String _savedPhrasesKey = 'saved_phrases_v1';
  static const int _maxSavedPhrases = 80;

  final SharedPreferences _preferences;

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
