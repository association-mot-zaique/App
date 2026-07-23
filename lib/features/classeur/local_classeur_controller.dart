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

  Future<void> _persist() async {
    await _repository.save(_classeur);
    notifyListeners();
  }
}
