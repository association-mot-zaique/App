/// A category of the user-owned local classeur.
///
/// Unlike the ARASAAC explorer presets, a category here is data the aidant
/// created and that lives entirely on the device.
class LocalCategory {
  const LocalCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  final int id;
  final String name;

  /// Display order within the classeur. Positions stay stable for the end
  /// user; only the aidant reorders (see CDC 3.1).
  final int sortOrder;

  LocalCategory copyWith({String? name, int? sortOrder}) {
    return LocalCategory(
      id: id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'sortOrder': sortOrder};
  }

  factory LocalCategory.fromJson(Map<String, dynamic> json) {
    return LocalCategory(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}
