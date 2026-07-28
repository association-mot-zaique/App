import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../data/models/pictogram.dart';
import '../../data/models/saved_phrase.dart';
import '../../data/services/phrase_book_repository.dart';

class PhraseBookController extends ChangeNotifier {
  PhraseBookController(
    this._repository, {
    Random? random,
    String Function(String absolutePath)? reanchorLocalImagePath,
  }) : _random = random ?? Random(),
       _reanchorLocalImagePath = reanchorLocalImagePath;

  final PhraseBookRepository _repository;
  final Random _random;

  /// Repairs the absolute path of an owned image at load time: the stored
  /// prefix goes stale across reinstalls and profile switches, which left
  /// broken thumbnails in the bande-phrase.
  final String Function(String absolutePath)? _reanchorLocalImagePath;

  final List<Pictogram> _currentPhrase = <Pictogram>[];
  final List<SavedPhrase> _savedPhrases = <SavedPhrase>[];

  List<Pictogram> get currentPhrase => List.unmodifiable(_currentPhrase);
  List<SavedPhrase> get savedPhrases => List.unmodifiable(_savedPhrases);

  String get currentText =>
      _currentPhrase.map((item) => item.label).join(' ').trim();

  Future<void> load() async {
    _currentPhrase
      ..clear()
      ..addAll(_repository.readCurrentPhrase().map(_reanchored));

    _savedPhrases
      ..clear()
      ..addAll(
        _repository.readSavedPhrases().map(
          (phrase) => SavedPhrase(
            id: phrase.id,
            name: phrase.name,
            pictograms: phrase.pictograms.map(_reanchored).toList(),
            createdAt: phrase.createdAt,
          ),
        ),
      );

    notifyListeners();
  }

  Pictogram _reanchored(Pictogram pictogram) {
    final reanchor = _reanchorLocalImagePath;
    if (reanchor == null || !pictogram.isLocal) {
      return pictogram;
    }
    return pictogram.withLocalImagePath(reanchor(pictogram.localImagePath!));
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
