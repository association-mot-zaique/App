import 'package:flutter/foundation.dart';

import '../../data/models/pictogram.dart';
import '../../data/services/favorites_repository.dart';

class FavoritesController extends ChangeNotifier {
  FavoritesController(this._repository);

  final FavoritesRepository _repository;
  final List<Pictogram> _favorites = <Pictogram>[];

  List<Pictogram> get favorites => List.unmodifiable(_favorites);

  Future<void> load() async {
    _favorites
      ..clear()
      ..addAll(_repository.readFavorites());
    notifyListeners();
  }

  bool isFavorite(int pictogramId) {
    return _favorites.any((picto) => picto.id == pictogramId);
  }

  Future<void> toggleFavorite(Pictogram pictogram) async {
    final index = _favorites.indexWhere((item) => item.id == pictogram.id);
    if (index == -1) {
      _favorites.add(pictogram);
    } else {
      _favorites.removeAt(index);
    }

    await _repository.saveFavorites(_favorites);
    notifyListeners();
  }

  Future<void> removeById(int pictogramId) async {
    _favorites.removeWhere((picto) => picto.id == pictogramId);
    await _repository.saveFavorites(_favorites);
    notifyListeners();
  }
}
