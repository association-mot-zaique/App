import 'local_category.dart';
import 'local_pictogram.dart';

/// The whole user-owned classeur: categories and pictograms held on the
/// device. This is the aggregate serialized to `manifest.json`.
///
/// Ids are handed out from monotonic counters ([nextCategoryId] /
/// [nextPictogramId]) so a deleted id is never reused — this keeps image file
/// names and references stable.
class LocalClasseur {
  const LocalClasseur({
    required this.schemaVersion,
    required this.nextCategoryId,
    required this.nextPictogramId,
    required this.categories,
    required this.pictograms,
  });

  static const int currentSchemaVersion = 1;

  factory LocalClasseur.empty() {
    return const LocalClasseur(
      schemaVersion: currentSchemaVersion,
      nextCategoryId: 1,
      nextPictogramId: 1,
      categories: [],
      pictograms: [],
    );
  }

  final int schemaVersion;
  final int nextCategoryId;
  final int nextPictogramId;
  final List<LocalCategory> categories;
  final List<LocalPictogram> pictograms;

  bool get isEmpty => categories.isEmpty && pictograms.isEmpty;

  /// Categories in display order.
  List<LocalCategory> get categoriesSorted {
    final sorted = [...categories];
    sorted.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted;
  }

  /// Pictograms of [categoryId] in display order.
  List<LocalPictogram> pictogramsIn(int categoryId) {
    final items = pictograms
        .where((picto) => picto.categoryId == categoryId)
        .toList();
    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return items;
  }

  /// Cross-cutting favorites view (CDC 4.1 / US-R.02, US-R.03).
  ///
  /// Ordered by category, then by position inside the category, so a favorite
  /// keeps the same slot from one session to the next (CDC 3.1).
  List<LocalPictogram> get favorites {
    final categoryOrder = {
      for (final category in categories) category.id: category.sortOrder,
    };
    final items = pictograms.where((picto) => picto.isFavorite).toList();
    items.sort((a, b) {
      final byCategory = (categoryOrder[a.categoryId] ?? 0).compareTo(
        categoryOrder[b.categoryId] ?? 0,
      );
      return byCategory != 0 ? byCategory : a.sortOrder.compareTo(b.sortOrder);
    });
    return items;
  }

  int _nextSortOrder(Iterable<int> orders) {
    var max = -1;
    for (final order in orders) {
      if (order > max) {
        max = order;
      }
    }
    return max + 1;
  }

  /// Adds a category and returns the updated classeur together with the
  /// created category (whose id is the previous [nextCategoryId]).
  ({LocalClasseur classeur, LocalCategory category}) addCategory(String name) {
    final category = LocalCategory(
      id: nextCategoryId,
      name: name,
      sortOrder: _nextSortOrder(categories.map((c) => c.sortOrder)),
    );
    return (
      classeur: copyWith(
        nextCategoryId: nextCategoryId + 1,
        categories: [...categories, category],
      ),
      category: category,
    );
  }

  /// Adds a pictogram to [categoryId] and returns the updated classeur with
  /// the created pictogram (whose id is the previous [nextPictogramId]).
  ({LocalClasseur classeur, LocalPictogram pictogram}) addPictogram({
    required String label,
    required String imagePath,
    required int categoryId,
    bool isFavorite = false,
  }) {
    final pictogram = LocalPictogram(
      id: nextPictogramId,
      label: label,
      imagePath: imagePath,
      categoryId: categoryId,
      sortOrder: _nextSortOrder(
        pictogramsIn(categoryId).map((p) => p.sortOrder),
      ),
      isFavorite: isFavorite,
    );
    return (
      classeur: copyWith(
        nextPictogramId: nextPictogramId + 1,
        pictograms: [...pictograms, pictogram],
      ),
      pictogram: pictogram,
    );
  }

  LocalClasseur copyWith({
    int? nextCategoryId,
    int? nextPictogramId,
    List<LocalCategory>? categories,
    List<LocalPictogram>? pictograms,
  }) {
    return LocalClasseur(
      schemaVersion: schemaVersion,
      nextCategoryId: nextCategoryId ?? this.nextCategoryId,
      nextPictogramId: nextPictogramId ?? this.nextPictogramId,
      categories: categories ?? this.categories,
      pictograms: pictograms ?? this.pictograms,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'nextCategoryId': nextCategoryId,
      'nextPictogramId': nextPictogramId,
      'categories': categories.map((c) => c.toJson()).toList(),
      'pictograms': pictograms.map((p) => p.toJson()).toList(),
    };
  }

  factory LocalClasseur.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['categories'];
    final rawPictograms = json['pictograms'];

    final categories = <LocalCategory>[];
    if (rawCategories is List) {
      for (final item in rawCategories) {
        if (item is Map<String, dynamic>) {
          categories.add(LocalCategory.fromJson(item));
        } else if (item is Map) {
          categories.add(
            LocalCategory.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final pictograms = <LocalPictogram>[];
    if (rawPictograms is List) {
      for (final item in rawPictograms) {
        if (item is Map<String, dynamic>) {
          pictograms.add(LocalPictogram.fromJson(item));
        } else if (item is Map) {
          pictograms.add(
            LocalPictogram.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    return LocalClasseur(
      schemaVersion:
          (json['schemaVersion'] as num?)?.toInt() ?? currentSchemaVersion,
      nextCategoryId: (json['nextCategoryId'] as num?)?.toInt() ?? 1,
      nextPictogramId: (json['nextPictogramId'] as num?)?.toInt() ?? 1,
      categories: categories,
      pictograms: pictograms,
    );
  }
}
