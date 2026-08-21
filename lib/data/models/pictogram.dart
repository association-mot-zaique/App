class Pictogram {
  const Pictogram({
    required this.id,
    required this.label,
    this.tags = const [],
    this.categories = const [],
    this.language = 'es',
    this.aac = false,
    this.schematic = false,
    this.downloads = 0,
    this.violence = false,
    this.sex = false,
    this.localImagePath,
  });

  final int id;
  final String label;
  final List<String> tags;
  final List<String> categories;
  final String language;
  final bool aac;
  final bool schematic;
  final int downloads;

  /// ARASAAC's own content flags. Flagged pictograms are filtered out of
  /// every search: the app is distributed in Google Play's children category,
  /// where any reachable violent or sexual content is grounds for rejection
  /// (politique Familles, rejet du 21/08/2026).
  final bool violence;
  final bool sex;

  /// Absolute path to an owned image on disk. When set, the pictogram is a
  /// local classeur entry and must be rendered from the file, never the
  /// network (CDC 6.3).
  final String? localImagePath;

  bool get isLocal => localImagePath != null && localImagePath!.isNotEmpty;

  /// Same pictogram pointing at another owned image file, used to re-anchor
  /// a stale absolute path after a reinstall or a profile switch.
  Pictogram withLocalImagePath(String newPath) {
    return Pictogram(
      id: id,
      label: label,
      tags: tags,
      categories: categories,
      language: language,
      aac: aac,
      schematic: schematic,
      downloads: downloads,
      violence: violence,
      sex: sex,
      localImagePath: newPath,
    );
  }

  factory Pictogram.fromArasaacJson(
    Map<String, dynamic> json, {
    required String language,
  }) {
    final dynamic rawId = json['_id'] ?? json['id'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '');
    if (parsedId == null) {
      // Developer diagnostic: caught and skipped by the search loop, never
      // surfaced to the user (who always sees a localized message).
      throw const FormatException('Pictogram without a valid ID');
    }

    final tags = <String>[];
    final rawTags = json['tags'];
    if (rawTags is List) {
      for (final tag in rawTags) {
        if (tag != null) {
          tags.add(tag.toString());
        }
      }
    }

    final categories = <String>[];
    final rawCategories = json['categories'];
    if (rawCategories is List) {
      for (final item in rawCategories) {
        if (item != null) {
          categories.add(item.toString());
        }
      }
    }

    return Pictogram(
      id: parsedId,
      label: _extractLabel(json),
      tags: tags,
      categories: categories,
      language: language,
      aac: _boolFromJson(json['aac']),
      schematic: _boolFromJson(json['schematic']),
      downloads: _intFromJson(json['downloads']),
      violence: _boolFromJson(json['violence']),
      sex: _boolFromJson(json['sex']),
    );
  }

  factory Pictogram.fromJson(Map<String, dynamic> json) {
    final rawTags = json['tags'];
    final rawCategories = json['categories'];

    return Pictogram(
      id: json['id'] as int,
      label: json['label'] as String,
      language: json['language'] as String? ?? 'es',
      tags: rawTags is List ? rawTags.map((e) => e.toString()).toList() : [],
      categories: rawCategories is List
          ? rawCategories.map((e) => e.toString()).toList()
          : const [],
      aac: json['aac'] as bool? ?? false,
      schematic: json['schematic'] as bool? ?? false,
      downloads: _intFromJson(json['downloads']),
      violence: json['violence'] as bool? ?? false,
      sex: json['sex'] as bool? ?? false,
      localImagePath: json['localImagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'tags': tags,
      'categories': categories,
      'language': language,
      'aac': aac,
      'schematic': schematic,
      'downloads': downloads,
      'violence': violence,
      'sex': sex,
      if (localImagePath != null) 'localImagePath': localImagePath,
    };
  }

  String imageUrl({int size = 300}) {
    // ARASAAC only serves the 300, 500 and 2500 px variants; any other value
    // (e.g. 100 for a thumbnail) is a 404 and shows up as a broken image.
    final int servedSize;
    if (size <= 300) {
      servedSize = 300;
    } else if (size <= 500) {
      servedSize = 500;
    } else {
      servedSize = 2500;
    }
    return 'https://static.arasaac.org/pictograms/$id/${id}_$servedSize.png';
  }

  String get semanticKey {
    final normalizedLabel = _normalizeForKey(label);
    if (normalizedLabel.isNotEmpty) {
      return normalizedLabel;
    }

    if (categories.isNotEmpty) {
      final normalizedCategory = _normalizeForKey(categories.first);
      if (normalizedCategory.isNotEmpty) {
        return normalizedCategory;
      }
    }
    return 'id-$id';
  }

  int get qualityScore {
    var score = 0;
    if (aac) {
      score += 200;
    }
    if (schematic) {
      score += 120;
    }

    final boundedDownloads = downloads.clamp(0, 2000);
    score += boundedDownloads ~/ 10;
    score += tags.length * 2;
    return score;
  }

  static String _extractLabel(Map<String, dynamic> json) {
    final rawKeywords = json['keywords'];
    if (rawKeywords is List) {
      for (final keywordItem in rawKeywords) {
        if (keywordItem is Map && keywordItem['keyword'] != null) {
          final rawValue = keywordItem['keyword'].toString().trim();
          if (rawValue.isNotEmpty) {
            return rawValue;
          }
        }
      }
    }

    final fallback = json['name']?.toString().trim();
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }
    return 'Sin etiqueta';
  }

  static bool _boolFromJson(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  static int _intFromJson(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static String _normalizeForKey(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
