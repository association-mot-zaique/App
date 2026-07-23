/// A pictogram owned by the user and stored on the device.
///
/// The image is referenced by [imagePath], a path relative to the classeur
/// root directory (e.g. `images/picto_1.png`). There is deliberately **no**
/// remote URL: a local pictogram never depends on the network (CDC 5.1 / 6.3).
class LocalPictogram {
  const LocalPictogram({
    required this.id,
    required this.label,
    required this.imagePath,
    required this.categoryId,
    required this.sortOrder,
    this.isFavorite = false,
  });

  final int id;
  final String label;

  /// Path to the image file, relative to the classeur root directory.
  final String imagePath;

  final int categoryId;

  /// Display order within its category. Stable for the end user.
  final int sortOrder;

  /// Favorites are a cross-cutting view over frequent vocabulary (CDC 4.1).
  final bool isFavorite;

  LocalPictogram copyWith({
    String? label,
    String? imagePath,
    int? categoryId,
    int? sortOrder,
    bool? isFavorite,
  }) {
    return LocalPictogram(
      id: id,
      label: label ?? this.label,
      imagePath: imagePath ?? this.imagePath,
      categoryId: categoryId ?? this.categoryId,
      sortOrder: sortOrder ?? this.sortOrder,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'imagePath': imagePath,
      'categoryId': categoryId,
      'sortOrder': sortOrder,
      'isFavorite': isFavorite,
    };
  }

  factory LocalPictogram.fromJson(Map<String, dynamic> json) {
    return LocalPictogram(
      id: (json['id'] as num).toInt(),
      label: json['label'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
