import 'package:flutter/foundation.dart';

import '../../data/models/local_classeur.dart';
import '../../data/services/local_classeur_repository.dart';

/// Owns the in-memory [LocalClasseur] and persists every mutation through the
/// [LocalClasseurRepository]. This is the bridge between the classeur data
/// layer (US-1.01) and the aidant UI (US-1.05 / US-1.06).
class LocalClasseurController extends ChangeNotifier {
  LocalClasseurController(this._repository);

  final LocalClasseurRepository _repository;
  LocalClasseur _classeur = LocalClasseur.empty();

  LocalClasseur get classeur => _classeur;

  Future<void> load() async {
    _classeur = await _repository.load();
    notifyListeners();
  }

  /// Absolute path of a stored image, for display with `Image.file`.
  String absoluteImagePath(String relativePath) =>
      _repository.absoluteImagePath(relativePath);

  // ── Categories (US-1.05) ────────────────────────────────────────────

  bool _categoryNameExists(String name, {int? exceptId}) {
    final normalized = name.trim().toLowerCase();
    return _classeur.categories.any(
      (c) => c.id != exceptId && c.name.trim().toLowerCase() == normalized,
    );
  }

  /// Adds a category. Returns false (and does nothing) when the name is empty
  /// or already used by another category — no duplicates.
  Future<bool> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _categoryNameExists(trimmed)) {
      return false;
    }
    _classeur = _classeur.addCategory(trimmed).classeur;
    await _persist();
    return true;
  }

  /// Renames a category. Returns false when the name is empty or already used
  /// by another category.
  Future<bool> renameCategory(int id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || _categoryNameExists(trimmed, exceptId: id)) {
      return false;
    }
    _classeur = _classeur.copyWith(
      categories: _classeur.categories
          .map((c) => c.id == id ? c.copyWith(name: trimmed) : c)
          .toList(),
    );
    await _persist();
    return true;
  }

  /// Deletes the category, its pictograms and their image files.
  Future<void> deleteCategory(int id) async {
    final orphanedImages = _classeur.pictograms
        .where((picto) => picto.categoryId == id)
        .map((picto) => picto.imagePath)
        .toList();

    _classeur = _classeur.copyWith(
      categories: _classeur.categories.where((c) => c.id != id).toList(),
      pictograms:
          _classeur.pictograms.where((p) => p.categoryId != id).toList(),
    );
    await _persist();

    for (final imagePath in orphanedImages) {
      await _repository.deleteImage(imagePath);
    }
  }

  // ── Pictograms (US-1.06) ────────────────────────────────────────────

  /// Stores [imageBytes] on disk and creates a pictogram in [categoryId].
  /// The image file is named after the new pictogram id, so it stays unique.
  Future<void> addPictogram({
    required String label,
    required int categoryId,
    required List<int> imageBytes,
    required String extension,
  }) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final id = _classeur.nextPictogramId;
    final imagePath = await _repository.storeImageBytes(
      imageBytes,
      pictogramId: id,
      extension: extension,
    );
    _classeur = _classeur
        .addPictogram(label: trimmed, imagePath: imagePath, categoryId: categoryId)
        .classeur;
    await _persist();
  }

  Future<void> renamePictogram(int id, String label) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _classeur = _classeur.copyWith(
      pictograms: _classeur.pictograms
          .map((p) => p.id == id ? p.copyWith(label: trimmed) : p)
          .toList(),
    );
    await _persist();
  }

  /// Deletes the pictogram and its image file.
  Future<void> deletePictogram(int id) async {
    final imagePaths = _classeur.pictograms
        .where((picto) => picto.id == id)
        .map((picto) => picto.imagePath)
        .toList();

    _classeur = _classeur.copyWith(
      pictograms: _classeur.pictograms.where((p) => p.id != id).toList(),
    );
    await _persist();

    for (final imagePath in imagePaths) {
      await _repository.deleteImage(imagePath);
    }
  }

  // ── Organisation (US-3.04 / US-3.05) ────────────────────────────────

  /// Moves a pictogram to another category, placing it at the end (A-07).
  Future<void> movePictogramToCategory(int id, int categoryId) async {
    final matches = _classeur.pictograms.where((p) => p.id == id).toList();
    if (matches.isEmpty || matches.first.categoryId == categoryId) {
      return;
    }
    final target = _classeur.pictogramsIn(categoryId);
    final nextOrder = target.isEmpty ? 0 : target.last.sortOrder + 1;
    _classeur = _classeur.copyWith(
      pictograms: _classeur.pictograms
          .map(
            (p) => p.id == id
                ? p.copyWith(categoryId: categoryId, sortOrder: nextOrder)
                : p,
          )
          .toList(),
    );
    await _persist();
  }

  /// Moves a pictogram one slot up (-1) or down (+1) inside its category
  /// (A-08). Positions stay stable for the end user: only the aidant reorders.
  Future<void> movePictogramBy(int id, int delta) async {
    final matches = _classeur.pictograms.where((p) => p.id == id).toList();
    if (matches.isEmpty) {
      return;
    }
    final siblings = _classeur.pictogramsIn(matches.first.categoryId);
    final index = siblings.indexWhere((p) => p.id == id);
    final target = index + delta;
    if (index < 0 || target < 0 || target >= siblings.length) {
      return;
    }
    final reordered = [...siblings];
    reordered.insert(target, reordered.removeAt(index));

    final orderById = <int, int>{
      for (var i = 0; i < reordered.length; i++) reordered[i].id: i,
    };
    _classeur = _classeur.copyWith(
      pictograms: _classeur.pictograms
          .map(
            (p) => orderById.containsKey(p.id)
                ? p.copyWith(sortOrder: orderById[p.id])
                : p,
          )
          .toList(),
    );
    await _persist();
  }

  /// Reorders categories (A-08), renumbering their display order.
  /// [newIndex] is the destination index **after** the item was removed
  /// (the `onReorderItem` convention).
  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    final sorted = [..._classeur.categoriesSorted];
    if (oldIndex < 0 || oldIndex >= sorted.length) {
      return;
    }
    if (newIndex < 0 || newIndex >= sorted.length || newIndex == oldIndex) {
      return;
    }
    sorted.insert(newIndex, sorted.removeAt(oldIndex));
    _classeur = _classeur.copyWith(
      categories: [
        for (var i = 0; i < sorted.length; i++)
          sorted[i].copyWith(sortOrder: i),
      ],
    );
    await _persist();
  }

  // ── Transfert du classeur (US-3.01 / US-3.02) ───────────────────────

  /// Zip autonome du classeur (manifeste + images), a enregistrer hors de
  /// l'app pour changer d'appareil (A-09).
  Future<List<int>> exportArchive() => _repository.exportToZipBytes();

  /// Remplace le classeur courant par celui de l'archive (A-10).
  /// Retourne false si le fichier n'est pas un classeur valide.
  Future<bool> importArchive(List<int> bytes) async {
    final imported = await _repository.importFromZipBytes(bytes);
    if (imported) {
      await load();
    }
    return imported;
  }

  Future<void> _persist() async {
    await _repository.save(_classeur);
    notifyListeners();
  }
}
