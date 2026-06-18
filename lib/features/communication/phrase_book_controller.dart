import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../data/models/pictogram.dart';
import '../../data/models/saved_phrase.dart';
import '../../data/services/phrase_book_repository.dart';

class PhraseBookController extends ChangeNotifier {
  PhraseBookController(this._repository, {Random? random})
    : _random = random ?? Random();

  final PhraseBookRepository _repository;
  final Random _random;

  final List<Pictogram> _currentPhrase = <Pictogram>[];
  final List<SavedPhrase> _savedPhrases = <SavedPhrase>[];

  List<Pictogram> get currentPhrase => List.unmodifiable(_currentPhrase);
  List<SavedPhrase> get savedPhrases => List.unmodifiable(_savedPhrases);

  String get currentText =>
      _currentPhrase.map((item) => item.label).join(' ').trim();

  Future<void> load() async {
    _currentPhrase
      ..clear()
      ..addAll(_repository.readCurrentPhrase());

    _savedPhrases
      ..clear()
      ..addAll(_repository.readSavedPhrases());

    notifyListeners();
  }

  Future<void> addToCurrent(Pictogram pictogram) async {
    _currentPhrase.add(pictogram);
    await _repository.saveCurrentPhrase(_currentPhrase);
    notifyListeners();
  }

  Future<void> removeLastFromCurrent() async {
    if (_currentPhrase.isEmpty) {
      return;
    }
    _currentPhrase.removeLast();
    await _repository.saveCurrentPhrase(_currentPhrase);
    notifyListeners();
  }

  Future<void> clearCurrent() async {
    if (_currentPhrase.isEmpty) {
      return;
    }
    _currentPhrase.clear();
    await _repository.saveCurrentPhrase(_currentPhrase);
    notifyListeners();
  }

  Future<void> loadSavedPhrase(SavedPhrase phrase) async {
    _currentPhrase
      ..clear()
      ..addAll(phrase.pictograms);
    await _repository.saveCurrentPhrase(_currentPhrase);
    notifyListeners();
  }

  Future<void> saveCurrentAsPhrase({String? customName}) async {
    if (_currentPhrase.isEmpty) {
      return;
    }

    final fallbackName = currentText;
    final cleanName = customName?.trim();

    final phrase = SavedPhrase(
      id: _generateId(),
      name: (cleanName == null || cleanName.isEmpty) ? fallbackName : cleanName,
      pictograms: List<Pictogram>.from(_currentPhrase),
      createdAt: DateTime.now(),
    );

    _savedPhrases.insert(0, phrase);
    await _repository.saveSavedPhrases(_savedPhrases);
    notifyListeners();
  }

  Future<void> deleteSavedPhrase(String phraseId) async {
    _savedPhrases.removeWhere((item) => item.id == phraseId);
    await _repository.saveSavedPhrases(_savedPhrases);
    notifyListeners();
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = _random.nextInt(1 << 32);
    return '$timestamp-$randomPart';
  }
}
