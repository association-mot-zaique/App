import 'pictogram.dart';

class SavedPhrase {
  const SavedPhrase({
    required this.id,
    required this.name,
    required this.pictograms,
    required this.createdAt,
  });

  final String id;
  final String name;
  final List<Pictogram> pictograms;
  final DateTime createdAt;

  String get text => pictograms.map((picto) => picto.label).join(' ').trim();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'pictograms': pictograms.map((picto) => picto.toJson()).toList(),
    };
  }

  factory SavedPhrase.fromJson(Map<String, dynamic> json) {
    final rawPictograms = json['pictograms'];
    final pictograms = <Pictogram>[];

    if (rawPictograms is List) {
      for (final item in rawPictograms) {
        if (item is Map<String, dynamic>) {
          pictograms.add(Pictogram.fromJson(item));
        } else if (item is Map) {
          pictograms.add(Pictogram.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return SavedPhrase(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      pictograms: pictograms,
    );
  }
}
